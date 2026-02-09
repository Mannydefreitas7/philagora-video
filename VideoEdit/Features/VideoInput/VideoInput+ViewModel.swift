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
        var previousDevice: AVDevice? = nil
        var isRecording: Bool = false
        var showSettings: Bool = false

        @ObservationIgnored
        @Preference(\.isMirrored) var isMirrored: Bool?
        @ObservationIgnored
        @Preference(\.selectedVideoID) var selectedVideoID

        var isRunning: Bool { currentSession.isRunning }

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

        var currentSession: AVCaptureSession {
            session.current
        }

        var currentDevice: AVDevice {
            get async { await deviceDescovery.getDevice(withUniqueID: selectedVideoID) ?? .defaultDevice(.video) }
        }

        func setSession(_ session: CaptureSession) {
            self.session = session
        }

        func initialize() async {
            guard !isRunning else { return }
            await session.initialize()

            do {
                try  await session.addDeviceInputs(deviceDescovery.cameras)
            } catch {
                logger.error("Failed to add device inputs: \(error.localizedDescription)")
            }


            selectedID = selectedVideoID

            if let device = await deviceDescovery.getDevice(withUniqueID: selectedVideoID) {
                selectedDevice = device
            }
        }

        func start() async {
            do {
                logger.info("Starting with device \(self.selectedDevice.name)")
                previousDevice = selectedDevice

                try await connectDevice(selectedDevice)

               // try await session.addDeviceInput(selectedDevice)
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
            guard let device = await deviceDescovery.getDevice(withUniqueID: id) else { return }

            do {
                if let previousDevice, previousDevice.id != device.id {
                   // try await session.removeInput(for: previousDevice)
                    await session.removeConnection(previousDevice)
                    logger.warning("Successfully removed device: \(previousDevice.name)")
                }
               // try await session.addDeviceInput(device)
                try await connectDevice(device)
                self.previousDevice = device
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

