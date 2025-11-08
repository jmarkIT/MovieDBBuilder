//
//  DB.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import SQLite
import SwiftTMDB

func createDatabase(for db: Connection) throws {
    try createMoviesTable(for: db)
    try createGenresTable(for: db)
    try createMoviesToGenresTable(for: db)
}

func createMoviesTable(for db: Connection) throws {
    let movies = Table("movies")
    let id = SQLite.Expression<Int64>("id")
    let title = SQLite.Expression<String>("title")
    let budget = SQLite.Expression<Int64>("budget")
    let revenue = SQLite.Expression<Int64>("revenue")
    let runtime = SQLite.Expression<Int64>("runtime")

    try db.run(
        movies.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(budget)
            t.column(revenue)
            t.column(runtime)
        }
    )
}

func createGenresTable(for db: Connection) throws {
    let genres = Table("genres")
    let id = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")

    try db.run(
        genres.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
        }
    )
}

func createMoviesToGenresTable(for db: Connection) throws {
    let moviesToGenres = Table("movies_to_genres")
    let movieIdAndGenreId = SQLite.Expression<Int64>("id")
    let movieId = SQLite.Expression<Int64>("movie_id")
    let genreId = SQLite.Expression<Int64>("genre_id")

    try db.run(
        moviesToGenres.create(ifNotExists: true) { t in
            t.column(movieIdAndGenreId, primaryKey: true)
            t.column(movieId)
            t.column(genreId)
            
        }
    )
}
