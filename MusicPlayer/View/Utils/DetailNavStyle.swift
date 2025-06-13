//
//  DetailNavStyle.swift
//  MusicPlayer
//
//  Created by Mariana Ribeiro Meireles on 09/06/2025.
//
import SwiftUI

struct DetailNavStyle: ViewModifier {
    @Binding var showOptions: Bool
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(Constants.Strings.navigationIconFile)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showOptions = true
                    } label: {
                        Image(Constants.Strings.ellipsisIconFile)
                    }
                }
            }
    }
}
