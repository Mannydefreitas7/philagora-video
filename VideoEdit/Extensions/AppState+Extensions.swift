//
//  IAppState+Extensions.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-19.
//

import SwiftUI
import AVFoundation
import CoreMedia
import Combine

// MARK: - App State

@MainActor
final class IAppState: ObservableObject {
    @Published var videoURL: URL?
    @Published var currentTool: EditingTool = .none
    @Published var showRecordingSheet = false
    @Published var showExportSheet = false
    @Published var exportFormat: ExportFormat = .movie
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    /// properties
    @Published var status: CaptureStatus = .idle

    // Capture view model
    @Published var captureState: CaptureView.Store = .init()
    @Published var previewState: CaptureView.Store = .init()

    // Crop settings
    @Published var cropRect: CGRect = .zero
    @Published var isCropping = false

    // Trim settings
    @Published var trimStart: Double = 0
    @Published var trimEnd: Double = 1

    // Recording settings
    @Published var recordMicrophone = true
    @Published var recordSystemAudio = false
    @Published var showCameraOverlay = false
    @Published var visualizeClicks = true
    @Published var recordingQuality: RecordingQuality = .high

    // GIF settings
    @Published var gifFrameRate: Int = 15
    @Published var gifLoopCount: Int = 0 // 0 = infinite
    @Published var gifScale: Double = 1.0
    @Published var gifOptimize = true

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .video, .mpeg4Movie, .quickTimeMovie, .gif]

        if panel.runModal() == .OK {
            videoURL = panel.url
            currentTool = .none
            cropRect = .zero
            trimStart = 0
            trimEnd = 1
        }
    }

    func startCapture() async {
        logger.info("Capture engine status: \(self.status == .idle ? "idle" : "running")")
        guard status == .idle else {
            logger.debug("Capture engine is running")
            return
        }
        do {
            status = .configuring
            try await captureState.initialize()
            status = .running
        } catch {
            logger.error("Capture error: \(error.localizedDescription)")
            status = .failed(message: "Failed to initialize capture engine")
        }
    }

    func endCapture() async {
        logger.info("Ending capture engine...")
        guard status == .running else {
            logger.debug("Capture engine is not running")
            return
        }
        status = .idle
    }

    func saveFile(completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = exportFormat == .gif ? [.gif] : [.mpeg4Movie]
        panel.nameFieldStringValue = exportFormat == .gif ? "export.gif" : "export.mp4"

        if panel.runModal() == .OK {
            completion(panel.url)
        } else {
            completion(nil)
        }
    }
}


