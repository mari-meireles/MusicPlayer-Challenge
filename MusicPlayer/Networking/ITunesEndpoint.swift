//
//  ITunesEndpoint.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import Foundation

enum ITunesEndpoint {
    static let baseURL = "https://itunes.apple.com"

    case searchSongs(query: String, offset: Int, limit: Int)
    case getAlbumSongs(collectionId: Int)

    var urlRequest: URLRequest? {
        switch self {
        case let .searchSongs(query, offset, limit):
            var components = URLComponents(string: ITunesEndpoint.baseURL + "/search")
            components?.queryItems = [
                URLQueryItem(name: "term", value: query),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            guard let url = components?.url else { return nil }
            return URLRequest(url: url)

        case let .getAlbumSongs(collectionId):
            var components = URLComponents(string: ITunesEndpoint.baseURL + "/lookup")
            components?.queryItems = [
                URLQueryItem(name: "id", value: "\(collectionId)"),
                URLQueryItem(name: "entity", value: "song")
            ]
            guard let url = components?.url else { return nil }
            return URLRequest(url: url)
        }
    }
}
