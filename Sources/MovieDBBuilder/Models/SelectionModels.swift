//
//  SelectionModels.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/25/25.
//

import GRDB

struct WeeklySelections: Codable, FetchableRecord, PersistableRecord {
    var weekOf: DatabaseDateComponents
    var masterOfCeremony: String
    var movieId1: Int
    var movieId2: Int?

    enum CodingKeys: String, CodingKey {
        case weekOf = "weekOf"
        case masterOfCeremony = "masterOfCeremony"
        case movieId1 = "movie1Id"
        case movieId2 = "movie2Id"
    }

    enum Columns {
        static let weekOf = Column(CodingKeys.weekOf)
        static let masterofCeremony = Column(CodingKeys.masterOfCeremony)
        static let movieId1 = Column(CodingKeys.movieId1)
        static let movieId2 = Column(CodingKeys.movieId2)
    }
}
