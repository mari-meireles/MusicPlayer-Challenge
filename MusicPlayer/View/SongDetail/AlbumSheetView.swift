//
//  AlbumSheetView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 10/06/2025.
//
import SwiftUI

struct AlbumSheetView: View {
    let title: String
    var songs: [Song]
    let onSongSelection: (Song) -> Void

    var body: some View {
        List {
            Section(header: titleView) {
                songsView
            }
        }
        .listStyle(.plain)
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var titleView: some View {
        Text(title)
            .font(Constants.Fonts.title3)
            .foregroundColor(Constants.Colors.primaryText)
            .lineLimit(1)
            .frame( maxWidth: .infinity, alignment: .center)
            .frame(height: 50)
            .padding(.horizontal)
    }

    private var songsView: some View {
        ForEach(songs) { song in
            SongRowView(song: song)
                .listRowSeparator(.hidden)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSongSelection(song)
                }
        }
    }
}

// MARK: - Preview

#Preview {
    AlbumSheetView(
        title: "Album Name",
        songs: generateMockSongs(count: 10),
        onSongSelection: { _ in }
    )
    .preferredColorScheme(.dark)
}
