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
            // Set up database connection
            let db = try Connection("db.sqlite3")
            try createDatabase(for: db)

            // Call api to populate genres table
            do {
                try await insertGenres(using: tmdb, into: db)
            } catch {
                print("Failed to insert genres: Aborting")
                print(error)
            }

            // Add each movie to the database
            for movie in tmdbMovies {
                do {
                    try insertMovie(movie, into: db)
                } catch {
                    print(
                        "Skipping movie \(movie.title) due to error: \(error)"
                    )
                    continue
                }
                
                // Add each person in the credits to the people table
                if let credits = movie.credits {
                    print("Adding credits for \(movie.title)")
                    for credit in credits.cast {
                        do {
                            try insertPerson(person: credit, with: db)
                        } catch {
                            print("Skipping \(credit.name) due to error: \(error)")
                        }
                    }
                    for credit in credits.crew {
                        do {
                            try insertPerson(person: credit, with: db)
                        } catch {
                            print("Skipping \(credit.name) due to error: \(error)")
                        }
                    }
                    
                }

                // Add a relationship to the junction table for each genre
                do {
                    try insertMovieToGenre(movie: movie, with: db)
                } catch {
                    print("Failed to insert relationship of \(movie.title): \(error)")
                }
                
                // Add a reltionship to the junction table for each credit
                do {
                    try insertPeopleToMovie(movie: movie, with: db)
                } catch {
                    print("Failed to insert relationship of \(movie.title): \(error)")
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
