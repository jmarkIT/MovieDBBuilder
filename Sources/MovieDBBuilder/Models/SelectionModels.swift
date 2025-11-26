//
//  SelectionModels.swift
//  MovieDBBuilder
//
//  Created by James Mark on 11/25/25.
//

import GRDB

struct WeeklySelections: Codable, FetchableRecord, PersistableRecord {
    var weekOf: DatabaseDateComponents
}

