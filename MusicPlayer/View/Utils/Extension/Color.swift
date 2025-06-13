//
//  Color.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 08/06/2025.
//
import SwiftUI

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double( rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
