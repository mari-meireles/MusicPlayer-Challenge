//
//  View.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 09/06/2025.
//
import SwiftUI

extension View {
    func customDetailNavStyle(showOptions: Binding<Bool>) -> some View {
        modifier(DetailNavStyle(showOptions: showOptions))
    }
}
