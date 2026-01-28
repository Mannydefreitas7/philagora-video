//
//  VideoOutputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-24.
//
import AVFoundation
import SwiftUI
import Combine

struct VideoOutputView: NSViewRepresentable {
    typealias NSViewType = PlayerView
    private let source: PreviewSource
    private var captureSession: AVCaptureSession

    @Preference(\.isMirrored) private var isMirror

    init(source: PreviewSource, captureSession: AVCaptureSession) {
        self.source = source
        self.captureSession = captureSession
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
}

extension VideoOutputView {

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
