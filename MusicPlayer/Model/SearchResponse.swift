//
//  SearchResponse.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import Foundation

struct SearchResponse: Decodable {
    let resultCount: Int
    let results: [ResultType]
}

public struct Song: Identifiable, Codable, Hashable, Sendable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: URL?
    let previewUrl: URL?
    let collectionName: String?
    let collectionId: Int?

    public var id: Int { trackId }
}

struct Collection: Decodable {
    let collectionId: Int
    let collectionName: String
}

enum ResultType: Decodable {
    case song(Song)
    case collection(Collection)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wrapperType = try container.decode(String.self, forKey: .wrapperType)

        switch wrapperType {
        case "track":
            let song = try Song(from: decoder)
            self = .song(song)

        case "collection":
            let collection = try Collection(from: decoder)
            self = .collection(collection)

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .wrapperType,
                in: container,
                debugDescription: "Unsupported wrapper type: \(wrapperType)"
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case wrapperType
    }
}
