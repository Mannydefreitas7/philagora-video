//
//  Capture+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import SwiftUI

extension CaptureView {

    @ViewBuilder
    func placeholderView() -> some View {
        VStack {
            ContentUnavailableView(
                .notAvailableTitle,
                systemSymbol: .videoSlashCircleFill,
                description: Text(verbatim: .notAvailbleDescription)
            )
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.movingParts.wipe(
            angle: .degrees(-45),
            blurRadius: 50
        ))
    }

    @ViewBuilder
    func VideoOutput() -> some View {
       CaptureVideoPreview(store: store)
      //  VideoOutputView(source: state.engine.previewSource, captureSession: state.engine.captureSession)
            .ignoresSafeArea(.all)
    }

    @ViewBuilder
    func BottomBar() -> some View {

        RecordingToolbar()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
    }

    @ViewBuilder
    func MaskAspectRatioView() -> some View {
        MaskRatioOverlay(
            aspectPreset: aspectPreset,
            showGuides: showSafeGuides,
            showMask: showAspectMask,
            showPlatformSafe: showPlatformSafe
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    func timeLabel() -> some View {
        Text("")
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(store.isRecording ? .red : .secondary)
    }

}

extension CaptureWindow {
    var sceneName: String { "capture" }
    var windowID: UUID { .init() }
}
