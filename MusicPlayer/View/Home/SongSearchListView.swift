//
//  SongSearchListView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import SwiftUI

struct SongSearchListView: View {
    private let apiClient: APIClientProtocol
    @StateObject private var viewModel: SongSearchViewModel
    @State private var path = NavigationPath()

    init(viewModel: SongSearchViewModel, apiClient: APIClientProtocol) {
        self.apiClient = apiClient
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .scrollDismissesKeyboard(.immediately)
                .navigationDestination(for: Song.self) { song in
                    SongDetailView(viewModel: SongDetailViewModel(song: song, apiClient: apiClient))
                        .onAppear { viewModel.storeRecentSearch(song) }
                }
                .navigationTitle(Constants.Strings.songSearchViewTitle)
                .searchable(
                    text: $viewModel.searchTerm,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Constants.Strings.songSearchViewSearchPlaceholder
                )
                .refreshable { viewModel.refresh() }
                .alert(Constants.Strings.alertErrorTitle, isPresented: $viewModel.showErrorAlert) {
                    Button(Constants.Strings.ok, role: .cancel) { }
                } message: {
                    Text(Constants.Strings.alertError)
                }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            tipLabel
        case .loading:
            loadingView
        case .empty:
            emptyLabel
        case .results(let songs, let isLoadingMore):
            SearchResultSongsView(
                songs: songs,
                isLoading: isLoadingMore,
                onSongSelection: { song in
                    path.append(song)
                },
                loadNextPageIfNeeded: { id in
                    Task { await viewModel.shouldLoadPagination(id: id) }
                }
            )
        case .recent(let songs):
            RecentSearchesView(
                songs: songs,
                onSongSelection: { song in
                    path.append(song)
                },
                loadNextPageIfNeeded: { id in
                    Task { await viewModel.shouldLoadPagination(id: id) }
                },
                clearRecentSearches: {
                    viewModel.clearRecentSearches()
                }

            )
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical)
        .listRowSeparator(.hidden)
    }

    private var tipLabel: some View {
        Text(Constants.Strings.songSearchViewTip)
            .font(Constants.Fonts.title2)
            .foregroundColor(Constants.Colors.primaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
    }

    private var emptyLabel: some View {
        Text("\(Constants.Strings.songSearchViewEmpty) “\(viewModel.searchTerm)“")
            .font(Constants.Fonts.title2)
            .foregroundColor(Constants.Colors.primaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview("Initial State") {
    songSearchListPreview(.idle)
}

#Preview("Empty State") {
    songSearchListPreview(.empty, searchTerm: "abcde")
}

#Preview("Loading") {
    songSearchListPreview(.loading)
}

#Preview("Search Results") {
    songSearchListPreview(.results(
        songs: generateMockSongs(count: 10),
        isLoadingMore: true)
    )
}

#Preview("Recent Searches") {
    songSearchListPreview(.recent(generateMockSongs(count: 5)))
}

@MainActor @ViewBuilder
private func songSearchListPreview(
    _ state: SongSearchViewModel.ViewState,
    searchTerm: String = ""
) -> some View {
    let vm = SongSearchViewModel(preview: state, searchTerm: searchTerm)
    SongSearchListView(viewModel: vm, apiClient: APIClient())
      .preferredColorScheme(.dark)
}
