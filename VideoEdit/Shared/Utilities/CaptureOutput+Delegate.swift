//
//  CaptureOutput+Delegate.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//
import AVFoundation

// Delegate classes
class OutputDataDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {

    var sampleBuffer: CMSampleBuffer?
    var connection: AVCaptureConnection?

    func process(sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
        self.sampleBuffer = sampleBuffer
        self.connection = connection
    }

    func captureOutput(_
           output: AVCaptureOutput,
           didOutput sampleBuffer: CMSampleBuffer,
           from connection: AVCaptureConnection
    ) {
        process(sampleBuffer: sampleBuffer, connection: connection)
    }
}

// Delegate classes
class FileOutputDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {

    var connections: [AVCaptureConnection] = []
    var url: URL?
    var error: CaptureError?

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?
    ) {
        if let error {
            self.error = .outputFileNotFound(url: outputFileURL, reason: error.localizedDescription)
            return
        }
        self.url = outputFileURL
        self.connections = connections
    }

    func process(_ action: @escaping (_ url: URL, _ connections: [AVCaptureConnection]) -> Void) {
        guard let url, !connections.isEmpty else { return }
        action(url, self.connections)
    }
}

class RecordingOutputDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {

    var connections: [AVCaptureConnection] = []
    var url: URL?
    var error: CaptureError?

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?
    ) {
        if let error {
            self.error = .outputFileNotFound(url: outputFileURL, reason: error.localizedDescription)
            return
        }
        self.url = outputFileURL
        self.connections = connections
    }

    func process(_ action: @escaping (_ url: URL, _ connections: [AVCaptureConnection]) -> Void) {
        guard let url, !connections.isEmpty else { return }
        action(url, self.connections)
    }

}

class MetadataOutputDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    var metadata: [AVMetadataObject] = []
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        self.metadata = metadataObjects
    }
}
