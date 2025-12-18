//
//  AlbumModels.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/14/25.
//

import Foundation
import GRDB
import SwiftMusicBrainz

struct Albums: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: String
    var title: String
    var date: String

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let date = Column(CodingKeys.date)
    }
}

extension Albums {
    init(from api: MusicBrainzRelease) {
        self.init(id: api.id, title: api.title, date: api.date)
    }
}

struct AlbumGenres: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }
}

extension AlbumGenres {
    init(from api: MusicBrainzGenre) {
        self.init(id: api.id, name: api.name)
    }
}

struct AlbumsToGenres: Codable, FetchableRecord, PersistableRecord {
    var albumId: String
    var genreId: String
    
    enum Columns {
        static let albumId = Column(CodingKeys.albumId)
        static let genreId = Column(CodingKeys.genreId)
    }
}

extension AlbumsToGenres {
    init(from api: MusicBrainzRelease, genreId: String){
        self.albumId = api.id
        self.genreId = genreId
    }
}
