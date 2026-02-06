//
//  EditorWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import SwiftUIIntrospect

struct RecordingWindow: Scene {

    @EnvironmentObject var appState: IAppState

    var body: some Scene {
        WindowGroup(Constants.Window.recording.rawValue, id: .window(.recording)) {
            CaptureView()
                .frame(minWidth: .minWindowWidth, minHeight: .minWindowHeight)
                .isHovering()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: .defaultRecordWidth, height: .defaultRecordHeight)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
    }
}
