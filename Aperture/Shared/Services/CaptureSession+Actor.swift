//
//  CaptureSession+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import AVFoundation
import Accelerate

actor CaptureSession {

    // Capture session
   nonisolated
    private let session: AVCaptureSession = .init()

    /// Session Outputs
    private let audioDataOutput: AVCaptureAudioDataOutput = .init()
    private let metadataOutput: AVCaptureMetadataOutput = .init()
    private let fileVideoOutput: AVCaptureMovieFileOutput = .init()
    private let fileAudioOutput: AVCaptureAudioFileOutput = .init()

    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureSession))
    private let sessionAudioQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureAudioOutput))
    private let sessionMetadataQueue = DispatchSerialQueue(label: .dispatchQueueKey(.metadataOutput))
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    // Delegates
    private let outputDelegate: OutputDataDelegate = .init()
    private let recordingDelegate: RecordingOutputDelegate = .init()
    private let metadataDelegate: MetadataOutputDelegate = .init()

    @Published var audioLevel: Float = 0
    @Published var peakLevel: Float = 0
    @Published var time: AVAudioTime = .init()
    @Published var isMonitoring: Bool = false

    var defaultOutputs: [AVCaptureOutput] {
        [audioDataOutput, metadataOutput]
    }

   nonisolated
   var current: AVCaptureSession {
         session
   }

    // 1. The configuration parameter for the FFT
    internal let bufferSize = 8192
    // 2. The FFT configuration
    internal var fftSetup: OpaquePointer?
    // 4. Store the results
    var fftMagnitudes = [Float](repeating: 0, count: .sampleAmount)
    // 5. Pick a subset of fftMagnitudes at regular intervals according to the downsampleFacto
    var downsampledMagnitudes: [Float] {
        fftMagnitudes.lazy.enumerated().compactMap { index, value in
            index.isMultiple(of: .downsampleFactor) ? value : nil
        }
    }

    // initialize
    func initialize(width preset: AVCaptureSession.Preset = .hd1920x1080) {

        // Ensures to initiate the session only if not already starting.
        guard !session.isRunning else { return }

        // Outputs + delegates
        audioDataOutput.setSampleBufferDelegate(outputDelegate, queue: sessionAudioQueue)
        metadataOutput.setMetadataObjectsDelegate(metadataDelegate, queue: sessionMetadataQueue)

        // Add all outputs
        defaultOutputs.forEach { output in
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }

        // Add preset if set and possible
        if session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
        }

        Task(priority: .userInitiated) {
            // starts session
            session.startRunning()
        }
    }

    func toggleMute(_ isEnabled: Bool) async {
        guard let connection = audioDataOutput.connection(with: .audio) else {
            return
        }
        connection.isEnabled = isEnabled
    }

    // MARK: - Get the device from type
    func findInput(with type: AVMediaType) -> AVDevice? {
        let input = session.inputs.first { input in
            input.ports.contains(where: { $0.mediaType == type })
        }
        let device: AVCaptureDevice =
        return
    }

        // MARK: - Remove existing input
    func removeInput(for device: AVDevice) throws {
        guard let existingInput = session.inputs
            .compactMap({ $0 as? AVCaptureDeviceInput })
            .first(where: { $0.device.uniqueID == device.id }) else {
            logger.error("Session does not contain input for device: \(device.name)")
            return
        }

        logger.info("Removing input: \(existingInput.device.localizedName)")
        session.beginConfiguration()
        session.removeInput(existingInput)
        session.commitConfiguration()
        logger.info("Input removed: \(existingInput.device.localizedName)")
    }

    // remove connection
    func removeConnection(_ device: AVDevice) {

        let connection = session.connections.first { connection in
            return connection.isActive && connection.inputPorts.contains(where: { $0.mediaType == .video })
        }
        guard let connection else { return }
        logger.info("Removing connection for device: \(device.name) in \(connection)")

        session.beginConfiguration()
        session.removeConnection(connection)
        session.commitConfiguration()
    }

    // add device input
    func addDeviceInput(_ device: AVDevice) throws {

        guard session.isRunning else {
            logger.log(level: .error, "Session is not running. Cannot add input.")
            throw AVError(.sessionNotRunning)
        }

        // Begin changes to the current session without restarting
        session.beginConfiguration()
        logger.log(level: .info, "Session is running. Adding input...")
        let input = try device.input
        // Check whether device isn't already in use by this or another session
        guard session.canAddInput(input) else {
            logger.log(level: .error, "Device \(device.name) is already in use by another session.")
            throw AVError(_nsError: .init(domain: "COULD NOT ADD INPUT", code: AVError.deviceNotConnected.rawValue))
        }
        // add input to the session
        logger.log(level: .info, "Adding input \(input.device.localizedName) to the session.")
        session.addInput(input)
        session.commitConfiguration()
        logger.log(level: .info, "Input \(input.device.localizedName) added to the session.")
    }

    func addDeviceInputs(_ devices: [AVDevice]) async throws {
        guard session.isRunning else {
            logger.log(level: .error, "Session is not running. Cannot add input.")
            throw AVError(.sessionNotRunning)
        }

            // Begin changes to the current session without restarting
        session.beginConfiguration()
        logger.log(level: .info, "Session is running. Adding inputs...")

        for device in devices {
            let input = try device.input
            guard session.canAddInput(input) else {
                logger.log(level: .error, "Device \(device.name) is already in use by another session.")
                throw AVError(_nsError: .init(domain: "COULD NOT ADD INPUT", code: AVError.deviceNotConnected.rawValue))
            }
                // add input to the session
            logger.log(level: .info, "Adding input \(input.device.localizedName) to the session.")
            session.addInputWithNoConnections(input)
        }
        session.commitConfiguration()
        logger.log(level: .info, "\(devices.count) Inputs added to the session.")
    }

    func addConnection(from port: AVCaptureInput.Port, to previewLayer: AVCaptureVideoPreviewLayer) throws {
        guard session.isRunning else {
            logger.log(level: .error, "Session is not running. Cannot add connection.")
            throw AVError(.sessionNotRunning)
        }
        
        session.beginConfiguration()
        let connection = AVCaptureConnection(inputPort: port, videoPreviewLayer: previewLayer)
        guard session.canAddConnection(connection) else {
            logger.log(level: .error, "Cannot add connection")
            throw AVError(.sessionNotRunning)
        }
        session.addConnection(connection)
        session.commitConfiguration()
    }

    func stop() {
        session.beginConfiguration()
        ///
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        ///
        session.commitConfiguration()
        ///
        Task(priority: .userInitiated) {
            session.stopRunning()
        }
    }
}
