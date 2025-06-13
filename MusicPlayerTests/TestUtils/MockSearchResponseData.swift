//
//  SearchResponseDataMock.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import Foundation

func makeSearchResponseData(tracks: [[String: Any]]) throws -> Data {
    let payload: [String: Any] = [
        "resultCount": tracks.count,
        "results": tracks
    ]
    return try JSONSerialization.data(withJSONObject: payload, options: [])
}

func makeTrackDict(
    trackId: Int,
    trackName: String,
    artistName: String,
    artworkUrl100: String = "",
    previewUrl: String = "",
    collectionName: String? = nil,
    trackTimeMillis: Int? = nil,
    collectionId: Int? = nil
) -> [String: Any] {
    var dict: [String: Any] = [
        "wrapperType": "track",
        "trackId": trackId,
        "trackName": trackName,
        "artistName": artistName
    ]
    dict["artworkUrl100"] = artworkUrl100
    dict["previewUrl"] = previewUrl
    if let collectionName = collectionName {
        dict["collectionName"] = collectionName
    }
    if let trackTimeMillis = trackTimeMillis {
        dict["trackTimeMillis"] = trackTimeMillis
    }
    if let collectionId = collectionId {
        dict["collectionId"] = collectionId
    }
    return dict
}

