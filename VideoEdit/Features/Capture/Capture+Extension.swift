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
                "Not available",
                systemSymbol: .videoSlashCircleFill,
                description: Text("Select a device from the menu below.")
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
       CaptureVideoPreview(store: captureStore)
      //  VideoOutputView(source: state.engine.previewSource, captureSession: state.engine.captureSession)
            .ignoresSafeArea(.all)
    }

    @ViewBuilder
    func BottomBar() -> some View {

            RecordingControlsView(viewModel: captureStore.controlsBarViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
                .environment(\.audioInputWave, captureStore.audioLevel)
                .environment(\.audioDevices, mainStore.microphones)
                .environment(\.videoDevices, mainStore.cameras)
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
            .foregroundStyle(captureStore.isRecording ? .red : .secondary)
    }

}

extension CaptureView {
     let sceneName: String = "capture"
     let windowID: UUID = UUID()
}
