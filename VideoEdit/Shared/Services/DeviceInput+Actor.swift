//
//  DeviceInput+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//
import AVFoundation
import Accelerate
import SwiftUI

actor DeviceInput {
    /// A value that indicates whether the capture service is idle or capturing a photo or movie.
    private(set) var captureActivity: CaptureActivity = .idle
    ///
    let session: AVCaptureSession = .init()
    // MARK: - access authorization
    var isAuthorized: Bool {
        let authorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        if !authorized {
            Task { return await AVCaptureDevice.requestAccess(for: .audio) }
        }
        return authorized
    }

    init () { }

    func addInput(for device: AVDevice) async throws {
        let input = try device.input
        guard session.canAddInput(input) else {
            session.removeInput(input)
            throw AVError.init(.unknown)
        }
        session.addInput(input)
    }

    func initialize(with device: AVDevice, preset: AVCaptureSession.Preset = .hd1920x1080) async throws {
        // Check whether the session is running to stop it.
        if session.isRunning {
            session.stopRunning()
        }
       

        session.sessionPreset = preset

        // add Input to the session
        try await addInput(for: device)
        // Starts the session.
        session.startRunning()
    }

}
