//
//  main.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import ArgumentParser
import Foundation
import SQLite
import SwiftTMDB

@main
struct CreateMovieDB: AsyncParsableCommand {
    @Argument(help: "a csv file containing a list of TMDB ids")
    var inputFile: String

    mutating func run() async throws {
        let tmdb = TMDBClient()
        var tmdbIDs: [String] = []
        var tmdbMovies: [TMDBMovie] = []
        guard
            let input = try? String(contentsOfFile: inputFile, encoding: .utf8)
        else {
            throw RuntimeError("Couldn't read from '\(inputFile)'")
        }
        for line in input.components(separatedBy: .newlines) {
            guard !line.isEmpty else { continue }
            tmdbIDs.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
        }
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

        do {
            let db = try Connection("db.sqlite3")
            try createDatabase(for: db)

            let moviesToGenres = Table("movies_to_genres")
            let moviesToGenresId = SQLite.Expression<Int64>("id")
            let moviesToGenresMovieId = SQLite.Expression<Int64>("movie_id")
            let moviesToGenresGenreId = SQLite.Expression<Int64>("genre_id")

            // Call api to populate genres table
            do {
                try await insertGenres(using: tmdb, into: db)
            } catch {
                print("Failed to insert genres: Aborting")
                print(error)
            }

            // Add the movie to the database
            for movie in tmdbMovies {
                do {
                    try insertMovie(movie, into: db)
                } catch {
                    print(
                        "Skipping movie \(movie.title) due to error: \(error)"
                    )
                    continue
                }

                // Add a relationship to the junction table for each genre
                for genre in movie.genres {
                    do {
                        // TODO: do this more cleanly
                        let key = Int64(String(movie.id) + String(genre.id))!
                        let insert = moviesToGenres.insert(
                            moviesToGenresId <- key,
                            moviesToGenresMovieId <- Int64(movie.id),
                            moviesToGenresGenreId <- Int64(genre.id),
                        )
                        try db.run(insert)
                    } catch {
                        // Continue on per-row errors (e.g., unique constraint violations)
                        print(error)
                        continue
                    }
                }
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
