//
//  utils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/25/25.
//

import ArgumentParser
import Foundation
import GRDB
import SwiftMusicBrainz
import SwiftNotion
import SwiftTMDB

func createTMDBClient() throws -> TMDBClient {
    guard let tmdbToken = ProcessInfo.processInfo.environment["TMDB_TOKEN"]
    else {
        throw RuntimeError("Please set the TMDB_TOKEN environment variable")
    }
    let cfg = TMDBConfig(authToken: tmdbToken)
    let tmdb = TMDBClient(cfg: cfg)
    return tmdb
}

func parseTMDBIds(_ inputFile: String) throws -> [String] {
    guard
        let input = try? String(contentsOfFile: inputFile, encoding: .utf8)
    else {
        throw RuntimeError("Couldn't read from '\(inputFile)'")
    }

    print("Getting tmdbids from file \(inputFile)")

    var tmdbIDs: [String] = []
    for line in input.components(separatedBy: .newlines) {
        guard !line.isEmpty else { continue }
        tmdbIDs.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return tmdbIDs
}

func getTMDBMovies(from tmdbIds: [String], with tmdb: TMDBClient) async throws
    -> [TMDBMovie]
{
    let tmdbMovies = try await tmdbIds.concurrentMap(maxConcurrent: 5) {
        try await tmdb.getMovie(movieId: $0, appendToResponse: ["credits"])
    }
    return tmdbMovies
}

func getTMDBGenres(with tmdb: TMDBClient) async throws -> [Genre] {
    var tmdbGenres: [Genre] = []
    do {
        let genres = try await tmdb.getGenres()
        tmdbGenres.append(contentsOf: genres)
    } catch {
        throw RuntimeError("Error while getting genres: \(error)")
    }
    return tmdbGenres
}

func convertTMDBtoDB(movies: [TMDBMovie], genres: [Genre])
    -> ([Movies], [Genres], [People], [MoviesToGenres], [MoviesToPeople])
{
    let dbMovies = movies.map(Movies.init(from:))
    let dbGenres = genres.map(Genres.init(from:))
    let dbPeople = movies.flatMap { movie in
        guard let credits = movie.credits else { return [] as [People] }
        return credits.cast.map(People.init(from:))
            + credits.crew.map(People.init(from:))
    }
    let dbMoviesToGenres = movies.flatMap { movie in
        movie.genres.map {
            MoviesToGenres(movieId: movie.id, genreId: $0.id)
        }
    }
    let dbMoviesToPeople: [MoviesToPeople] = movies.flatMap {
        (movie) -> [MoviesToPeople] in
        guard let credits = movie.credits else {
            return [] as [MoviesToPeople]
        }
        return credits.cast.map {
            MoviesToPeople(
                creditId: $0.creditId,
                movieId: movie.id,
                personId: $0.id,
                isCast: 1,
                castId: $0.castId,
                character: $0.character,
                order: $0.order,
                department: $0.department,
                job: $0.job

            )
        }
            + credits.crew.map {
                MoviesToPeople(
                    creditId: $0.creditId,
                    movieId: movie.id,
                    personId: $0.id,
                    isCast: 0,
                    castId: $0.castId,
                    character: $0.character,
                    order: $0.order,
                    department: $0.department,
                    job: $0.job
                )
            }
    }

    return (dbMovies, dbGenres, dbPeople, dbMoviesToGenres, dbMoviesToPeople)
}

func insertToDatabase(
    movies: [Movies],
    genres: [Genres],
    people: [People],
    moviesToGenres: [MoviesToGenres],
    moviesToPeople: [MoviesToPeople],
    albums: [Albums],
    albumGenres: [AlbumGenres],
    albumsToGenres: [AlbumGenres],
    weeklySelections: [WeeklySelections],
) async throws {
    let dbQueue = try! DatabaseQueue(path: "db.sqlite3")
    try await makeTables(dbQueue: dbQueue)

    try await dbQueue.write { db in
        print("Inserting movies...")
        for movie in movies {
            try movie.upsert(db)
        }

        print("Inserting genres...")
        for genre in genres {
            try genre.upsert(db)
        }

        print("Inserting people...")
        for person in people {
            try person.upsert(db)
        }

        print("Inserting movie-genre relationships...")
        for movieToGenre in moviesToGenres {
            try movieToGenre.upsert(db)
        }

        print("Inserting movie-person relationships...")
        for movieToPerson in moviesToPeople {
            try movieToPerson.upsert(db)
        }
        
        print("Inserting albums...")
        for album in albums {
            try album.upsert(db)
        }
        
        print("Inserting album genres...")
        for genre in albumGenres {
            try genre.upsert(db)
        }
        
        print("Inserting album-genre relationships...")
        for albumToGenre in albumsToGenres {
            try albumToGenre.upsert(db)
        }

        print("Inserting weekly selections...")
        for weeklySelection in weeklySelections {
            try weeklySelection.upsert(db)
        }

    }
}
