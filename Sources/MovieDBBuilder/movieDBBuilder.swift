//
//  main.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import ArgumentParser
import Foundation
import GRDB
import SwiftTMDB

@main
struct CreateMovieDB: AsyncParsableCommand {
    @Argument(help: "a csv file containing a list of TMDB ids")
    var inputFile: String

    mutating func run() async throws {
        // Build api clients
        let tmdb = try createTMDBClient()
        let notion = try createNotionClient()

        // Parse input file for TMDB IDs
        let tmdbIds = try parseTMDBIds(inputFile)

        // Get movie details from IDs
        print("Getting movie data from TMDB API...")
        let tmdbMovies = await getTMDBMovies(from: tmdbIds, with: tmdb)

        // Call the TMDB api to pull all available genres
        print("Getting genres from TMDB API...")
        let tmdbGenres = try await getTMDBGenres(with: tmdb)

        // Convert data to format to insert into database
        let (dbMovies, dbGenres, dbPeople, dbMoviesToGenres, dbMoviesToPeople) =
            convertTMDBtoDB(movies: tmdbMovies, genres: tmdbGenres)
        
        try await insertToDatabase(movies: dbMovies, genres: dbGenres, people: dbPeople, moviesToGenres: dbMoviesToGenres, moviesToPeople: dbMoviesToPeople)
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}
