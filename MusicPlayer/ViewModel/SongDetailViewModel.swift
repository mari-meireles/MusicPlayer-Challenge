//
//  SongDetailViewModel.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 07/06/2025.
//
import Combine
import AVFoundation

@MainActor
final class SongDetailViewModel: ObservableObject {
    private let apiClient: APIClientProtocol
    private var player: AVPlayer?
    private var endObserver: Any?
    private var timeObserverToken: Any?

    @Published var showingOptionsSheet = false
    @Published var showingAlbumSheet = false
    @Published var showErrorAlert = false
    @Published private(set) var song: Song
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var albumSongs: [Song] = []

    var artworkURL: URL? { song.artworkUrl100 }
    var trackTitle: String { song.trackName }
    var artistName: String { song.artistName }
    var albumName: String { song.collectionName ?? Constants.Strings.album }
    let previewDuration: Double = 30

    init(
        song: Song,
        apiClient: APIClientProtocol,
        isTesting: Bool = false
    ) {
        self.song = song
        self.apiClient = apiClient
        if isTesting {
            self.player = AVPlayer(playerItem: nil)
        } else {
            setUpPlayer()
        }
    }

    func teardownPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
            endObserver = nil
        }
        player?.pause()
        isPlaying = false
        currentTime = 0
    }

    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }

    func openAlbum() async {
        guard let collectionId = song.collectionId else { return }
        do {
            let fetchedSongs = try await Task.detached(priority: .userInitiated) {
                try await self.apiClient.getAlbumSongs(collectionId: collectionId)
            }.value
            albumSongs = fetchedSongs
            showingOptionsSheet = false
            showingAlbumSheet = true
        } catch {
            handleError(error)
        }
    }

    func updateSong(to newSong: Song) {
        teardownPlayer()
        song = newSong
        setUpPlayer()
    }

    private func setUpPlayer() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            handleError(error)
        }
        guard let url = song.previewUrl else { return }
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        player = p

        let interval = CMTime(seconds: 0.5, preferredTimescale: .init(NSEC_PER_SEC))

        timeObserverToken = p.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            p.seek(to: .zero)
            Task { @MainActor in
                self?.isPlaying = false
            }
        }
    }

    func handleError(_ error: Error) {
        print("🛠️ Error: \(error.localizedDescription)")
        showErrorAlert = true
    }
}

extension SongDetailViewModel {
    #if DEBUG
    convenience init(_ song: Song, apiClient: APIClientProtocol) {
        self.init(song: song, apiClient: apiClient, isTesting: true)
    }
    #endif
}
