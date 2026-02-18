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
    @Observable final class ViewModel {

        // User preferences to store/restore window parameters
        @ObservationIgnored
        @Preference(\.aspectPreset) var aspectPreset
        @ObservationIgnored
        @Preference(\.showSafeGuides) var showSafeGuides
        @ObservationIgnored
        @Preference(\.showAspectMask) var showAspectMask
        @ObservationIgnored
        @Preference(\.showPlatformSafe) var showPlatformSafe
        @ObservationIgnored
        @Published var isConnecting: Bool = false
        // Combine cancellables
        private var cancellables: Set<AnyCancellable> = []
        private var mainSession: SessionStore = .init()
        // Device discovery actor
        private let deviceDiscovery: DeviceDiscovery = .shared
        /// View models
        var isRecording: Bool = false
        var url: URL?
        var error: CaptureError?
        var hasConnectionTimeout: Bool = false
        var spacing: CGFloat = 8
        var isTimerEnabled: Bool = false
        var timerSelection: TimeInterval.Option = .threeSeconds
        /// Input view models
        var videoInput: VideoInputView.ViewModel = .init()
        var audioInput: AudioInputView.ViewModel = .init()

        var audioDevices: [AVDevice] = []
        var videoDevices: [AVDevice] = []

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
            /// Switch to default devices
            logger.info("Switch to default devices")
            videoDevices = deviceDiscovery.discoverDevices(.video)
            audioDevices = deviceDiscovery.discoverDevices(.audio)
        }

        func onDisappear() async {
            await mainSession.stop(input: videoInput.selectedDevice, audioInput.selectedDevice)
            videoDevices = []
            audioDevices = []
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
              //  videoInput.selectedID = device
           //     selectedVideoID = device.id
                return
            }
        //    selectedAudioDevice = device
            await muteDevice(device)
        }

        ///
        func start() async {
            isConnecting = true
             _ = await mainSession.start(with: videoInput.selectedDevice, audioInput.selectedDevice)
        }


        func onVideoLayerAppear() {
            isConnecting = false
            hasConnectionTimeout = false
        }

        func onDeviceChange(previousId: AVDevice.ID, newId: AVDevice.ID?) {
            Task {
                logger.info("\(String(describing: #fileID)) - onceDeviceChange(): previousId: \(previousId), newId: \(String(describing: newId))")
                await mainSession.onChangeDevice(previousId: previousId, newId: newId)
            }
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
