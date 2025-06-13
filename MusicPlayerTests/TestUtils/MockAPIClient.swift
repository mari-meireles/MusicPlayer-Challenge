//
//  MockAPIClient.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import Foundation
import MusicPlayer

final class MockAPIClient: APIClientProtocol {
    var searchSongsToReturn: [Song] = []
    var albumSongsToReturn: [Song] = []
    var shouldThrow = false
    var thrownError: Error = URLError(.badServerResponse)

    func searchSongs(term: String, offset: Int, limit: Int) async throws -> [Song] {
        if shouldThrow { throw thrownError }
        return searchSongsToReturn
    }

    func getAlbumSongs(collectionId: Int) async throws -> [Song] {
        if shouldThrow { throw thrownError }
        return albumSongsToReturn
    }
}
