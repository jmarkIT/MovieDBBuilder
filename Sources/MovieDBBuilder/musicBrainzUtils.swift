//
//  musicBrainzUtils.swift
//  MovieDBBuilder
//
//  Created by James Mark on 12/9/25.
//
import Foundation
import SwiftMusicBrainz

func createMusicBrainzClient() throws -> MusicBrainzClient {
    guard let appName = ProcessInfo.processInfo.environment["APP_NAME"] else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }

    guard let appVersion = ProcessInfo.processInfo.environment["APP_VERSION"]
    else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }

    guard let contactInfo = ProcessInfo.processInfo.environment["CONTACT_INFO"]
    else {
        throw RuntimeError("Please set APP_NAME environment variable")
    }
    let cfg = MusicBrainzConfig(
        appName: appName,
        appVersion: appVersion,
        contactInfo: contactInfo
    )
    let musicBrainz = MusicBrainzClient(cfg: cfg)
    return musicBrainz
}

func getMusicBrainzReleases(from musicBrainzIds: [String], with musicBrainz: MusicBrainzClient) async throws -> [MusicBrainzRelease] {
    let musicBrainzReleases = try await musicBrainzIds.concurrentMap(maxConcurrent: 5) {
        try await musicBrainz.getRelease(for: $0)
    }
    return musicBrainzReleases
}

func convertMusicBrainzToDB(
    albums: [MusicBrainzRelease],
    genres: [MusicBrainzGenre]
) -> ([Albums], [AlbumGenres], [AlbumToGenres]) {
    let dbAlbums = albums.map(Albums.init(from:))
    let dbAlbumGenres = genres.map(AlbumGenres.init(from:))
    let dbAlbumsToGenres = albums.flatMap { album in
        album.genres.map {
            AlbumToGenres(albumId: album.id, genreId: $0.id)
        }
    }
    
    return (dbAlbums, dbAlbumGenres, dbAlbumsToGenres)
}
