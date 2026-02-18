//
//  CaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI
import AVFoundation
import AppKit
import AVKit
import Combine
import AppState

struct CaptureView: View {

    @Environment(\.isHoveringWindow) var isHoveringWindow
    @State var viewModel: CaptureView.ViewModel = .init()

    var body: some View {

        NavigationStack  {
            
            ZStack(alignment: .bottom) {
                // MARK: - Placeholder
                CapturePlaceholder(
                    isConnecting: $viewModel.videoInput.isConnecting,
                    hasConnectionTimeout: $viewModel.hasConnectionTimeout,
                    currentDevice: viewModel.videoInput.selectedDevice
                )
                // MARK: - Video preview
                VideoPreview(viewModel: $viewModel.videoInput)
                    .onAppear(perform: viewModel.onVideoLayerAppear)
                // MARK: Crop mask for selected ratio
                MaskAspectRatioView()
                // MARK: Bottom bar content
                BottomBar()
                    .opacity(isHoveringWindow ? 1.0 : 0.0)
            }
            .environment(\.audioDevices, viewModel.audioDevices)
            .environment(\.videoDevices, viewModel.videoDevices)
            .task {
                await viewModel.initialize()
                await viewModel.start()
            }
            // Toolbar
            .toolbar { ToolbarSpacer() }
        }
        // Keep the window resizable but constrained to 16:9.
        .windowAspectRatio(AspectPreset.youtube.ratio)

    }
}
