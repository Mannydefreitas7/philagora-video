//
//  VICameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVFoundation
import AppKit
import AVKit
import Combine

struct CameraCaptureView: View {

    @EnvironmentObject var appState: AppState
    @ObservedObject var state: CaptureView.State
    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds
    @Environment(\.isHoveringWindow) var isHoveringWindow

    // User preferences to store/restore window parameters
    @Preference(\.aspectPreset) var aspectPreset
    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.showPlatformSafe) var showPlatformSafe

    var body: some View {

        NavigationStack  {
            ZStack(alignment: .bottom) {
                if state.selectedVideoDevice.isOn {
                    // MARK: Video preview
                    VideoOutput()
                } else {
                    placeholderView()
                }

                // MARK: Crop mask for selected ratio
                MaskAspectRatioView()

                if isHoveringWindow {
                    // MARK: Bottom bar content
                    BottomBar()
                }

            }
            .environmentObject(state)
        }
        // Keep the window resizable but constrained to 16:9.
        .windowAspectRatio(AspectPreset.youtube.ratio)
    }
}


extension CameraCaptureView {

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

#Preview {
    @Previewable @StateObject var captureVM: CaptureView.State = .init()
    CameraCaptureView(state: captureVM)
}

struct CustomCaptureView: NSViewRepresentable {

    var session: AVCaptureSession?

    init(session: AVCaptureSession? = nil) {
        self.session = session
    }

    func makeNSView(context: Context) -> AVCaptureView {
       let view = AVCaptureView()
        view.controlsStyle = .default
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateNSView(_ nsView: AVCaptureView, context: Context) {
        nsView.setSession(session, showVideoPreview: true, showAudioPreview: true)
    }

    class Coordinator: NSObject, AVCaptureViewDelegate {
        func captureView(_ captureView: AVCaptureView, startRecordingTo fileOutput: AVCaptureFileOutput) {
            logger.info("\(captureView.fileOutput?.description ?? "")")
        }


    }
    func makeCoordinator() -> Coordinator { Coordinator() }
}
