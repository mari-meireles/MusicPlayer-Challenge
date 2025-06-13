//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import SwiftUI

@main
struct MusicPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            let apiClient = APIClient()
            let viewModel = SongSearchViewModel(client: apiClient)
            SongSearchListView(viewModel: viewModel, apiClient: apiClient)
                .preferredColorScheme(.dark)
        }
    }
}
