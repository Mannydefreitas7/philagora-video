//
//  Preview+View.swift
//  Aperture
//
//  Created by Emmanuel on 2026-02-17.
//

import Combine
import SwiftUI
import AVFoundation

@MainActor
@Observable class PreviewViewModel {

    // Services
    private let deviceDescovery = DeviceDiscovery.shared
    // session
    private var session: CaptureSession = .init()
    private let defaultVideoDevice: AVDevice = .defaultDevice(.video)
    private var cancellables: Set<AnyCancellable> = []
    // View related
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    var sessionError: CaptureError? = nil
    var selectedID = AVDevice.defaultDevice(.video).id
    // Conditions
    var showSettings: AVMediaType? = nil
    var isConnecting: Bool = false
    var hasConnectionTimeout: Bool = false

    @Preference(\.selectedVideoID) var selectedVideoID: String?
    @Preference(\.selectedAudioID) var selectedAudioID: String?

    var currentDevice: AVDevice {
        get { deviceDescovery.getDevice(withUniqueID: selectedID) ?? defaultVideoDevice }
    }

    func initialize() async {
        guard !session.current.isRunning else {
            logger.warning("Session is already running, skipping initialization")
            return
        }
        await session.initialize()

        if let selectedVideoID {
            logger.info("User has a default stored video id, using that: \(selectedVideoID)")
            selectedID = selectedVideoID
        }

        logger.info("Initialized capture session...")

        if let videoDevice = deviceDescovery.getDevice(withUniqueID: selectedID) {
            logger.info("Selected device: \(videoDevice.name)")
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

    func onChangeDevice(id: String) async {
            // Ensure that the changed device is different
            // than the previous selected id.
        guard let device = deviceDescovery.getDevice(withUniqueID: id) else { return }

        do {
            // Get the previous device of the same media type
            let previousDevice = session.current.inputs.
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


}
