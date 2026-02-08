//
//  VideoInput+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI
import AVFoundation
import Combine

extension VideoInputView {

    @MainActor
    @Observable
    final class ViewModel {

        private var captureSession: CaptureSession = .init()

        var sessionError: CaptureError? = nil
        var selectedDevice: AVDevice = .defaultDevice(.video)
        var isRecording: Bool = false
        var showSettings: Bool = false

        var isRunning: Bool = false
        var url: URL? = nil

        var session: AVCaptureSession { captureSession.currentSession }

        var device: AVCaptureDevice {
            get throws {
                guard let device = selectedDevice.device else { throw AVError(.deviceNotConnected) }
                return device
            }
        }

        var deviceName: String { selectedDevice.device?.localizedName ?? selectedDevice.name }

        var deviceInput: AVCaptureDeviceInput? {
            get throws {
                let input = try? selectedDevice.input
                return input
            }
        }

        func initialize() async {
            guard !captureSession.currentSession.isRunning else { return }
            await captureSession.initialize()
        }

        func start() async {
            do {
                try await captureSession.addDeviceInput(selectedDevice)
            } catch {
                logger.error("Failed to add device input: \(error.localizedDescription)")
                sessionError = .noVideo
            }
        }

        func stop() async {
            await captureSession.stop()
        }
    }
}


