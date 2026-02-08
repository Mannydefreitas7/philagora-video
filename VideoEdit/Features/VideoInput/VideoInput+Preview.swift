//
//  VideoInut+Preview.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//

import AVFoundation
import SwiftUI
import Combine

struct VideoPreview: NSViewRepresentable {
    typealias NSViewType = VideoPreviewView
    let session: AVCaptureSession
    @Binding var isMirrored: Bool?

    public class VideoPreviewView: NSView {
        var previewLayer: AVCaptureVideoPreviewLayer? {
            layer as? AVCaptureVideoPreviewLayer
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        override func makeBackingLayer() -> CALayer {
            AVCaptureVideoPreviewLayer()
        }

        override func layout() {
            super.layout()
            previewLayer?.frame = bounds
            layer = previewLayer
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    public init(session: AVCaptureSession, isMirrored: Binding<Bool?>) {
        self.session = session
        self._isMirrored = isMirrored
    }

    func makeNSView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.frame = .zero
        view.previewLayer?.session = session
        view.previewLayer?.videoGravity = .resizeAspectFill
        toggleMirroring(view.previewLayer)
        return view
    }
    
    func updateNSView(_ nsView: VideoPreviewView, context: Context) {
        nsView.previewLayer?.videoGravity = .resizeAspectFill
        nsView.previewLayer?.frame = nsView.bounds
        toggleMirroring(nsView.previewLayer)
    }

    func toggleMirroring(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        guard let previewLayer, let connection = previewLayer.connection, let isMirrored else {
            return
        }
        connection.automaticallyAdjustsVideoMirroring = false
        if connection.isVideoMirroringSupported {
            previewLayer.connection?.isVideoMirrored = isMirrored
        }
    }
}
