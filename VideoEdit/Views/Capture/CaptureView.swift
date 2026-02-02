//
//  CaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//

import SwiftUI

struct CaptureView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        CameraCaptureView(state: appState.captureState)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .windowResizeAnchor(.bottomLeading)
            .ignoresSafeArea(.all)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            .toolbar {
                ToolbarSpacer()
            }
            .onDisappear {
                Task {
                    await appState.endCapture()
                }
            }
            .task {
                await appState.startCapture()
            }
            .windowDismissBehavior(.enabled)
    }
}

#Preview {
    CaptureView()
}
