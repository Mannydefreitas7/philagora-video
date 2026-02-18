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

    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds

    @Environment(\.isHoveringWindow) var isHoveringWindow
    @StateObject var store: CaptureView.Store = .init()

    // User preferences to store/restore window parameters
    @Preference(\.aspectPreset) var aspectPreset
    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.showPlatformSafe) var showPlatformSafe

    var body: some View {

        NavigationStack  {
            
            ZStack(alignment: .bottom) {

                CapturePlaceholder(
                    isConnecting: $store.videoInput.isConnecting,
                    hasConnectionTimeout: $store.hasConnectionTimeout,
                    currentDevice: store.videoInput.currentDevice
                )

                VideoPreview(viewModel: $store.videoInput)
                    .onAppear(perform: store.onVideoAppear)

                // MARK: Crop mask for selected ratio
                MaskAspectRatioView()

                // MARK: Bottom bar content
                BottomBar()
                    .opacity(isHoveringWindow ? 1.0 : 0.0)


            }
            .environmentObject(store)
            .environment(\.audioDevices, store.audioDevices)
            .environment(\.videoDevices, store.videoDevices)
            .task {
                await store.initialize()
                await store.start()
            }
            // Toolbar
            .toolbar {
                ToolbarSpacer()
            }
        }
        // Keep the window resizable but constrained to 16:9.
        .windowAspectRatio(AspectPreset.youtube.ratio)

    }
}
