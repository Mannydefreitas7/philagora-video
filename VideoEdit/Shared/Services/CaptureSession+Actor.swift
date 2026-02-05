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
   var currentSession: AVCaptureSession {
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

    // add device input
    @discardableResult
    func addDeviceInput(_ device: AVDevice) throws -> Bool {

        guard session.isRunning else {
            throw AVError(.sessionNotRunning)
        }

        // Begin changes to the current session without restarting
        session.beginConfiguration()

        let input = try device.input
        // Check whether device isn't already in use by this or another session
        guard session.canAddInput(input) else {
            // if input is already in use,
            // remove it
            session.removeInput(input)
            return false
        }
        // add input to the session
        session.addInput(input)
        session.commitConfiguration()
        return true
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
