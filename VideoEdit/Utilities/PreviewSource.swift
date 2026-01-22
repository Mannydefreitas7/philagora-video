//
//  PreviewSource.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-21.
//
import SwiftUI
@preconcurrency import AVFoundation


/// A protocol that enables a preview source to connect to a preview target.
///
/// The app provides an instance of this type to the client tier so it can connect
/// the capture session to the `PreviewView` view. It uses these protocols
/// to prevent explicitly exposing the capture objects to the UI layer.
///
protocol PreviewSource: Sendable {
    // Connects a preview destination to this source.
    func connect(to target: PreviewTarget)
}

/// A protocol that passes the app's capture session to the `CameraPreview` view.
protocol PreviewTarget {
    // Sets the capture session on the destination.
    func setSession(_ session: AVCaptureSession)
}

/// The app's default `PreviewSource` implementation.
struct DefaultPreviewSource: PreviewSource {

    private let session: AVCaptureSession

    init(session: AVCaptureSession) {
        self.session = session
    }

    func connect(to target: PreviewTarget) {
        target.setSession(session)
    }
}
