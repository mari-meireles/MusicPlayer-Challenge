//
//  RecentSearchesView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import SwiftUI

struct RecentSearchesView: View {
    let songs: [Song]
    let onSongSelection: (Song) -> Void
    let loadNextPageIfNeeded: (Int) -> Void
    let clearRecentSearches: () -> Void

    var body: some View {
        List {
            Section(header: header) {
                songList
                clearRecentSearchesButton
            }
        }.listStyle(.plain)
    }

    // MARK: - Subviews

    private var header: some View {
        Text(Constants.Strings.songRecentSearches)
            .font(Constants.Fonts.title3)
            .foregroundColor(Constants.Colors.primaryText)
            .padding(.horizontal)
    }

    private var songList: some View {
        SongsList(
            songs: songs,
            onSongSelection: onSongSelection,
            loadNextPageIfNeeded: loadNextPageIfNeeded
        )
    }

    private var clearRecentSearchesButton: some View {
        Button(Constants.Strings.songClearRecentSearches) {
            clearRecentSearches()
        }
        .listRowSeparator(.hidden)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .foregroundColor(Constants.Colors.primaryText)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Constants.Colors.primaryText, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Preview

#Preview {
    RecentSearchesView(
        songs: generateMockSongs(count: 10),
        onSongSelection: { _ in },
        loadNextPageIfNeeded: { _ in },
        clearRecentSearches: {}
    )
    .preferredColorScheme(.dark)
}
