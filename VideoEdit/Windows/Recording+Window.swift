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
    @StateObject private var viewModel: ViewModel = .init()

    var body: some Scene {
        WindowGroup(Constants.Window.recording.rawValue, id: .window(.recording)) {
            VECameraCaptureView(captureViewModel: appState.captureViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .windowResizeAnchor(.bottomLeading)
                .ignoresSafeArea(.all)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environmentObject(appState)
                .onDisappear {
                    appState.captureViewModel.onDisappear()
                }
                .task {
                    await appState.captureViewModel.onAppear()
                }
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
