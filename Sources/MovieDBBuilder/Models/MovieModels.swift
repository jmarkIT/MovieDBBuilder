//
//  MovieModels.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/12/25.
//

import GRDB
import SwiftTMDB
import Foundation

struct Movies: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: Int
    var title: String
    var budget: Int
    var revenue: Int
    var runtime: Int

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let budget = Column(CodingKeys.budget)
        static let revenue = Column(CodingKeys.revenue)
        static let runtime = Column(CodingKeys.runtime)
    }
}

extension Movies {
    init(from api: TMDBMovie) {
        self.init(
            id: api.id,
            title: api.title,
            budget: api.budget,
            revenue: api.revenue,
            runtime: api.runtime
        )
    }
}

struct Genres: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: Int
    var name: String

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }
}

extension Genres {
    init(from api: Genre) {
        self.init(id: api.id, name: api.name)
    }
}

struct People: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: Int
    var name: String
    var gender: Int
    var knownForDepartment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case gender
        case knownForDepartment = "knownForDepartment"
    }

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let gender = Column(CodingKeys.gender)
        static let knownForDepartment = Column(CodingKeys.knownForDepartment)
    }
}

extension People {
    init(from api: Credit) {
        self.init(
            id: api.id,
            name: api.name,
            gender: api.gender,
            knownForDepartment: api.knownForDepartment
        )
    }
}

struct MoviesToGenres: Codable, FetchableRecord, PersistableRecord
{
    var movieId: Int
    var genreId: Int
    
    enum CodingKeys: String, CodingKey {
        case movieId = "movieId"
        case genreId = "genreId"
    }

    enum Columns {
        static let movieId = Column(CodingKeys.movieId)
        static let genreId = Column(CodingKeys.genreId)
    }
}

extension MoviesToGenres {
    init(from api: TMDBMovie, id: Int, genreId: Int) {
        self.movieId = api.id
        self.genreId = genreId
    }
}

struct MoviesToPeople: Codable, Identifiable, FetchableRecord, PersistableRecord
{
    var id: UUID = UUID()
    var creditId: String
    var movieId: Int
    var personId: Int
    var isCast: Int
    var castId: Int?
    var character: String?
    var order: Int?
    var department: String?
    var job: String?
    
    enum CodingKeys: String, CodingKey {
        case creditId = "creditId"
        case movieId = "movieId"
        case personId = "personId"
        case isCast = "isCast"
        case castId = "castId"
        case character
        case order
        case department
        case job
    }

    enum Columns {
        static let creditId = Column(CodingKeys.creditId)
        static let movieId = Column(CodingKeys.movieId)
        static let personId = Column(CodingKeys.personId)
        static let isCast = Column(CodingKeys.isCast)
        static let castId = Column(CodingKeys.castId)
        static let character = Column(CodingKeys.character)
        static let order = Column(CodingKeys.order)
        static let department = Column(CodingKeys.department)
        static let job = Column(CodingKeys.job)
    }
}

extension MoviesToPeople {
    init(from api: Credit, movieId: Int, isCast: Int) {
        self.init(
            creditId: api.creditId,
            movieId: movieId,
            personId: api.id,
            isCast: isCast,
            castId: api.castId,
            character: api.character,
            order: api.order,
            department: api.department,
            job: api.job
        )
    }
}
