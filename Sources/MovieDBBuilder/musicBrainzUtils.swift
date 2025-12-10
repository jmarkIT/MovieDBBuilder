//
//  musicBrainzUtils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/9/25.
//
import Foundation
import SwiftMusicBrainz

func createMusicBrainzClient() throws -> MusicBrainzClient {
    guard let musicBrainzToken = ProcessInfo.processInfo.environment["MUSIC_BRAINZ_TOKEN"]
    else {
        throw RuntimeError("Please set the MUSIC_BRAINZ_TOKEN environment variable")
    }
    guard let userAgent = ProcessInfo.processInfo.environment["MUSIC_BRAINZ_USER_AGENT"]
    else {
        throw RuntimeError("Please set MUSIC_BRAINZ_USER_AGENT environment variable")
    }
    let cfg = MusicBrainzConfig(authToken: musicBrainzToken, userAgent: userAgent)
    let musicBrainz = MusicBrainzClient(cfg: cfg)
    return musicBrainz
}
