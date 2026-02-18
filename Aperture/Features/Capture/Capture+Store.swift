//
//  Capture+Store.swift
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
        // Device discovery actor
        private let deviceDiscovery: DeviceDiscovery = .shared

        @ObservationIgnored
        @Preference(\.selectedVideoID) var selectedVideoID: AVDevice.ID?

        @Published private(set) var recordingDuration: TimeInterval = 0
        /// Waveform / meters
        @Published var audioLevel: Float = 0
        @Published var audioHistory: [Double] = []
        @Published var selectedAudioDevice: AVDevice = .defaultDevice(.audio)
        /// View models
        @Published var downsampledMagnitudes: [Float] = []
        @Published var fftMagnitudes: [Float] = []
        @Published var isRecording: Bool = false
        @Published var url: URL?
        @Published var error: CaptureError?
        @Published var isConnecting: Bool = false
        @Published var hasConnectionTimeout: Bool = false
        /// Input view models
        @Published var videoInput: VideoInputView.ViewModel = .init()
        @Published var audioInput: AudioInputView.ViewModel = .init()

        @Published var audioDevices: [AVDevice] = []
        @Published var videoDevices: [AVDevice] = []

       var currentSession: AVCaptureSession {
           get { videoInput.currentSession }
       }

        func authorizationStatus(for type: AVMediaType) -> AVAuthorizationStatus {
            AVCaptureDevice.authorizationStatus(for: type)
        }

        func requestAccess(for type: AVMediaType) async -> Bool {
            let status = authorizationStatus(for: type)
            if status == .notDetermined {
                return await AVCaptureDevice.requestAccess(for: type)
            }
            return status == .authorized
        }

        func initialize() async {
            /// Configure + start the single underlying session.
            logger.debug("Starting capture engine")
            /// Audio service
            $isConnecting
                .map { $0.isTruthy }
                // If after 5 seconds we are still attemting,
                // to make a connection to device, then timeout.
                .delay(for: .seconds(10), scheduler: RunLoop.main)
                .assign(to: \.hasConnectionTimeout, on: self)
                .store(in: &cancellables)
            ///
            //downsampledMagnitudes = await captureSession.downsampledMagnitudes
            //fftMagnitudes = await captureSession.fftMagnitudes
           // audioLevel = await captureSession.audioLevel
            /// Switch to default devices
            logger.info("Switch to default devices")
            videoDevices = deviceDiscovery.discoverDevices(.video)
            audioDevices = deviceDiscovery.discoverDevices(.audio)

            await videoInput.initialize()
        }

        func onDisappear() async {
            await videoInput.stop()
        }

        /// Mute device
        func muteDevice(_ device: AVDevice) async {
           // await captureSession.toggleMute(device.isOn)
            logger.info("Mute device: \(device.name)")
        }

        /// Select device
        func selectDevice(_ device: AVDevice) async {
            let isVideo = device.kind == .video
            if isVideo {
                videoInput.selectedID = device
                selectedVideoID = device.id
                return
            }
            selectedAudioDevice = device
            await muteDevice(device)
        }

        ///
        func start() async {
            isConnecting = true
            await videoInput.start()
        }


        func onVideoAppear() {
            isConnecting = false
            hasConnectionTimeout = false
            videoInput.selectedDevice.isOn = true
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
