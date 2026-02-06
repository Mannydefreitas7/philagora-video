//
//  Capture+Command.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import Foundation
import SwiftUI
import AppState

struct GeneralCommand: Commands {
    @ObservedDependency(\.captureStore) var captureStore: CaptureView.Store

    var body: some Commands {
        CommandGroup(replacing: .newItem) {

            Menu("New...") {
                Button("Screen Recording") {
                    //
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])

                Button("Camera Recording") {
                  //
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }

            Divider()

            Button("Open Video...") {
               //
            }
            .keyboardShortcut("o", modifiers: .command)
        }
    }


}

struct VideoCommand: Commands {
    @ObservedDependency(\.captureStore) var captureStore: CaptureView.Store

    var body: some Commands {
        CommandMenu("Video") {
            Button("Crop") {
               //
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
          //  .disabled(appState.videoURL == nil)

            Button("Trim") {
                //appState.currentTool = .trim
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
       //     .disabled(appState.videoURL == nil)

            Divider()

            Button("Export as GIF...") {
               // appState.showExportSheet = true
               // appState.exportFormat = .gif
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        //    .disabled(appState.videoURL == nil)

            Button("Export as Movie...") {
              //  appState.showExportSheet = true
             //   appState.exportFormat = .movie
            }
            .keyboardShortcut("e", modifiers: .command)
           // .disabled(appState.videoURL == nil)
        }
    }


}
