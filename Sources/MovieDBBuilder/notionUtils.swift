import Foundation
//
//  notionUtils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/26/25.
//
import GRDB
import SwiftNotion

func makeDatabaseDateComponents(from dateString: String)
    -> DatabaseDateComponents?
{
    guard let comps = makeDateComponents(from: dateString) else { return nil }
    return DatabaseDateComponents(comps, format: .YMD)
}

func makeDateComponents(from dateString: String) -> DateComponents? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    let calendar = Calendar.current

    guard let date = formatter.date(from: dateString) else {
        return nil
    }
    return calendar.dateComponents([.year, .month, .day], from: date)
}

func buildWeeklySelections(from week: NotionPage, with movies: [NotionPage])
    -> WeeklySelections
{
    // TODO: Fix this force unwrapping
    let dateString = week.properties["Week of"]!.date!.start
    let dbDateComps = makeDatabaseDateComponents(from: dateString)
    // TODO: Fix this force unwrapping
    let movieId1 = Int(movies[0].properties["TMDB ID"]!.plainText!)
    var movieId2: Int? = nil
    if movies.count == 2 {
        movieId2 = Int(movies[1].properties["TMDB ID"]!.plainText!)
    }
    let masterOfCeremony = week.properties["Master of Ceremony"]?.select?.name ?? ""

    //    guard let comps = dbDateComps else {
    //        print(movieId)
    //        return nil
    //    }

    // TODO: Fix this force unwrapping
    return WeeklySelections(weekOf: dbDateComps!, masterOfCeremony: masterOfCeremony, movieId1: movieId1!, movieId2: movieId2)
}

func extractMoviePages(from week: NotionPage, with client: NotionClient)
    async throws -> [NotionPage]
{
    var moviePages: [NotionPage] = []
    // TODO: Fix this force unwrapping
    let relations = week.properties["Movie"]!.relation!
    let moviePageId1 = relations[0].id
    let moviePage1 = try await client.getPage(pageId: moviePageId1)
    moviePages.append(moviePage1)
    if relations.count == 2 {
        let moviePageId2 = relations[1].id
        let moviePage2 = try await client.getPage(pageId: moviePageId2)
        moviePages.append(moviePage2)
    }

    return moviePages
}
