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
    @Observable final class ViewModel: NSObject {

        private var session: CaptureSession = .init()
        private let deviceDescovery = DeviceDiscovery.shared
        private let defaultDeviceId = AVDevice.defaultDevice(.video).id
        private var cancellables: Set<AnyCancellable> = []

        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        var sessionError: CaptureError? = nil
        var url: URL? = nil

        var selectedID = AVDevice.defaultDevice(.video).id
        var selectedDevice: AVDevice = .defaultDevice(.video)
        var isRecording: Bool = false
        var showSettings: Bool = false

        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored: Bool?
        @ObservationIgnored
        @Preference(\.selectedVideoID) var selectedVideoID

        var isRunning: Bool { session.current.isRunning }
        var device: AVCaptureDevice {
            get throws {
                guard let device = selectedDevice.device else { throw AVError(.deviceNotConnected) }
                return device
            }
        }
        var deviceName: String { selectedDevice.name }
        var deviceInput: AVCaptureDeviceInput? {
            get throws {
                let input = try? selectedDevice.input
                return input
            }
        }

        var currentSession: AVCaptureSession { session.current }
        var currentDevice: AVDevice {
            get async { await deviceDescovery.getDevice(withUniqueID: selectedVideoID) ?? .defaultDevice(.video) }
        }

        func setSession(_ session: CaptureSession) {
            self.session = session
        }

        func initialize() async {
            guard !isRunning else { return }
            await session.initialize()
        }

        func start() async {
            do {
                logger.info("Starting with device \(self.selectedDevice.name)")
                try await session.addDeviceInput(selectedDevice)
            } catch {
                logger.error("Failed to add device input: \(error.localizedDescription)")
                sessionError = .noVideo
            }
        }

        func onChangeDevice(id: String) async {
            guard let device = await deviceDescovery.getDevice(withUniqueID: id) else { return }
            do {
                let currentDevice = await currentDevice
                try await session.removeInput(for: currentDevice)
                logger.warning("Successfully removed device: \(currentDevice.name)")
                try await session.addDeviceInput(device)
                logger.notice("Successfully changed device to \(device.name)")
            } catch {
                sessionError = .unknown(reason: "Could not change device for \(device.name)")
            }
        }

        func stop() async {
            await session.stop()
        }
    }
}


