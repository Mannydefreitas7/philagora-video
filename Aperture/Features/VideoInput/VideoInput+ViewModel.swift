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
        private let defaultDevice: AVDevice = .defaultDevice(.video)
        private var cancellables: Set<AnyCancellable> = []

        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        var sessionError: CaptureError? = nil
        var url: URL? = nil

        var selectedID = AVDevice.defaultDevice(.video).id
      //  var selectedDevice: AVDevice = .defaultDevice(.video)
        var isRecording: Bool = false
        var showSettings: Bool = false
        //
        var isConnecting: Bool = false
        var hasConnectionTimeout: Bool = false

        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored: Bool?
        @ObservationIgnored
        @Preference(\.selectedVideoID) var storedVideoID: String?


        var isRunning: Bool { currentSession.isRunning }

        var currentDevice: AVDevice {
            get { deviceDescovery.getDevice(withUniqueID: selectedID) ?? defaultDevice }
        }

        var device: AVCaptureDevice {
            get throws {
                guard let device = currentDevice.device else { throw AVError(.deviceNotConnected) }
                return device
            }
        }

        var deviceName: String {
            get { currentDevice.name }
        }

        var deviceInput: AVCaptureDeviceInput? {
            get throws {
                let input = try currentDevice.input
                return input
            }
        }

        var currentSession: AVCaptureSession {
            session.current
        }

        func setSession(_ session: CaptureSession) {
            self.session = session
        }

        func initialize() async {
            guard !session.current.isRunning else {
                logger.warning("Session is already running, skipping initialization")
                return
            }
            await session.initialize()

            if let storedVideoID {
                logger.info("User has a default stored video id, using that: \(storedVideoID)")
                selectedID = storedVideoID
            }

            logger.info("Initialized capture session...")

            if let device = await deviceDescovery.getDevice(withUniqueID: selectedID) {
                logger.info("Selected device: \(device.name)")
            }
        }

        func start() async {
            guard session.current.isRunning else {
                logger.info("`start()` ignored as session is not running.")
                logger.info("`start()` calling initialize().")
                await initialize()
                return
            }
            do {
                let selectedDevice = await currentDevice
                logger.info("Starting with device \(selectedDevice.name)")
                try await session.addDeviceInput(selectedDevice)

            } catch {
                logger.error("Failed to add device input: \(error.localizedDescription)")
                sessionError = .noVideo
            }
        }

        func connectDevice(_ device: AVDevice) async throws {
            do {
                guard let port = inputPort(for: device, in: currentSession), let previewLayer else {
                    logger.warning("No input port for device: \(device.name)")
                    return
                }

                logger.debug("Adding device connection with port: \(port)")
                try await session.addConnection(from: port, to: previewLayer)
            } catch {
                logger.error("Failed to add device input: \(error.localizedDescription)")
            }
        }

        func onChangeDevice(id: String) async {
                // Ensure that the changed device is different
                // than the previous selected id.
            guard let device = await deviceDescovery.getDevice(withUniqueID: id), storedVideoID != device.id else { return }

            do {
                // get the current device info asynchronously
                let previousDevice = await self.currentDevice
                // Renmove the previous device input
                try await session.removeInput(for: previousDevice)
                logger.warning("Successfully removed device: \(previousDevice.name)")
                // when previous input is successfully removed from session
                // add new device to running session
                try await session.addDeviceInput(device)
                logger.notice("Successfully changed device to \(device.name)")
            } catch {
                sessionError = .unknown(reason: "Could not change device for \(device.name)")
            }
        }


        func stop() async {
            await session.stop()
        }

        private func inputPort(for device: AVDevice, in session: AVCaptureSession) -> AVCaptureInput.Port? {
            guard let input = session.inputs
                .compactMap({ $0 as? AVCaptureDeviceInput })
                .first(where: { $0.device.uniqueID == device.id }) else {
                return nil
            }
            return input.ports.first(where: { $0.mediaType == .video })
        }

        private func configureMirroring(for connection: AVCaptureConnection) {
            guard let isMirrored else { return }
            connection.automaticallyAdjustsVideoMirroring = false
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = isMirrored
            }
        }
    }
}

