//
//  Image.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 08/06/2025.
//
import SwiftUI

extension Image {
    func songArtworkStyle(size: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
    }
}
