//
//  MultiCamSession+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-09.
//

import AVFoundation

#if os(iOS)
actor MultiCamSession {

    nonisolated
    private let session: AVCaptureMultiCamSession = .init()

    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureSession))

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    nonisolated var current: AVCaptureSession {
        session
    }

    func initialize() {
        guard !session.isRunning else { return }

        session.beginConfiguration()
        session.sessionPreset = .inputPriority
        session.commitConfiguration()

        Task(priority: .userInitiated) {
            session.startRunning()
        }
    }

    func addDeviceInput(_ device: AVDevice) throws {
        let input = try device.input
        guard session.canAddInput(input) else {
            logger.error("Device \(device.name) cannot be added to multi-cam session.")
            throw AVError(_nsError: .init(domain: "COULD NOT ADD INPUT", code: AVError.deviceNotConnected.rawValue))
        }

        session.beginConfiguration()
        session.addInputWithNoConnections(input)
        session.commitConfiguration()
    }

    func removeInput(for device: AVDevice) throws {
        guard let existingInput = session.inputs
            .compactMap({ $0 as? AVCaptureDeviceInput })
            .first(where: { $0.device.uniqueID == device.id }) else {
            return
        }

        let ports = existingInput.ports
        let connectionsToRemove = session.connections.filter { connection in
            connection.inputPorts.contains { port in
                ports.contains(port)
            }
        }

        session.beginConfiguration()
        connectionsToRemove.forEach { session.removeConnection($0) }
        session.removeInput(existingInput)
        session.commitConfiguration()
    }

    func stop() {
        session.beginConfiguration()
        session.connections.forEach { session.removeConnection($0) }
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()

        Task(priority: .userInitiated) {
            session.stopRunning()
        }
    }
}
#else
actor MultiCamSession {

    nonisolated
    private let session: AVCaptureSession = .init()

    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureSession))

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    nonisolated var current: AVCaptureSession {
        session
    }

    func initialize() {
        guard !session.isRunning else { return }
        Task(priority: .userInitiated) {
            session.startRunning()
        }
    }

    func addDeviceInput(_ device: AVDevice) throws {
        let input = try device.input
        guard session.canAddInput(input) else {
            throw AVError(_nsError: .init(domain: "COULD NOT ADD INPUT", code: AVError.deviceNotConnected.rawValue))
        }
        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()
    }

    func removeInput(for device: AVDevice) throws {
        guard let existingInput = session.inputs
            .compactMap({ $0 as? AVCaptureDeviceInput })
            .first(where: { $0.device.uniqueID == device.id }) else {
            return
        }
        session.beginConfiguration()
        session.removeInput(existingInput)
        session.commitConfiguration()
    }

    func stop() {
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()

        Task(priority: .userInitiated) {
            session.stopRunning()
        }
    }
}
#endif
