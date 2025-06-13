//
//  SongSearchViewModel.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import Foundation
import Combine

extension SongSearchViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case results(songs: [Song], isLoadingMore: Bool)
        case recent([Song])
        case empty
    }

    enum Defaults {
        static let recentKey = "recentSearches"
    }
}

@MainActor
final class SongSearchViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var showErrorAlert = false
    @Published private(set) var state: ViewState = .idle

    private var searchResults: [Song] = []
    private var recentSearches: [Song] = []
    private var hasMorePages: Bool = false
    private var offset = 0
    private var subscriptions = Set<AnyCancellable>()
    private let client: APIClientProtocol
    private let defaults: UserDefaults
    private let recentSearchesLimit = 15
    private let searchResultsPageLimit = 30

    init(client: APIClientProtocol, defaults: UserDefaults = .standard, isPreview: Bool = false) {
        self.client = client
        self.defaults = defaults
        self.recentSearches = loadRecentSearches()
        if !isPreview {
            bindSearchTerm()
        }
    }

    func shouldLoadPagination(id: Int) async {
        if id == searchResults.last?.id && hasMorePages {
            await loadNextPage()
        }
    }

    func refresh() {
        if recentSearches.isEmpty {
            state = .idle
        } else {
            state = .recent(recentSearches)
        }
        offset = 0
        hasMorePages = false
    }

    func storeRecentSearch(_ song: Song) {
        recentSearches.removeAll { $0.id == song.id }
        recentSearches.insert(song, at: 0)
        if recentSearches.count > recentSearchesLimit {
            recentSearches.removeLast(recentSearches.count - 10)
        }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        defaults.removeObject(forKey: Defaults.recentKey)
        state = .idle
    }

    private func bindSearchTerm() {
        $searchTerm
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] term in
                if term.isEmpty {
                    self?.refresh()
                } else {
                    Task {
                        await self?.startNewSearch(term: term)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func loadNextPage() async {
        guard state != .loading else { return }
        state = searchResults.isEmpty ? .loading : .results(songs: searchResults, isLoadingMore: true)

        let client = self.client
        let term = self.searchTerm
        let page = self.offset
        let limit = self.searchResultsPageLimit

        do {
            let newSongs = try await Task.detached(priority: .userInitiated) {
                try await client.searchSongs(term: term, offset: page, limit: limit)
            }.value
            searchResults.append(contentsOf: newSongs)
            offset = searchResults.count
            hasMorePages = !newSongs.isEmpty
            let emptyResults = newSongs.isEmpty && searchResults.isEmpty
            state = emptyResults ? .empty : .results(songs: searchResults, isLoadingMore: false)
        } catch {
            state = .empty
            handleError(error)
        }
    }

    private func startNewSearch(term: String) async {
        guard !term.isEmpty else { return }

        offset = 0
        searchResults = []
        hasMorePages = true
        await loadNextPage()
    }

    // MARK: – UserDefaults Persistence

    private func saveRecentSearches() {
        do {
            let data = try JSONEncoder().encode(recentSearches)
            defaults.set(data, forKey: Defaults.recentKey)
        } catch {
            handleError(error, showAlert: false)
        }
    }

    private func loadRecentSearches() -> [Song] {
        guard let data = defaults.data(forKey: Defaults.recentKey) else { return [] }
        do {
            return try JSONDecoder().decode([Song].self, from: data)
        } catch {
            handleError(error, showAlert: false)
            return []
        }
    }

    func handleError(_ error: Error, showAlert: Bool = true) {
        print("🛠️ Error: \(error.localizedDescription)")
        showErrorAlert = showAlert
    }
}

//For Previews
extension SongSearchViewModel {
    #if DEBUG
    convenience init(preview state: ViewState, searchTerm: String = "") {
        self.init(client: APIClient(), defaults: .standard, isPreview: true)
        self.state = state
        self.searchTerm = searchTerm
    }
    #endif
}
