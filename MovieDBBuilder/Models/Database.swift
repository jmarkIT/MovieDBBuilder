//
//  Database.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/12/25.
//

import GRDB

func makeTables(dbQueue: DatabaseQueue) async throws {
    // Create Movies table
    try await dbQueue.write { db in
        try db.create(table: "movies") { t in
            t.primaryKey("id", .integer)
            t.column("title", .text).notNull()
            t.column("budget", .integer)
            t.column("revenue", .integer)
            t.column("runtime", .integer)
        }

        // Create Genres table
        try db.create(table: "genres") { t in
            t.primaryKey("id", .integer)
            t.column("name", .text).notNull()
        }

        // Create People table
        try db.create(table: "people") { t in
            t.primaryKey("id", .integer)
            t.column("name", .text).notNull()
            t.column("gender", .integer).notNull()
            t.column("known_for_department", .text)
        }

        // Create MoviesToGenre table
        try db.create(table: "moviesToGenres") { t in
            t.column("movie_id", .integer).notNull()
            t.column("genre_id", .integer).notNull()
            t.primaryKey(["movie_id", "genre_id"])
        }
        
        // Create MoviesToPeople table
        try db.create(table: "moviesToPeople") { t in
            t.primaryKey("id", .text)
            t.column("movie_id", .integer).notNull()
            t.column("person_id", .integer).notNull()
            t.column("is_cast", .integer).notNull()
            t.column("cast_id", .integer)
            t.column("character", .text)
            t.column("order", .integer)
            t.column("department", .text)
            t.column("job", .text)
        }
    }
}
