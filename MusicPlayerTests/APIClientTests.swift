//
//  MusicPlayerTests.swift
//  MusicPlayerTests
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import XCTest
@testable import MusicPlayer

final class APIClientTests: XCTestCase {
    private var client: APIClient!
    private var track: [String : Any]!

    private var trackId = 42
    private var trackName = "My Song"
    private var artistName = "The Artist"
    private var artworkUrl100 = "https://example.com/a.png"
    private var previewUrl = "https://example.com/p.mp3"
    private var collectionName = "The Album"
    private var trackTimeMillis = 123456
    private var collectionId = 7

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        client = APIClient(session: session)
        track = makeTrackDict(
            trackId: trackId,
            trackName: trackName,
            artistName: artistName,
            artworkUrl100: artworkUrl100,
            previewUrl: previewUrl,
            collectionName: collectionName,
            trackTimeMillis: trackTimeMillis,
            collectionId: collectionId
        )
    }

    override func tearDown() {
        client = nil
        track = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testSearchSongsReturnsTracksOn200() async throws {
        let json = try makeSearchResponseData(tracks: [track])
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
              url: request.url!,
              statusCode: 200,
              httpVersion: nil,
              headerFields: nil
            )!
            return (response, json)
        }
        let songs = try await client.searchSongs(term: "anything", offset: 0, limit: 20)

        XCTAssertEqual(songs.count, 1)
        let track = songs[0]
        XCTAssertEqual(track.trackId, trackId)
        XCTAssertEqual(track.trackName, trackName)
        XCTAssertEqual(track.artistName, artistName)
        XCTAssertEqual(track.artworkUrl100, URL(string: artworkUrl100))
        XCTAssertEqual(track.previewUrl, URL(string: previewUrl))
        XCTAssertEqual(track.collectionName, collectionName)
        XCTAssertEqual(track.collectionId, collectionId)
    }

    func testSearchSongsThrowsOnNon200() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
              url: request.url!,
              statusCode: 500,
              httpVersion: nil,
              headerFields: nil
            )!
            return (response, Data())
        }

        do {
            _ = try await client.searchSongs(term: "oops", offset: 0, limit: 20)
            XCTFail("Expected badServerResponse error")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .badServerResponse)
        } catch {
            XCTFail("Expected URLError.badServerResponse, got \(error)")
        }
    }

    func testGetAlbumSongsReturnsMultipleTracksOn200() async throws {
        let track1 = track!
        let track2 = makeTrackDict(
            trackId: trackId + 1,
            trackName: "Another Song",
            artistName: "Another Artist",
            artworkUrl100: artworkUrl100,
            previewUrl: previewUrl,
            collectionName: collectionName,
            trackTimeMillis: trackTimeMillis,
            collectionId: collectionId
        )
        let json = try makeSearchResponseData(tracks: [track1, track2])
        MockURLProtocol.requestHandler = { request in
            // ensure the lookup endpoint was hit
            XCTAssertTrue(request.url?.path.contains("lookup") ?? false)
            let response = HTTPURLResponse(
              url: request.url!,
              statusCode: 200,
              httpVersion: nil,
              headerFields: nil
            )!
            return (response, json)
        }

        let songs = try await client.getAlbumSongs(collectionId: collectionId)
        XCTAssertEqual(songs.count, 2)
        XCTAssertEqual(songs[0].trackId, trackId)
        XCTAssertEqual(songs[0].trackName, trackName)

        XCTAssertEqual(songs[1].trackId, trackId + 1)
        XCTAssertEqual(songs[1].trackName, "Another Song")
    }

    func testGetAlbumSongsThrowsOnBadURL() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.badURL)
        }

        do {
            _ = try await client.getAlbumSongs(collectionId: collectionId)
            XCTFail("Expected badURL error")
        } catch let urlError as URLError {
            XCTAssertEqual(urlError.code, .badURL)
        } catch {
            XCTFail("Expected URLError.badURL, got \(error)")
        }
    }
}
