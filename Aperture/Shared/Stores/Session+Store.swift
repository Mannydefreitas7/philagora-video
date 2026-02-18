//
//  Session+Store.swift
//  Aperture
//
//  Created by Emmanuel on 2026-02-17.
//

import Combine
import SwiftUI
import AVFoundation

@MainActor
@Observable class SessionStore {
    // Services
    private let deviceDescovery = DeviceDiscovery.shared
    // session
    private var session: CaptureSession = .init()
    private var cancellables: Set<AnyCancellable> = []
    // View related
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    var sessionError: CaptureError? = nil
    var previewVideoID = AVDevice.defaultDevice(.video).id
    var previewAudioID = AVDevice.defaultDevice(.audio).id
    // Conditions
    var isConnecting: Bool = false
    var hasConnectionTimeout: Bool = false
    var showRecordButton: Bool = false
    // Initialize
    func initialize() async {
        guard !session.current.isRunning else {
            logger.warning("Session is already running, skipping initialization")
            return
        }
        await session.initialize()
        logger.info("Initialized capture session...")
    }

    // Start
    func start(with devices: AVDevice...) async -> Bool {
        guard session.current.isRunning else {
            logger.info("`start()` ignored as session is not running.")
            logger.info("`start()` calling initialize() a second time.")
            await initialize()
            return false
        }
        do {
            for device in devices {
                logger.info("Starting with \(device.kind.rawValue) device \(device.name)")
                try await session.addDeviceInput(device)
            }
            return session.current.isRunning
        } catch {
            logger.error("Failed to add device input: \(error.localizedDescription)")
            sessionError = .noVideo
        }
        return false
    }

    func onChangeDevice(previousId: AVDevice.ID, newId: AVDevice.ID?) async {
        guard let newId, let newDevice = deviceDescovery.getDevice(withUniqueID: newId) else {
            sessionError = .unknown(reason: "Could not change device for ID \(newId ?? "Unknown")")
            return
        }
        do {
            // Ensure that the changed device is different
            // than the previous selected id.
            guard let previousDevice = deviceDescovery.getDevice(withUniqueID: previousId) else {
                try await session.addDeviceInput(newDevice)
                return
            }
            // Renmove the previous device input
            try await session.removeInput(for: previousDevice)
            logger.warning("Successfully removed device: \(previousDevice.name)")
            // when previous input is successfully removed from session
            // add new device to running session
            try await session.addDeviceInput(newDevice)
            logger.notice("Successfully changed device to \(newDevice.name)")
        } catch {
            sessionError = .unknown(reason: "Could not change device for \(newDevice.name)")
        }
    }

    func stop(input devices: AVDevice...) async {
        do {
            for device in devices {
                try await session.removeInput(for: device)
            }
            await session.stop()
        } catch {
            logger.error("Failed to remove device input: \(error.localizedDescription)")
        }
    }

    private func inputPort(for device: AVDevice, in session: AVCaptureSession) -> AVCaptureInput.Port? {
        guard let input = session.inputs
            .compactMap({ $0 as? AVCaptureDeviceInput })
            .first(where: { $0.device.uniqueID == device.id }) else {
            return nil
        }
        return input.ports.first(where: { $0.mediaType == .video })
    }
}
