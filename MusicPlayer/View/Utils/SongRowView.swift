//
//  SongRowView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import SwiftUI

struct SongRowView: View {
    let artworkSize: CGFloat = 44
    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            artworkView
            infoView
            Spacer()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var artworkView: some View {
        if let url = song.artworkUrl100 {
            artworkImage(url: url)
        } else {
            placeholderIcon
        }
    }

    private func artworkImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty, .failure:
                placeholderIcon
            case .success(let image):
                image.songArtworkStyle(size: artworkSize)
            @unknown default:
                placeholderIcon
            }
        }
        .cornerRadius(8)
    }

    private var placeholderIcon: some View {
        Image(Constants.Strings.songIconFile).songArtworkStyle(size: artworkSize)
    }

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.trackName)
                .font(Constants.Fonts.title3)
                .foregroundColor(Constants.Colors.primaryText)
                .lineLimit(1)
            Text(song.artistName)
                .font(Constants.Fonts.subtitle2)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    SongRowView(song: Song(
        trackId: 789,
        trackName: "Song Title",
        artistName: "Artist name",
        artworkUrl100: URL(string: "https://")!,
        previewUrl: URL(string: "https://")!,
        collectionName: "Album Title",
        collectionId: 456
    ))
    .preferredColorScheme(.dark)
}
