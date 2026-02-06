//
//  VideoInput+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI
import AVFoundation

extension VideoInputView {

    @MainActor
    @Observable
    final class ViewModel {

        private var captureSession: CaptureSession = .init()

        var sessionError: CaptureError? = nil
        var selectedDevice: AVDevice? = nil
        var isRecording: Bool = false
        var url: URL? = nil

        var session: AVCaptureSession {
            captureSession.currentSession
        }

        var hasVideo: Bool {
            guard let selectedDevice, let device = selectedDevice.device else {
                return false
            }
            return device.isConnected
        }

        func start() async {
            await captureSession.initialize()
            do {
                if let selectedDevice {
                    try await captureSession.addDeviceInput(selectedDevice)
                    return
                }
                try await captureSession.addDeviceInput(.defaultDevice(.video))
            } catch {
                sessionError = .noVideo
            }
        }
    }
}


