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
    @Observable public class ViewModel {

        private var cancellables: Set<AnyCancellable> = []
        private var session: AVCaptureSession? = nil

        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        //
        var isConnecting: Bool = false
        var hasConnectionTimeout: Bool = false
        var currentSession: AVCaptureSession { session ?? .init() }
        //
        @ObservationIgnored
        @Published public var showSettings: Bool = false
        //
        @ObservationIgnored
        @Published public var selectedDevice: AVDevice = .defaultDevice(.video)

        @ObservationIgnored
        @Published public var availableDevices: [AVDevice] = []

        @ObservationIgnored
        @Published public var deviceId: AVDevice.ID = AVDevice.defaultDevice(.video).id
        @ObservationIgnored
        @Published public var isRunning: Bool = false

        @ObservationIgnored
        @Preference(\.selectedVideoID) var selectedVideoID: AVDevice.ID?

        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored: Bool?

        func setSession(_ session: AVCaptureSession) {
            self.session = session
        }

        func start() {
            // Start the video input
            logger.info("\(String(describing: #fileID)) - Start video input session")
            if let selectedVideoID, let device = DeviceDiscovery.shared.getDevice(withUniqueID: selectedVideoID) {
                logger.info("User has a default stored video id, using that: \(selectedVideoID)")
                deviceId = selectedVideoID
                selectedDevice = device
            }
        }
    }
}

