//
//  VideoInput+NSView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-08.
//

import SwiftUI
import AVFoundation

class VideoInputNSView: NSView {
    var previewLayer: AVCaptureVideoPreviewLayer?

    var session: AVCaptureSession? {
        didSet {
            setupPreviewLayer()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }


    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }

    private func setupPreviewLayer() {
        previewLayer?.removeFromSuperlayer()

        guard let session = session else { return }

        let layer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds

        self.layer?.addSublayer(layer)
        self.previewLayer = layer
    }
}
