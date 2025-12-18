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
        try db.create(table: "movies", options: [.ifNotExists]) { t in
            t.primaryKey("id", .integer)
            t.column("title", .text).notNull()
            t.column("budget", .integer)
            t.column("revenue", .integer)
            t.column("runtime", .integer)
        }

        // Create Genres table
        try db.create(table: "genres", options: [.ifNotExists]) { t in
            t.primaryKey("id", .integer)
            t.column("name", .text).notNull()
        }

        // Create People table
        try db.create(table: "people", options: [.ifNotExists]) { t in
            t.primaryKey("id", .integer)
            t.column("name", .text).notNull()
            t.column("gender", .integer).notNull()
            t.column("knownForDepartment", .text)
        }

        // Create MoviesToGenre table
        try db.create(table: "moviesToGenres", options: [.ifNotExists]) { t in
            t.column("movieId", .integer).notNull()
            t.column("genreId", .integer).notNull()
            t.primaryKey(["movieId", "genreId"])
        }

        // Create MoviesToPeople table
        try db.create(table: "moviesToPeople", options: [.ifNotExists]) { t in
            t.primaryKey("creditId", .text)
            t.column("movieId", .integer).notNull()
            t.column("personId", .integer).notNull()
            t.column("isCast", .integer).notNull()
            t.column("castId", .integer)
            t.column("character", .text)
            t.column("order", .integer)
            t.column("department", .text)
            t.column("job", .text)
        }

        // Create Albums table
        try db.create(table: "albums", options: [.ifNotExists]) { t in
            t.primaryKey("id", .text)
            t.column("title", .text)
            t.column("date", .text)
        }

        // Create AlbumGenres table
        try db.create(table: "albumGenres", options: [.ifNotExists]) { t in
            t.primaryKey("id", .text)
            t.column("name", .text)
        }

        // Create AlbumsToAlbumGenres table
        try db.create(table: "albumsToGenres", options: [.ifNotExists]) {
            t in
            t.belongsTo("album", inTable: "albums").notNull()
            t.belongsTo("genre", inTable: "albumGenres").notNull()
            t.primaryKey(["albumId", "genreId"])
        }

        // Create WeeklySelections table
        try db.create(table: "weeklySelections", options: [.ifNotExists]) { t in
            t.primaryKey("weekOf", .text)
            t.column("masterOfCeremony", .text).notNull()
            t.belongsTo("movie1", inTable: "movies").notNull()
            t.belongsTo("movie2", inTable: "movies")
            t.belongsTo("album1", inTable: "albums")
            t.belongsTo("album2", inTable: "albums")
        }
    }
}
