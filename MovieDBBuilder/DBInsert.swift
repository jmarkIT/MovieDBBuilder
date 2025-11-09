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

func insertMovieToGenre(movie: TMDBMovie, with db: Connection) throws {
    let moviesToGenres = Table("movies_to_genres")
    let moviesToGenresId = SQLite.Expression<Int64>("id")
    let moviesToGenresMovieId = SQLite.Expression<Int64>("movie_id")
    let moviesToGenresGenreId = SQLite.Expression<Int64>("genre_id")

    for genre in movie.genres {
        let key = Int64(String(movie.id) + String(genre.id))!
        let insert = moviesToGenres.insert(
            moviesToGenresId <- key,
            moviesToGenresMovieId <- Int64(movie.id),
            moviesToGenresGenreId <- Int64(genre.id),
        )

        try db.run(insert)
    }
}

func insertPerson(person: Credit, with db: Connection) throws {
    let peopleTable = Table("people")
    let id = SQLite.Expression<Int64>("id")
    let name = SQLite.Expression<String>("name")
    let gender = SQLite.Expression<Int64>("gender")
    let knownForDepartment = SQLite.Expression<String?>("known_for_department")
    // TODO: figure out a clean way to pull these without having to make 28k API calls repeatedly
    //    let placeOfBirth = SQLite.Expression<String?>("place_of_birth")
    //    let birthday = SQLite.Expression<String?>("birthday")
    //    let deathday = SQLite.Expression<String?>("deathday")

    let insert = peopleTable.insert(
        id <- Int64(person.id),
        name <- person.name,
        gender <- Int64(person.gender),
        knownForDepartment <- person.knownForDepartment,
    )

    try db.run(insert)
}

func insertPeopleToMovie(movie: TMDBMovie, with db: Connection)
    throws
{
    let peopleToMovies = Table("people_to_movies")
    let peopleToMoviesId = SQLite.Expression<String>("id")
    let peopleToMoviesPersonId = SQLite.Expression<Int64>("person_id")
    let peopleToMoviesMovieId = SQLite.Expression<Int64>("movie_id")
    let isCast = SQLite.Expression<Int64>("is_cast")
    let character = SQLite.Expression<String?>("role")
    let order = SQLite.Expression<Int64?>("order")
    let department = SQLite.Expression<String?>("department")
    let job = SQLite.Expression<String?>("job")

    if let credit = movie.credits {
        for credit in credit.cast {
            let isCastRow = 1
            let insert = peopleToMovies.insert(
                peopleToMoviesId <- credit.creditId,
                peopleToMoviesMovieId <- Int64(movie.id),
                peopleToMoviesPersonId <- Int64(credit.id),
                isCast <- Int64(isCastRow),
                character <- credit.character,
                order <- Int64(credit.order!),
            )
            
            try db.run(insert)
        }
        
        for credit in credit.crew {
            let isCastRow = 0
            let insert = peopleToMovies.insert(
                peopleToMoviesId <- credit.creditId,
                peopleToMoviesMovieId <- Int64(movie.id),
                peopleToMoviesPersonId <- Int64(credit.id),
                isCast <- Int64(isCastRow),
                department <- credit.department,
                job <- credit.job,
            )
            
            try db.run(insert)
        }

    }

}
