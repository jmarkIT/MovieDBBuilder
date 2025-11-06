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
            try createMoviesTable(for: db)

            let movies = Table("movies")
            let id = SQLite.Expression<Int64>("id")
            let title = SQLite.Expression<String>("title")
            let budget = SQLite.Expression<Int64>("budget")
            let revenue = SQLite.Expression<Int64>("revenue")
            let runtime = SQLite.Expression<Int64>("runtime")

            for movie in tmdbMovies {
                do {
                    let insert = movies.insert(
                        id <- Int64(movie.id),
                        title <- movie.title,
                        budget <- Int64(movie.budget),
                        revenue <- Int64(movie.revenue),
                        runtime <- Int64(movie.runtime),
                        
                    )
                    try db.run(insert)
                } catch {
                    // Continue on per-row errors (e.g., unique constraint violations)
                    print("Skipping movie id \(movie.id) due to DB error: \(error)")
                    continue
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

