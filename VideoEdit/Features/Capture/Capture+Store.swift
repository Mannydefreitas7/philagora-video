//
//  Capture+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import AVFoundation
import Combine
import SwiftUI

extension CaptureView {
    @MainActor
    final class Store: ObservableObject {
        // Combine cancellables
        private var cancellables: Set<AnyCancellable> = []
        /// capture session actor
        private let captureSession: CaptureSession = .init()

        @Published private(set) var recordingDuration: TimeInterval = 0
        /// Waveform / meters
        @Published var audioLevel: Float = 0
        @Published var audioHistory: [Double] = []
        @Published var selectedVideoDevice: AVDevice = .defaultDevice(.video)
        @Published var selectedAudioDevice: AVDevice = .defaultDevice(.audio)
        /// View models
        @Published var downsampledMagnitudes: [Float] = []
        @Published var fftMagnitudes: [Float] = []
        @Published var isRecording: Bool = false
        @Published var url: URL?
        @Published var error: CaptureError?

       var currentSession: AVCaptureSession {
          get { captureSession.currentSession }
       }

        func authorizationStatus(for type: AVMediaType) -> AVAuthorizationStatus {
            AVCaptureDevice.authorizationStatus(for: type)
        }

        func requestAccess(for type: AVMediaType) async -> Bool {
            let status = authorizationStatus(for: type)
            if status == .notDetermined {
                return await AVCaptureDevice.requestAccess(for: type)
            }
        }

        func initialize() async {
            /// Configure + start the single underlying session.
            logger.debug("Starting capture engine")
            /// Audio service
            await captureSession.initialize()
            ///
            downsampledMagnitudes = await captureSession.downsampledMagnitudes
            fftMagnitudes = await captureSession.fftMagnitudes
            audioLevel = await captureSession.audioLevel
            /// Switch to default devices
            logger.info("Switch to default devices")
        }

        func onDisappear() async {
            await captureSession.stop()
        }

        /// Mute device
        func muteDevice(_ device: AVDevice) async {
            await captureSession.toggleMute(device.isOn)
            logger.info("Mute device: \(device.name)")
        }

        /// Select device
        func selectDevice(_ device: AVDevice) async {
            let isVideo = device.kind == .video
            if isVideo {
                selectedVideoDevice = device
                return
            }
            selectedAudioDevice = device
            await muteDevice(device)
        }
//
//        /// Switch to a specific device
//        func commitDevice(_ device: AVDevice, isOn: Bool = false) async {
//            let isVideo = device.kind == .video
//            /// Current device
//            let currentDevice = isVideo ? selectedVideoDevice : selectedAudioDevice
//            logger.info("No input or device to switch to: \(device.name)")
//            do {
//                try await engine.removeInput(for: currentDevice)
//                var newValue = device
//                newValue.isOn = isOn
//                try await engine.addInput(for: newValue)
//            } catch {
//                logger.error("Failed to remove input: \(error.localizedDescription)")
//                try? await engine.addInput(for: currentDevice)
//            }
//        }
    }
}
