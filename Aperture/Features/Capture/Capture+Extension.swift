//
//  Capture+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import SwiftUI

extension CaptureView {

    @ViewBuilder
    func BottomBar() -> some View {
        RecordingToolbar()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
    }

    @ViewBuilder
    func MaskAspectRatioView() -> some View {
        MaskRatioOverlay(
            aspectPreset: viewModel.aspectPreset,
            showGuides: viewModel.showSafeGuides,
            showMask: viewModel.showAspectMask,
            showPlatformSafe: viewModel.showPlatformSafe
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    func timeLabel() -> some View {
        Text("")
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(viewModel.isRecording ? .red : .secondary)
    }

}

extension CapturePlaceholder {

    @ViewBuilder
    func PlaceholderView() -> some View {
        VStack {
            Image("video-placeholder")
                .renderingMode(.template)
                .tint(.primary)
                .opacity(0.3)
            Text(.noDeviceConnected)
                .opacity(0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

extension CaptureWindow {
    var sceneName: String { "capture" }
    var windowID: UUID { .init() }
}
