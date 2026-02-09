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
    typealias NSViewType = VideoInputNSView
    @Binding var viewModel: VideoInputView.ViewModel

    public init(viewModel: Binding<VideoInputView.ViewModel>) {
        self._viewModel = viewModel
    }

    func makeNSView(context: Context) -> VideoInputNSView {
        let view = VideoInputNSView()
        view.session = viewModel.currentSession
        viewModel.previewLayer = view.previewLayer
        return view
    }

    func updateNSView(_ nsView: VideoInputNSView, context: Context) {
        //nsView.session = viewModel.currentSession
        toggleMirroring(nsView.previewLayer)
    }

    func toggleMirroring(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        guard let previewLayer, let connection = previewLayer.connection, let isMirrored = viewModel.isMirrored else {
            return
        }
        connection.automaticallyAdjustsVideoMirroring = false
        if connection.isVideoMirroringSupported {
            previewLayer.connection?.isVideoMirrored = isMirrored
        }
    }
}
