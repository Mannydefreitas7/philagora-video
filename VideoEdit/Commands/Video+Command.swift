//
//  Video+Command.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-16.
//


import Foundation
import SwiftUI

struct VideoCommand: Commands {

    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandMenu("Video") {
            Button("Crop") {
                appState.currentTool = .crop
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .disabled(appState.videoURL == nil)

            Button("Trim") {
                appState.currentTool = .trim
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
            .disabled(appState.videoURL == nil)

            Divider()

            Button("Export as GIF...") {
                appState.showExportSheet = true
                appState.exportFormat = .gif
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(appState.videoURL == nil)

            Button("Export as Movie...") {
                appState.showExportSheet = true
                appState.exportFormat = .movie
            }
            .keyboardShortcut("e", modifiers: .command)
            .disabled(appState.videoURL == nil)
        }
    }


}
