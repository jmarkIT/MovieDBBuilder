//
//  main.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/5/25.
//

import ArgumentParser
import Foundation
import GRDB
import SwiftNotion
import SwiftTMDB

@main
struct CreateMovieDB: AsyncParsableCommand {
    mutating func run() async throws {
        // Build api clients
        let tmdb = try createTMDBClient()
        let notion = try createNotionClient()
        let musicBrainz = try createMusicBrainzClient()

        // Get Album Data from Notion
        print("Getting albums from Notion...")
        let albumRows = try await notion.getDatabaseRows(
            dataSourceId: "9f42fba7-d154-430d-b025-679ea1f1123b"
        )
        var musicBrainzReleaseIds: [String] = []
        for album in albumRows {
            let musicBrainzId = album.properties["MusicBrainz Release ID"]!
                .plainText!
            musicBrainzReleaseIds.append(musicBrainzId)
        }

        // Get album details from MusicBrainz
        print("Getting album details from MusicBrainz...")
//        let musicBrainzReleases = try await getMusicBrainzReleases(
//            from: musicBrainzIds,
//            with: musicBrainz
//        )
//        let musicBrainzReleaseIds = [
//            "3c54c98c-6151-4eee-8981-5a7d9b7da97c",
//            "a57a4689-eb83-4ffc-b083-f3c30956108f",
//            "4a18986d-1598-43a8-b15f-0340af442ffe",
//        ]
        let musicBrainzReleases = try await getMusicBrainzReleases(
            from: musicBrainzReleaseIds,
            with: musicBrainz
        )

        // Get all MusicBrainz genres
        print("Getting music genres from MusicBrainz...")
        let musicBrainzGenres = try await musicBrainz.getAllGenres()

        // Convert album data to format to insert into database
        let (dbAlbums, dbAlbumGenres, dbAlbumsToGenres) =
            convertMusicBrainzToDB(
                albums: musicBrainzReleases,
                genres: musicBrainzGenres
            )

        // Get Movie Data from Notion
        print("Getting movie data from Notion...")
        let movieRows = try await notion.getDatabaseRows(
            dataSourceId: "a105db30-4d76-40b0-99c9-32f1faede907"
        )
        var tmdbIds: [String] = []
        for movie in movieRows {
            let tmdbId = movie.properties["TMDB ID"]!.plainText!
            tmdbIds.append(tmdbId)
        }

        // Get movie details from IDs
        print("Getting movie data from TMDB API...")
        let tmdbMovies = try await getTMDBMovies(from: tmdbIds, with: tmdb)

        // Call the TMDB api to pull all available genres
        print("Getting genres from TMDB API...")
        let tmdbGenres = try await getTMDBGenres(with: tmdb)

        // Convert data to format to insert into database
        let (dbMovies, dbGenres, dbPeople, dbMoviesToGenres, dbMoviesToPeople) =
            convertTMDBtoDB(movies: tmdbMovies, genres: tmdbGenres)

        print("Getting rows from Notion database...")
        let rows = try await notion.getDatabaseRows(
            dataSourceId: "9d9e132b-5b77-496f-b78b-3c0abd33d1f2"
        )

        print("Getting Weekly Selections from Notion database...")
        var weeklySelectionPageList: [NotionPage] = []
        for row in rows {
            let page = try await notion.getPage(pageId: row.id)
            weeklySelectionPageList.append(page)
        }

        var weeklySelections: [WeeklySelections] = []
        for page in weeklySelectionPageList {
            let moviePages = try await extractMoviePages(
                from: page,
                with: notion
            )
            let weeklySelection = buildWeeklySelections(
                from: page,
                with: moviePages
            )
            weeklySelections.append(weeklySelection)
        }

        try await insertToDatabase(
            movies: dbMovies,
            genres: dbGenres,
            people: dbPeople,
            moviesToGenres: dbMoviesToGenres,
            moviesToPeople: dbMoviesToPeople,
            albums: dbAlbums,
            albumGenres: dbAlbumGenres,
            albumsToGenres: dbAlbumsToGenres,
            weeklySelections: weeklySelections
        )
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}
