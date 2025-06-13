//
//  Constants.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 08/06/2025.
//
import SwiftUI

enum Constants {
    // MARK: - Colors
    enum Colors {
        static let background = Color.black
        static let primaryText = Color.white
        static let secondaryText = Color(hex: "#737373")
        static let tertiaryText = Color(hex: "#BFBFBF")
    }

    // MARK: - Strings
    enum Strings {
        static let songSearchViewTitle = "Songs"
        static let songSearchViewSearchPlaceholder = "Search"
        static let songSearchViewTip = "Search for a song"
        static let songSearchViewEmpty = "No songs found for"
        static let songRecentSearches = "Recent Searches"
        static let songClearRecentSearches = "clear recent searches"
        static let openAlbum = "Open album"
        static let album = "Album"
        static let alertErrorTitle = "Something went wrong"
        static let alertError = "Please try again later"
        static let ok = "OK"

        static let songIconFile = "SongIcon"
        static let navigationIconFile = "NavigationIcon"
        static let ellipsisIconFile = "EllipsisIcon"
        static let nextIconFile = "NextIcon"
        static let previousIconFile = "PreviousIcon"
        static let playIconFile = "PlayIcon"
        static let pauseIconFile = "PauseIcon"
        static let openAlbumIconFile = "OpenAlbumIcon"

    }

    // MARK: - Fonts
    enum Fonts {
        static let title1 = Font.system(size: Fonts.titleFontSize1)
        static let title2 = Font.system(size: Fonts.titleFontSize2)
        static let title3 = Font.system(size: Fonts.titleFontSize3, weight: .bold)
        static let subtitle1 = Font.system(size: Fonts.subtitleFontSize1)
        static let subtitle2 = Font.system(size: Fonts.subtitleFontSize2)

        private static let titleFontSize1: CGFloat = 24
        private static let titleFontSize2: CGFloat = 18
        private static let titleFontSize3: CGFloat = 16
        private static let subtitleFontSize1: CGFloat = 14
        private static let subtitleFontSize2: CGFloat = 12
    }
}
