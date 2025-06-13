//
//  SongDetailView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 09/06/2025.
//
import AVFoundation
import SwiftUI

struct SongDetailView: View {
    let artworkSize: CGFloat = 200
    @StateObject private var viewModel: SongDetailViewModel

    init(viewModel: SongDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack() {
            Spacer()
            artwork
            Spacer()
            bottomBar
        }
        .onDisappear { viewModel.teardownPlayer() }
        .customDetailNavStyle(showOptions: $viewModel.showingOptionsSheet)
        .sheet(isPresented: $viewModel.showingOptionsSheet) {
            optionsSheetView
        }
        .sheet(isPresented: $viewModel.showingAlbumSheet) {
            albumSheetView
        }
        .alert(Constants.Strings.alertErrorTitle, isPresented: $viewModel.showErrorAlert) {
            Button(Constants.Strings.ok, role: .cancel) { }
        } message: {
            Text(Constants.Strings.alertError)
        }
    }

    // MARK: - Subviews

    private var artwork: some View {
        ZStack {
            AsyncImage(url: viewModel.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image.songArtworkStyle(size: artworkSize)
                default:
                    Image(Constants.Strings.songIconFile).songArtworkStyle(size: artworkSize)
                }
            }
        }
        .cornerRadius(25)
    }

    private var bottomBar: some View {
        VStack {
            VStack(alignment: .leading) {
                credits
                progressBar
            }
            .padding(.horizontal)
            playbackControls
        }
    }

    private var credits: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.trackTitle)
                .font(Constants.Fonts.title1)
                .foregroundColor(Constants.Colors.primaryText)
                .lineLimit(1)
            Text(viewModel.artistName)
                .font(Constants.Fonts.subtitle1)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(1)
        }
    }

    private var progressBar: some View {
        VStack {
            slider
            timeline
        }
    }

    private var slider: some View {
        Slider(
            value: Binding(
            get: { viewModel.currentTime },
            set: { newValue in viewModel.seek(to: newValue) }
            ),
            in: 0...viewModel.previewDuration
        )
        .tint(.white)
        .onAppear {
            let progressCircleConfig = UIImage.SymbolConfiguration(scale: .small)
            UISlider.appearance()
                .setThumbImage(UIImage(systemName: "circle.fill", withConfiguration: progressCircleConfig), for: .normal)
        }
    }

    private var timeline: some View {
        let remainTime = viewModel.previewDuration - viewModel.currentTime
        return HStack {
            Text(timeString(viewModel.currentTime))
                .font(Constants.Fonts.subtitle1)
                .foregroundColor(Constants.Colors.tertiaryText)
            Spacer()
            Text("-" + timeString(max(remainTime, 0)))
                .font(Constants.Fonts.subtitle1)
                .foregroundColor(Constants.Colors.tertiaryText)
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 60) {
            previousButton
            playButton
            nextButton
        }
    }

    private var previousButton: some View {
        Button {
            // previous action
        } label: {
            Image(Constants.Strings.previousIconFile)
        }
    }

    private var nextButton: some View {
        Button {
            // next action
        } label: {
            Image(Constants.Strings.nextIconFile)
        }
    }

    private var playButton: some View {
        Button { viewModel.togglePlayPause() }
        label: {
            Image(viewModel.isPlaying ? Constants.Strings.pauseIconFile : Constants.Strings.playIconFile)
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }

    private var optionsSheetView: some View {
        OptionsSheetView(
            title: viewModel.trackTitle,
            subtitle: viewModel.artistName,
            openAction: {
                await viewModel.openAlbum()
            }
        )
    }

    private var albumSheetView: some View {
        AlbumSheetView(
            title: viewModel.albumName,
            songs: viewModel.albumSongs,
            onSongSelection: { song in
                viewModel.updateSong(to: song)
                viewModel.showingAlbumSheet = false
            }
        )
    }
}

// MARK: - Preview

#Preview {
    SongDetailView(
        viewModel:
            SongDetailViewModel(
                song: Song(
                    trackId: 789,
                    trackName: "Song Title",
                    artistName: "Artist name",
                    artworkUrl100: URL(string: "https://")!,
                    previewUrl: URL(string: "https://")!,
                    collectionName: "Album Title",
                    collectionId: 456
                ),
                apiClient: APIClient()
            )
    )
    .preferredColorScheme(.dark)
}
