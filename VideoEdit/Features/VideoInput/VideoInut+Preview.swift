//
//  VideoInut+Preview.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//

import AVFoundation
import SwiftUI
import Combine

struct VideoInputPreview: NSViewRepresentable {
    typealias NSViewType = PlayerView

    @Binding var viewModel: VideoInputView.ViewModel
    
    private var dbags = [AnyCancellable]()
    private let source: PreviewSource

    @Preference(\.isMirrored) private var isMirror


    init(source: PreviewSource) {
        self.source = source
    }

    func makeNSView(context: Context) -> PlayerView {
        let player = PlayerView()
        source.connect(to: player)
        return player
    }

    func updateNSView(_ nsView: PlayerView, context: Context) {

        let previewLayer = nsView.previewLayer
        guard let connection = previewLayer.connection else { return }

        DispatchQueue.main.async {
            connection.automaticallyAdjustsVideoMirroring = false
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = isMirror
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.videoGravity = .resizeAspectFill

            // This ensures the layer resizes automatically with the view
        view.layer?.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
            // Sync the layer frame to the view's current bounds
        context.coordinator.previewLayer?.frame = nsView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: self.$viewModel)
    }

    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {

        @Binding var viewModel: VideoInputView.ViewModel
        var previewLayer: AVCaptureVideoPreviewLayer?

        init(viewModel: Binding<VideoInputView.ViewModel>) {
            self._viewModel = viewModel
        }

            // Required delegate method
        func fileOutput(
            _ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
                guard error != nil else {
                    Task { @MainActor in
                        viewModel.sessionError = .outputFileNotFound(url: outputFileURL, reason: "")
                    }
                    return
                }
                print("Successfully saved to: \(outputFileURL.path)")
                Task { @MainActor in
                    viewModel.isRecording = false
                    viewModel.url = outputFileURL
                }
            }

            // Optional: UI sync method
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
            print("Recording started!")
            Task { @MainActor in
                viewModel.isRecording = true
                viewModel.url = fileURL
            }
        }
    }
}

extension VideoInputPreview {

    class PlayerView: NSView, PreviewTarget {
        var previewLayer: AVCaptureVideoPreviewLayer = .init()
        private var dbags = [AnyCancellable]()

        init() {
            super.init(frame: .zero)
            setupLayer()
        }

            // Use `AVCaptureVideoPreviewLayer` as the view's backing layer.
        class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        func setupLayer() {
            previewLayer.frame = self.frame
            previewLayer.isDeferredStartEnabled = true
            previewLayer.contentsGravity = .resizeAspectFill
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.automaticallyAdjustsVideoMirroring = true
                // previewLayer.connection?.audioChannels
            layer = previewLayer
        }

        nonisolated func setSession(_ session: AVCaptureSession) {
                // Connects the session with the preview layer, which allows the layer
                // to provide a live view of the captured content.
            Task { @MainActor in
                previewLayer.session = session
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
