//
//  SongSearchViewModelTests.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import XCTest
@testable import MusicPlayer

@MainActor
final class SongSearchViewModelTests: XCTestCase {
    private var viewModel: SongSearchViewModel!
    private var client: MockAPIClient!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)

        client = MockAPIClient()
        viewModel = SongSearchViewModel(client: client, defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: #file)
        super.tearDown()
    }

    func testInitialStateIsIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testSearchSuccessTransitionsToResults() async {
        let songs = generateMockSongs(count: 5)
        client.searchSongsToReturn = songs

        viewModel.searchTerm = "query"
        // debounce delay simulated
        try? await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertEqual(viewModel.state, .results(songs: songs, isLoadingMore: false))
    }

    func testSearchEmptyResultsTransitionsToEmpty() async {
        client.searchSongsToReturn = []

        viewModel.searchTerm = "nope"
        // debounce delay simulated
        try? await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testErrorDuringSearchShowsAlertAndIdle() async {
        client.shouldThrow = true
        client.thrownError = URLError(.notConnectedToInternet)

        viewModel.searchTerm = "fail"
        // debounce delay simulated
        try? await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testShouldLoadPaginationDoesNothingWhenNotLastID() async {
        let firstPage = [generateMockSongs(count: 1).first!]
        client.searchSongsToReturn = firstPage
        viewModel.searchTerm = "abc"
        try? await Task.sleep(nanoseconds: 600_000_000)

        let oldState = viewModel.state
        await viewModel.shouldLoadPagination(id: 999)
        XCTAssertEqual(viewModel.state, oldState)
    }


    func testShouldLoadPagination_AppendsNewPage_WhenLastIDAndHasMorePages() async {
        let all = generateMockSongs(count: 2)
        let firstPage = [all[0]]
        let secondPage = [all[1]]

        client.searchSongsToReturn = firstPage
        viewModel.searchTerm = "page1"
        try? await Task.sleep(nanoseconds: 600_000_000)

        let lastID = firstPage[0].id

        client.searchSongsToReturn = secondPage

        await viewModel.shouldLoadPagination(id: lastID)

        guard case .results(let songs, let isLoadingMore) = viewModel.state else {
            return XCTFail("Expected .results after pagination")
        }
        XCTAssertEqual(songs, firstPage + secondPage)
        XCTAssertFalse(isLoadingMore)
    }

    func testRefreshNoRecentsSetsIdle() {
        viewModel.refresh()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testRefreshWithRecentsSetsRecentWithSameOrder() {
        let songs = generateMockSongs(count: 3)
        songs.forEach { viewModel.storeRecentSearch($0) }

        viewModel.refresh()

        guard case .recent(let recents) = viewModel.state else {
            return XCTFail("Expected .recent state after refresh() when recents exist")
        }
        XCTAssertEqual(recents, songs.reversed())
    }

    func testStoreRecentSearchPersists() {
        let song = generateMockSongs(count: 1).first!
        viewModel.storeRecentSearch(song)

        let data = defaults.data(forKey: SongSearchViewModel.Defaults.recentKey)!
        let decoded = try? JSONDecoder().decode([Song].self, from: data)
        XCTAssertEqual(decoded, [song])
    }

    func testClearRecentSearchesRemovesFromMemoryAndUserDefaults() {
        let song = generateMockSongs(count: 1).first!
        viewModel.storeRecentSearch(song)

        XCTAssertNotNil(defaults.data(forKey: SongSearchViewModel.Defaults.recentKey))

        viewModel.clearRecentSearches()

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(defaults.data(forKey: SongSearchViewModel.Defaults.recentKey))
    }
}
