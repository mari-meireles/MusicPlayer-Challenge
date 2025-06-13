//
//  SongsList.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 12/06/2025.
//
import SwiftUI

struct SongsList: View {
    var songs: [Song]
    let onSongSelection: (Song) -> Void
    let loadNextPageIfNeeded: (Int) -> Void

    var body: some View {
        ForEach(songs) { song in
            SongRowView(song: song)
                .listRowSeparator(.hidden)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSongSelection(song)
                }
                .task {
                    if song.id == songs.last?.id {
                        loadNextPageIfNeeded(song.id)
                    }
                }
        }
      }
}

// MARK: - Preview

#Preview {
    List {
        SongsList(
            songs: generateMockSongs(count: 10),
            onSongSelection: { _ in },
            loadNextPageIfNeeded: { _ in }
        )
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}
