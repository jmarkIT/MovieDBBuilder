//
//  musicBrainzUtils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/9/25.
//
import Foundation
import SwiftMusicBrainz

func createMusicBrainzClient() throws -> MusicBrainzClient {
    guard
        let musicBrainzToken = ProcessInfo.processInfo.environment[
            "MUSIC_BRAINZ_TOKEN"
        ]
    else {
        throw RuntimeError(
            "Please set the MUSIC_BRAINZ_TOKEN environment variable"
        )
    }
    guard let appName = ProcessInfo.processInfo.environment["APP_NAME"] else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }
    
    guard let appVersion = ProcessInfo.processInfo.environment["APP_VERSION"] else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }
    
    guard let contactInfo = ProcessInfo.processInfo.environment["CONTACT_INFO"] else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }
    let cfg = MusicBrainzConfig(
        authToken: musicBrainzToken,
        appName: appName,
        appVersion: appVersion,
        contactInfo: contactInfo
    )
    let musicBrainz = MusicBrainzClient(cfg: cfg)
    return musicBrainz
}
