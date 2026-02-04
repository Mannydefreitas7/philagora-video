//
//  Capture+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

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
        VideoOutputView(source: state.engine.previewSource, captureSession: state.engine.captureSession)
            .ignoresSafeArea(.all)
    }

    @ViewBuilder
    func BottomBar() -> some View {

            RecordingControlsView(viewModel: state.controlsBarViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, .small)
                .environment(\.audioInputWave, state.audioLevel)
                .environment(\.audioDevices, state.audioDevices)
                .environment(\.videoDevices, state.videoDevices)
                .environmentObject(appState.previewState)
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
        Text(state.recordingTimeString)
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(state.isRecording ? .red : .secondary)
    }

}

extension CaptureView {
    static let sceneName: String = "Capture"
}
