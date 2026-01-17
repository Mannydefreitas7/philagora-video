//
//  General+Command.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-16.
//

import Foundation
import SwiftUI

struct GeneralCommand: Commands {

    @ObservedObject var appState: AppState

    var body: some Commands {
        CommandGroup(replacing: .newItem) {

            Menu("New...") {
                Button("Screen Recording") {
                    appState.showRecordingSheet = true
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])

                Button("Camera Recording") {
                    appState.showRecordingSheet = true
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            Divider()

            Button("Open Video...") {
                appState.openFile()
            }
            .keyboardShortcut("o", modifiers: .command)

        }
    }


}
