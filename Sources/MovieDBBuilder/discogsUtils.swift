//
//  discogsUtils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/9/25.
//

import Foundation
import SwiftDiscogs

func createDiscogsClient() throws -> DiscogsClient {
    guard let discogsToken = ProcessInfo.processInfo.environment["DISCOGS_TOKEN"]
    else {
        throw RuntimeError("Please set the DISCOGS_TOKEN environment variable")
    }
    let cfg = DiscogsConfig(authToken: discogsToken)
    let tmdb = DiscogsClient(cfg: cfg)
    return tmdb
}
