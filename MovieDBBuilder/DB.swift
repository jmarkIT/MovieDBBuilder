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
    try createPeopleTable(for: db)
    try createPeopleToMoviesTable(for: db)
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

func createPeopleTable(for db: Connection) throws {
    let peopleTable = Table("people")
    let id = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")
    let gender = SQLite.Expression<Int64>("gender")
    let knownForDepartment = SQLite.Expression<String?>("known_for_department")
    let placeOfBirth = SQLite.Expression<String?>("place_of_birth")
    let birthday = SQLite.Expression<String?>("birthday")
    let deathday = SQLite.Expression<String?>("deathday")

    try db.run(
        peopleTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(gender)
            t.column(knownForDepartment)
            t.column(placeOfBirth)
            t.column(birthday)
            t.column(deathday)
        }
    )
}

func createPeopleToMoviesTable(for db: Connection) throws {
    let peopleToMoviesTable = Table("people_to_movies")
    let peopleToMoviesId = SQLite.Expression<String>("id")
    let personId = SQLite.Expression<Int64>("person_id")
    let movieId = SQLite.Expression<Int64>("movie_id")
    let isCast = SQLite.Expression<Int64>("is_cast")
    let character = SQLite.Expression<String?>("role")
    let order = SQLite.Expression<Int64?>("order")
    let department = SQLite.Expression<String?>("department")
    let job = SQLite.Expression<String?>("job")

    try db.run(
        peopleToMoviesTable.create(ifNotExists: true) { t in
            t.column(peopleToMoviesId, primaryKey: true)
            t.column(personId)
            t.column(movieId)
            t.column(isCast)
            t.column(character)
            t.column(order)
            t.column(department)
            t.column(job)
        }
    )
}
