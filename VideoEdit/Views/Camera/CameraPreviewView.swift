import SwiftUI
import AVFoundation

struct CameraPreviewView: NSViewRepresentable {
    var session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = CameraPreviewNSView()
        view.session =  session
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let previewView = nsView as? CameraPreviewNSView else { return }
        previewView.session =  session
    }
}

class CameraPreviewNSView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

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

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds

        self.layer?.addSublayer(layer)
        self.previewLayer = layer
    }
}
