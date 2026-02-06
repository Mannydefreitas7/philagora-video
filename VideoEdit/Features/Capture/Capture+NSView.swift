//
//  Capture+Preview.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import AppState
import AVFoundation
import SwiftUI

struct CaptureVideoPreview: NSViewRepresentable {

      let store: CaptureView.Store
    

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

       let previewLayer = AVCaptureVideoPreviewLayer(session: store.currentSession)
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
        Coordinator()
    }

    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {
        @ObservedDependency(\.captureStore) var captureStore
        var previewLayer: AVCaptureVideoPreviewLayer?

        // Required delegate method
        func fileOutput(
            _ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
                guard error != nil else {
                Task { @MainActor in
                    captureStore.error = .outputFileNotFound(url: outputFileURL, reason: error?.localizedDescription ?? .unknown)
                }
                return
            }
            print("Successfully saved to: \(outputFileURL.path)")
            Task { @MainActor in
                captureStore.isRecording = false
                captureStore.url = outputFileURL
            }
        }

        // Optional: UI sync method
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
            print("Recording started!")
            Task { @MainActor in
                captureStore.isRecording = true
                captureStore.url = fileURL
            }
        }
    }
}
