//
//  MockData.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 10/06/2025.
//
import Foundation

func generateMockSongs(count: Int) -> [Song] {
    (1...count).map { i in
        Song(
            trackId: i,
            trackName: "Track \(i)",
            artistName: "Artist \(i)",
            artworkUrl100: URL(string: "https://via.placeholder.com/100"),
            previewUrl: URL(string: "https://example.com/preview\(i).m4a"),
            collectionName: "Album \( (i % 5) + 1 )",
            collectionId: (i % 5) + 1
        )
    }
}
