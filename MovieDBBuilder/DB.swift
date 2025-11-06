//
//  DB.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import SQLite
import SwiftTMDB

func createMoviesTable(for db: Connection) throws {
    let movies = Table("movies")
    let id = SQLite.Expression<Int64>("id")
    let title = SQLite.Expression<String>("title")
    let budget = SQLite.Expression<Int64>("budget")
    let revenue = SQLite.Expression<Int64>("revenue")
    let runtime = SQLite.Expression<Int64>("runtime")

    try db.run(movies.create(ifNotExists: true) { t in
        t.column(id, primaryKey: true)
        t.column(title)
        t.column(budget)
        t.column(revenue)
        t.column(runtime)
    })
}

