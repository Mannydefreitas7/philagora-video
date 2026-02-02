//
//  AVCaptureEngine+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//
@preconcurrency import AVFoundation
import Combine

/// Main capture engine actor.
actor AVCaptureEngine {

    static let shared = AVCaptureEngine()

    /// A Boolean value that indicates whether a higher priority event,
    /// like receiving a phone call, interrupts the app.
    @Published private(set) var isInterrupted: Bool = false
    /// A Boolean value that indicates whether the user enables HDR video capture.
    @Published var isHDRVideoEnabled: Bool = false
    /// A Boolean value that indicates whether capture controls are in a fullscreen appearance.
    @Published var isShowingFullscreenControls: Bool = false
    /// A type that connects a preview destination with the capture session.
    nonisolated let previewSource: PreviewSource
    // The app's capture session.
    nonisolated let captureSession = AVCaptureSession()
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureSession))
    // The mode of capture, either photo or video. Defaults to photo.
    private(set) var captureMode = CaptureMode.video
    // A Boolean value that indicates whether the actor finished its required configuration.
    private var isSetUp: Bool = false
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    init() {
        // Create a source object to connect the preview view with the capture session.
        previewSource = DefaultPreviewSource(session: captureSession)
    }

    // MARK: - Capture session life cycle
    func start(with state: CameraState) async throws {
        // Set initial operating state.
        captureMode = state.captureMode
        // Check whether the HDR is enabled
        isHDRVideoEnabled = state.isVideoHDREnabled
        // Exit early if not authorized or the session is already running.
        guard !captureSession.isRunning else { return }
        // Configure the session and start it.
        try await configure()
        // Start session.
        captureSession.startRunning()
    }

    // MARK: - Capture setup
    /// Performs the initial capture session configuration.
    private func configure() async throws {
        /// Return early if already set up.
        guard !isSetUp else { return }
        /// fetch available devices

        do {
            #if os(iOS)
            // Enable using AirPods as a high-quality lapel microphone.
            captureSession.configuresApplicationAudioSessionForBluetoothHighQualityRecording = true
            #endif
            /// Configure the session preset based on the current capture mode.
            captureSession.sessionPreset = captureMode == .photo ? .photo : .hd4K3840x2160
            /// If the capture mode is set to Video, add a movie capture output.
            /// Add the movie output as the default output type.
            isSetUp = true
        } catch {
            throw CameraError.setupFailed
        }
    }

    // MARK: - Access to nested video preview layer
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        /// Access the capture session's connected preview layer.
        guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }

    // MARK: - Change the preset of the session
    nonisolated func setPreset(_ preset: AVCaptureSession.Preset) async {
        sessionQueue.async {
            self.captureSession.sessionPreset = preset
        }
    }

    // MARK: - Remove existing input
    func removeInput(for device: AVDeviceInfo) throws {
        if let input = device.input, captureSession.inputs.contains(input) {
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }
            captureSession.removeInput(input)
        }
    }

    // Adds an input to the capture session to connect the specified capture device.
    internal func addInput(for device: AVDeviceInfo) throws {
        guard let input = device.input else {
            throw CameraError.addInputFailed
        }
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        // Add the input process
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
    }

    // Adds an output to the capture session to connect the specified capture device, if allowed.
    private func addOutput(_ output: AVCaptureOutput) throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }

}
