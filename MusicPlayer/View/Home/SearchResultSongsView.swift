//
//  SearchResultSongsView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import SwiftUI

struct SearchResultSongsView: View {
    let songs: [Song]
    let isLoading: Bool
    let onSongSelection: (Song) -> Void
    let loadNextPageIfNeeded: (Int) -> Void

    var body: some View {
        List {
            songList
            if isLoading {
                loadingView
            }
        }.listStyle(.plain)
    }

    // MARK: - Subviews

    private var songList: some View {
        SongsList(
            songs: songs,
            onSongSelection: onSongSelection,
            loadNextPageIfNeeded: loadNextPageIfNeeded
        )
    }

    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .id("footer-\(songs.count)")
    }
}

// MARK: - Preview
#Preview {
    SearchResultSongsView(
        songs: generateMockSongs(count: 10),
        isLoading: true,
        onSongSelection: { _ in },
        loadNextPageIfNeeded: { _ in }
    )
    .preferredColorScheme(.dark)
}
