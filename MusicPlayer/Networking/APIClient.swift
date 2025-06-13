//
//  APIClient.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import Foundation

public protocol APIClientProtocol: Sendable {
    func searchSongs(term: String, offset: Int, limit: Int) async throws -> [Song]
    func getAlbumSongs(collectionId: Int) async throws -> [Song]
}

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchSongs(term: String, offset: Int, limit: Int) async throws -> [Song] {
        guard let request = ITunesEndpoint.searchSongs(query: term, offset: offset, limit: limit).urlRequest else {
            throw URLError(.badURL)
        }
        return try await fetchSongs(from: request)
    }

    func getAlbumSongs(collectionId: Int) async throws -> [Song] {
        guard let request = ITunesEndpoint.getAlbumSongs(collectionId: collectionId).urlRequest else {
            throw URLError(.badURL)
        }
        return try await fetchSongs(from: request)
    }

    private func fetchSongs(from request: URLRequest) async throws -> [Song] {
        let (data, response) = try await session.data(for: request)
        try validate(response: response)

        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.results.compactMap { result in
            if case .song(let song) = result { return song }
            else { return nil }
        }
    }

    private func validate(response: URLResponse) throws {
        if (response as? HTTPURLResponse)?.statusCode != 200 {
          throw URLError(.badServerResponse)
        }
    }
}
