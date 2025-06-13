//
//  SongDetailViewModelTests.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import XCTest
@testable import MusicPlayer

@MainActor
final class SongDetailViewModelTests: XCTestCase {
    private var viewModel: SongDetailViewModel!
    private var client: MockAPIClient!
    private var sampleSong: Song!

    override func setUp() {
        super.setUp()
        sampleSong = generateMockSongs(count: 1).first!
        client = MockAPIClient()
        viewModel = SongDetailViewModel(sampleSong, apiClient: client)
    }

    override func tearDown() {
        sampleSong = nil
        viewModel = nil
        client = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertFalse(viewModel.showingAlbumSheet)
        XCTAssertEqual(viewModel.albumSongs, [])
        XCTAssertEqual(viewModel.song, sampleSong)
    }

    func testTogglePlayPause() {
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        viewModel.togglePlayPause()
        XCTAssertFalse(viewModel.isPlaying)
    }

    func testOpenAlbumSuccessShowsSheet() async {
        let albumSongs = generateMockSongs(count: 10)
        client.albumSongsToReturn = albumSongs

        await viewModel.openAlbum()

        XCTAssertEqual(viewModel.albumSongs, albumSongs)
        XCTAssertTrue(viewModel.showingAlbumSheet)
        XCTAssertFalse(viewModel.showingOptionsSheet)
    }

    func testOpenAlbumFailureShowsErrorAlert() async {
        client.shouldThrow = true
        viewModel.showErrorAlert = false

        await viewModel.openAlbum()

        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertFalse(viewModel.showingAlbumSheet)
    }
}
