//
//  main.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import ArgumentParser
import Foundation
import GRDB
import SwiftNotion
import SwiftTMDB

@main
struct CreateMovieDB: AsyncParsableCommand {
    mutating func run() async throws {
        // Build api clients
        let tmdb = try createTMDBClient()
        let notion = try createNotionClient()
        let musicBrainz = try createMusicBrainzClient()
        
        let album = try await musicBrainz.getRelease(releaseId: "aa97e4af-a4a6-4e59-9319-80f7fa64e376")
        print(album)
        

        // Get Movie Data from Notion
        let movieRows = try await notion.getDatabaseRows(
            dataSourceId: "a105db30-4d76-40b0-99c9-32f1faede907"
        )
        var tmdbIds: [String] = []
        for movie in movieRows {
            let tmdbId = movie.properties["TMDB ID"]!.plainText!
            tmdbIds.append(tmdbId)
        }

        // Get movie details from IDs
        print("Getting movie data from TMDB API...")
        let tmdbMovies = await getTMDBMovies(from: tmdbIds, with: tmdb)

        // Call the TMDB api to pull all available genres
        print("Getting genres from TMDB API...")
        let tmdbGenres = try await getTMDBGenres(with: tmdb)

        // Convert data to format to insert into database
        let (dbMovies, dbGenres, dbPeople, dbMoviesToGenres, dbMoviesToPeople) =
            convertTMDBtoDB(movies: tmdbMovies, genres: tmdbGenres)

        print("Getting rows from Notion database...")
        let rows = try await notion.getDatabaseRows(
            dataSourceId: "9d9e132b-5b77-496f-b78b-3c0abd33d1f2"
        )

        print("Getting ")
        var pageList: [NotionPage] = []
        for row in rows {
            let page = try await notion.getPage(pageId: row.id)
            pageList.append(page)
        }

        var weeklySelections: [WeeklySelections] = []
        for page in pageList {
            let moviePages = try await extractMoviePages(
                from: page,
                with: notion
            )
            let weeklySelection = buildWeeklySelections(
                from: page,
                with: moviePages
            )
            weeklySelections.append(weeklySelection)
        }

        try await insertToDatabase(
            movies: dbMovies,
            genres: dbGenres,
            people: dbPeople,
            moviesToGenres: dbMoviesToGenres,
            moviesToPeople: dbMoviesToPeople,
            weeklySelections: weeklySelections
        )
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}
