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
        guard let authToken = ProcessInfo.processInfo.environment["TMDB_TOKEN"]
        else {
            print("Please set the TMDB_AUTH_TOKEN environment variable")
            throw ExitCode.failure
        }
        let cfg = TMDBConfig(authToken: authToken)
        let tmdb = TMDBClient(cfg: cfg)
        var tmdbIDs: [String] = []
        var tmdbMovies: [TMDBMovie] = []
        guard
            let input = try? String(contentsOfFile: inputFile, encoding: .utf8)
        else {
            throw RuntimeError("Couldn't read from '\(inputFile)'")
        }
        print("Getting tmdbids from file \(inputFile)")
        for line in input.components(separatedBy: .newlines) {
            guard !line.isEmpty else { continue }
            tmdbIDs.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        print("Getting movie data from TMDB API...")
        for id in tmdbIDs {
            do {
                let movie = try await tmdb.getMovie(
                    movieId: id,
                    appendToResponse: ["credits"]
                )
                tmdbMovies.append(movie)
            } catch {
                print("Skipping id \(id) due to error: \(error)")
                continue
            }
        }

        print("Getting genres from TMDB API...")
        var tmdbGenres: [Genre] = []
        do {
            let genres = try await tmdb.getGenres()
            tmdbGenres.append(contentsOf: genres)
        } catch {
            print("Error while getting genres: \(error)")
        }

        let dbMovies = tmdbMovies.map(Movies.init(from:))
        let dbGenres = tmdbGenres.map(Genres.init(from:))
        let dbPeople = tmdbMovies.flatMap { movie in
            guard let credits = movie.credits else { return [] as [People] }
            return credits.cast.map(People.init(from:))
                + credits.crew.map(People.init(from:))
        }
        let dbMoviesToGenres = tmdbMovies.flatMap { movie in
            movie.genres.map {
                MoviesToGenres(movieId: movie.id, genreId: $0.id)
            }
        }
        let dbMoviesToPeople: [MoviesToPeople] = tmdbMovies.flatMap {
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

        do {
            let dbQueue = try! DatabaseQueue(path: "db.sqlite3")
            try await makeTables(dbQueue: dbQueue)

            do {
                try await dbQueue.write { db in
                    print("Inserting movies...")
                    for movie in dbMovies {
                        try movie.upsert(db)
                    }

                    print("Inserting genres...")
                    for genre in dbGenres {
                        try genre.upsert(db)
                    }

                    print("Inserting people...")
                    for person in dbPeople {
                        try person.upsert(db)
                    }

                    print("Inserting movie-genre relationships...")
                    for movieToGenre in dbMoviesToGenres {
                        try movieToGenre.upsert(db)
                    }

                    print("Inserting movie-person relationships...")
                    for movieToPerson in dbMoviesToPeople {
                        try movieToPerson.upsert(db)
                    }

                }
            } catch {
                print("Error while inserting movies: \(error)")
            }

        } catch {
            print(error)
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}
