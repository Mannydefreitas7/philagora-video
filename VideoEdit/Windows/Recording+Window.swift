//
//  EditorWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import SwiftUIIntrospect

struct RecordingWindow: Scene {

    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup(Constants.Window.recording.rawValue, id: .window(.recording)) {

            VECameraCaptureView()
                .introspect(.window, on: .macOS(.v26)) {
                    $0.isMovableByWindowBackground = true
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .windowResizeAnchor(.bottomLeading)
                .ignoresSafeArea(.all)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environmentObject(appState)
            
        }
        
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentMinSize)
    }
}

extension RecordingWindow {

    class ViewModel: ObservableObject {

        @Published var isVisible: Bool = true
        @Published var position: CameraPosition = .topLeft
        @Published var size: CameraSize = .small
        @Published var shape: CameraShape = .circle

    }
}
