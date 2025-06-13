//
//  OptionsSheetView.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 10/06/2025.
//
import SwiftUI

struct OptionsSheetView: View {
    let title: String
    let subtitle: String
    let openAction: () async -> ()

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            header
            Spacer()
            openAlbumButton
            Spacer()
        }
        .padding(.horizontal, 30)
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(Constants.Fonts.title2)
                .foregroundColor(Constants.Colors.primaryText)
                .lineLimit(1)
            Text(subtitle)
                .font(Constants.Fonts.subtitle1)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(1)
        }
    }

    private var openAlbumButton: some View {
        Button {
            Task { await openAction() }
        } label: {
            Label(Constants.Strings.openAlbum, image: Constants.Strings.openAlbumIconFile)
                .font(Constants.Fonts.title3)
                .foregroundColor(Constants.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Preview

#Preview {
    OptionsSheetView(
      title: "Something",
      subtitle: "Artist",
      openAction: {}
    )
    .frame(width: UIScreen.main.bounds.width, height: 150)
    .preferredColorScheme(.dark)
}
