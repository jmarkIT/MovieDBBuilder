//
//  DBInsert.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/7/25.
//

import SQLite
import SwiftTMDB

func insertMovie(_ movie: TMDBMovie, into db: Connection) throws {
    let moviesTable = Table("movies")
    let movieId = SQLite.Expression<Int64>("id")
    let title = SQLite.Expression<String>("title")
    let budget = SQLite.Expression<Int64>("budget")
    let revenue = SQLite.Expression<Int64>("revenue")
    let runtime = SQLite.Expression<Int64>("runtime")

    let insert = moviesTable.insert(
        movieId <- Int64(movie.id),
        title <- movie.title,
        budget <- Int64(movie.budget),
        revenue <- Int64(movie.revenue),
        runtime <- Int64(movie.runtime),

    )

    try db.run(insert)
}

func insertGenres(using client: TMDBClient, into db: Connection) async throws {
    let genres = try await client.getGenres()

    let genresTable = Table("genres")
    let genreId = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")

    for genre in genres {
        let insert = genresTable.insert(
            genreId <- Int64(genre.id),
            name <- genre.name
        )

        try db.run(insert)
    }
}
