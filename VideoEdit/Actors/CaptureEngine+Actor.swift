//
//  CaptureEngine+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//

@preconcurrency import AVFoundation
import Combine

enum CaptureEngineError: Error {
    case noVideoDeviceAvailable
    case noAudioDeviceAvailable
}

actor CaptureEngine {

    /// A value that indicates whether the capture service is idle or capturing a photo or movie.
    @Published private(set) var captureActivity: CaptureActivity = .idle
    /// A value that indicates the current capture capabilities of the service.
    @Published private(set) var captureCapabilities: CaptureCapabilities = .unknown
    /// A Boolean value that indicates whether a higher priority event, like receiving a phone call, interrupts the app.
    @Published private(set) var isInterrupted: Bool = false
    /// A Boolean value that indicates whether the user enables HDR video capture.
    @Published var isHDRVideoEnabled: Bool = false
    /// A Boolean value that indicates whether capture controls are in a fullscreen appearance.
    @Published var isShowingFullscreenControls: Bool = false

    @Published private(set) var audioLevel: Float = 0

    /// Available video capture devices.
    @Published private(set) var availableVideoDevices: [AVCaptureDevice] = []
    
    /// Available audio capture devices.
    @Published private(set) var availableAudioDevices: [AVCaptureDevice] = []

    

    /// A type that connects a preview destination with the capture session.
    nonisolated let previewSource: PreviewSource

    // The app's capture session.
    nonisolated let captureSession = AVCaptureSession()

    // Audio level monitoring actor
    nonisolated let audioLevelMonitor: AVAudioLevelMonitor = .init()

    // An object that manages the app's photo capture behavior.
    private let photoCapture = PhotoCapture()

    // An object that manages the app's video capture behavior.
    private let movieCapture = MovieCapture()

    // An internal collection of output services.
    private var outputServices: [any OutputService] { [photoCapture, movieCapture] }

    // The video input for the currently selected device camera.
    internal var activeVideoInput: AVCaptureDeviceInput?

    // The video input for the currently selected device microphone.
    var activeAudioInput: AVCaptureDeviceInput?

    // The mode of capture, either photo or video. Defaults to photo.
    private(set) var captureMode = CaptureMode.video

    // An object the service uses to retrieve capture devices.
    private let deviceLookup = DeviceLookup()

    // An object that monitors the state of the system-preferred camera.
    private let systemPreferredCamera = SystemPreferredCameraObserver()

    private var rotationObservers = [AnyObject]()

    // MARK: - Audio sample stream (for waveform / meters)

    private let audioDataOutput = AVCaptureAudioDataOutput()
    private var audioStreamContinuation: AsyncStream<CMSampleBuffer>.Continuation?
  //  private var audioSampleDelegate: AudioSampleOutputDelegate?
    private let audioOutputQueue = DispatchQueue(label: .dispatchQueueKey(.captureAudioOutput))

    // A Boolean value that indicates whether the actor finished its required configuration.
    private var isSetUp: Bool = false

    // A delegate object that responds to capture control activation and presentation events.
    private var controlsDelegate = CaptureControlsDelegate()

    // A map that stores capture controls by device identifier.
    private var controlsMap: [String: [AVCaptureControl]] = [:]

    // A method to forward the
    nonisolated
    func onChange(_ handler: @escaping @Sendable (Float) -> Void) async {
       await audioLevelMonitor.onChange(handler)
    }

    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureSession))

    // (session property removed as per instructions)

    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    var audioDevice: AVCaptureDevice? {
        return activeAudioInput?.device
    }

    var videoDevice: AVCaptureDevice? {
        return activeVideoInput?.device
    }

    // MARK: - Authorization
    /// A Boolean value that indicates whether a person authorizes this app to use
    /// device cameras and microphones. If they haven't previously authorized the
    /// app, querying this property prompts them for authorization.
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            // Determine whether a person previously authorized camera access.
            var isAuthorized = status == .authorized
            // If the system hasn't determined their authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }

    init() {
        // Create a source object to connect the preview view with the capture session.
        previewSource = DefaultPreviewSource(session: captureSession)
    }

    // MARK: - Capture session life cycle
    func start(with state: CameraState) async throws {
        // Set initial operating state.
        captureMode = state.captureMode
        isHDRVideoEnabled = state.isVideoHDREnabled

        // Exit early if not authorized or the session is already running.
        guard await isAuthorized, !captureSession.isRunning else { return }
        // Configure the session and start it.
        try await setUpSession()
        captureSession.startRunning()
    }

    // MARK: - Capture stop
    func stop() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

    // MARK: - Capture setup
    // Performs the initial capture session configuration.
    private func setUpSession() async throws {
        // Return early if already set up.
        guard !isSetUp else { return }

        // Observe internal state and notifications.
        observeOutputServices()
        observeNotifications()
        observeCaptureControlsState()

        do {
            // Retrieve the default camera and microphone.
            let defaultCamera = try deviceLookup.defaultCamera
            let defaultMic = try deviceLookup.defaultMic
            
            // Populate available devices for the UI
            availableVideoDevices = deviceLookup.cameras
            availableAudioDevices = deviceLookup.microphones

            #if os(iOS)
            // Enable using AirPods as a high-quality lapel microphone.
            captureSession.configuresApplicationAudioSessionForBluetoothHighQualityRecording = true
            #endif
            // Add inputs for the default camera and microphone devices.
            activeVideoInput = try addInput(for: defaultCamera)
            activeAudioInput = try addInput(for: defaultMic)

            logger.info("active audio input \(String(describing: self.activeAudioInput))")

            // Configure the session preset based on the current capture mode.
            captureSession.sessionPreset = captureMode == .photo ? .photo : .hd4K3840x2160
            // If the capture mode is set to Video, add a movie capture output.
            if captureMode == .video {
                // Add the movie output as the default output type.
                try addOutput(movieCapture.output)
                setHDRVideoEnabled(isHDRVideoEnabled)
            }

            // Add an audio data output for level monitoring / waveform rendering.
            let audioOutput = audioLevelMonitor.start(with: audioDataOutput)
            // This is lightweight and does not create a second AVCaptureSession.
            if captureSession.canAddOutput(audioOutput) {
                captureSession.addOutput(audioOutput)

                // Verify the audio connection is properly established
                if let audioConnection = audioOutput.connection(with: .audio) {
                    if audioConnection.isEnabled {
                        logger.debug("Audio data output successfully connected to audio input.")
                    } else {
                        logger.warning("Audio connection exists but is disabled.")
                        audioConnection.isEnabled = true
                    }
                } else {
                    logger.error("No audio connection found for audioDataOutput. Audio samples will be empty.")
                }
            } else {
                logger.error("Cannot add audio data output to capture session.")
            }

            // Configure controls to use with the Camera Control.
            configureControls(for: defaultCamera)
            // Monitor the system-preferred camera state.
            monitorSystemPreferredCamera()
            // Observe changes to the default camera's subject area.
            observeSubjectAreaChanges(of: defaultCamera)
            // Update the service's advertised capabilities.
            updateCaptureCapabilities()

            isSetUp = true

          
        } catch {
            throw CameraError.setupFailed
        }
    }

    // MARK: - Capture controls
    internal func configureControls(for device: AVCaptureDevice) {

        // Exit early if the host device doesn't support capture controls.
        guard captureSession.supportsControls else { return }

        // Begin configuring the capture session.
        captureSession.beginConfiguration()

        // Remove previously configured controls, if any.
        for control in captureSession.controls {
            captureSession.removeControl(control)
        }

        // Create controls and add them to the capture session.
        for control in createControls(for: device) {
            if captureSession.canAddControl(control) {
                captureSession.addControl(control)
            } else {
                logger.info("Unable to add control \(control).")
            }
        }

        // Set the controls delegate.
        captureSession.setControlsDelegate(controlsDelegate, queue: sessionQueue)

        // Commit the capture session configuration.
        captureSession.commitConfiguration()
    }

    func createControls(for device: AVCaptureDevice) -> [AVCaptureControl] {
        // Retrieve the capture controls for this device, if they exist.
        guard let controls = controlsMap[device.uniqueID] else {
            // Define the default controls.
            var controls = [
                AVCaptureSystemZoomSlider(device: device),
                AVCaptureSystemExposureBiasSlider(device: device)
            ]
#if os(iOS)
            // Create a lens position control if the device supports setting a custom position.
            if device.isLockingFocusWithCustomLensPositionSupported {
                // Create a slider to adjust the value from 0 to 1.
                let lensSlider = AVCaptureSlider("Lens Position", symbolName: "circle.dotted.circle", in: 0...1)
                // Perform the slider's action on the session queue.
                lensSlider.setActionQueue(sessionQueue) { lensPosition in
                    do {
                        try device.lockForConfiguration()
                        device.setFocusModeLocked(lensPosition: lensPosition)
                        device.unlockForConfiguration()
                    } catch {
                        logger.info("Unable to change the lens position: \(error)")
                    }
                }
                // Add the slider the controls array.
                controls.append(lensSlider)
            }
#endif
            // Store the controls for future use.
            controlsMap[device.uniqueID] = controls
            return controls
        }

        // Return the previously created controls.
        return controls
    }

    // MARK: - Capture mode selection

    /// Changes the mode of capture, which can be `photo` or `video`.
    ///
    /// - Parameter `captureMode`: The capture mode to enable.
    func setCaptureMode(_ captureMode: CaptureMode) throws {
        // Update the internal capture mode value before performing the session configuration.
        self.captureMode = captureMode

        // Change the configuration atomically.
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // Configure the capture session for the selected capture mode.
        switch captureMode {
            case .photo:
                // The app needs to remove the movie capture output to perform Live Photo capture.
                captureSession.sessionPreset = .photo
                captureSession.removeOutput(movieCapture.output)
            case .video:
                captureSession.sessionPreset = .high
                try addOutput(movieCapture.output)
                if isHDRVideoEnabled {
                    setHDRVideoEnabled(true)
                }
        }

        // Update the advertised capabilities after reconfiguration.
        updateCaptureCapabilities()
    }

    // MARK: - Device selection

    /// Changes the capture device that provides video input.
    ///
    /// The app calls this method in response to the user tapping the button in the UI to change cameras.
    /// The implementation switches between the front and back cameras and, in iPadOS,
    /// connected external cameras.
    func selectNextVideoDevice() throws {
        // Current active device
        guard let currentDevice else {
            throw AVError(_nsError: .init(domain: String(describing: self), code: 0))
        }
        // The array of available video capture devices.
        let videoDevices = deviceLookup.cameras

        // Find the index of the currently selected video device.
        let selectedIndex = videoDevices.firstIndex(of: currentDevice) ?? 0
        // Get the next index.
        var nextIndex = selectedIndex + 1
        // Wrap around if the next index is invalid.
        if nextIndex == videoDevices.endIndex {
            nextIndex = 0
        }

        let nextDevice = videoDevices[nextIndex]
        // Change the session's active capture device.
        changeCaptureDevice(to: nextDevice)

        // The app only calls this method in response to the user requesting to switch cameras.
        // Set the new selection as the user's preferred camera.
        AVCaptureDevice.userPreferredCamera = nextDevice
    }

    // Changes the device the service uses for video capture.
    private func changeCaptureDevice(to device: AVCaptureDevice) {
        // The service must have a valid video input prior to calling this method.
        guard let currentInput = activeVideoInput else { fatalError() }

        // Bracket the following configuration in a begin/commit configuration pair.
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        // Remove the existing video input before attempting to connect a new one.
        captureSession.removeInput(currentInput)
        do {
            // Attempt to connect a new input and device to the capture session.
            activeVideoInput = try addInput(for: device)
            // Configure capture controls for new device selection.
            configureControls(for: device)
            // Register for device observations.
            observeSubjectAreaChanges(of: device)
            // Update the service's advertised capabilities.
            updateCaptureCapabilities()
        } catch {
            // Reconnect the existing camera on failure.
            captureSession.addInput(currentInput)
        }
    }

    /// Monitors changes to the system's preferred camera selection.
    ///
    /// iPadOS supports external cameras. When someone connects an external camera to their iPad,
    /// they're signaling the intent to use the device. The system responds by updating the
    /// system-preferred camera (SPC) selection to this new device. When this occurs, if the SPC
    /// isn't the currently selected camera, switch to the new device.
    private func monitorSystemPreferredCamera() {
        Task {
            // An object monitors changes to system-preferred camera (SPC) value.
            for await camera in systemPreferredCamera.changes {
                // If the SPC isn't the currently selected camera, attempt to change to that device.
                if let camera, currentDevice != camera {
                    logger.debug("Switching camera selection to the system-preferred camera.")
                    changeCaptureDevice(to: camera)
                }
            }
        }
    }

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        // Access the capture session's connected preview layer.
        guard let previewLayer = captureSession.connections.compactMap({ $0.videoPreviewLayer }).first else {
            fatalError("The app is misconfigured. The capture session should have a connection to a preview layer.")
        }
        return previewLayer
    }

    // MARK: - Automatic focus and exposure

    /// Performs a one-time automatic focus and expose operation.
    ///
    /// The app calls this method as the result of a person tapping on the preview area.
    func focusAndExpose(at point: CGPoint) {
        // The point this call receives is in view-space coordinates. Convert this point to device coordinates.
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
        do {
            // Perform a user-initiated focus and expose.
            try focusAndExpose(at: devicePoint, isUserInitiated: true)
        } catch {
            logger.debug("Unable to perform focus and exposure operation. \(error)")
        }
    }

    // Observe notifications of type `subjectAreaDidChangeNotification` for the specified device.
    private func observeSubjectAreaChanges(of device: AVCaptureDevice) {
        // Cancel the previous observation task.
        subjectAreaChangeTask?.cancel()
#if os(iOS)
        subjectAreaChangeTask = Task {
            // Signal true when this notification occurs.
            for await _ in NotificationCenter.default.notifications(named: AVCaptureDevice.subjectAreaDidChangeNotification, object: device).compactMap({ _ in true }) {
                // Perform a system-initiated focus and expose.
                try? focusAndExpose(at: CGPoint(x: 0.5, y: 0.5), isUserInitiated: false)
            }
        }
#endif
    }
    private var subjectAreaChangeTask: Task<Void, Never>?

    private func focusAndExpose(at devicePoint: CGPoint, isUserInitiated: Bool) throws {
        // Configure the current device.
       guard let device = currentDevice else {
           throw AVError(.sessionConfigurationChanged)
        }

        // The following mode and point of interest configuration requires obtaining an exclusive lock on the device.
        try device.lockForConfiguration()

        let focusMode = isUserInitiated ? AVCaptureDevice.FocusMode.autoFocus : .continuousAutoFocus
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
            device.focusPointOfInterest = devicePoint
            device.focusMode = focusMode
        }

        let exposureMode = isUserInitiated ? AVCaptureDevice.ExposureMode.autoExpose : .continuousAutoExposure
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
            device.exposurePointOfInterest = devicePoint
            device.exposureMode = exposureMode
        }

#if os(iOS)
        // Enable subject-area change monitoring when performing a user-initiated automatic focus and exposure operation.
        // If this method enables change monitoring, when the device's subject area changes, the app calls this method a
        // second time and resets the device to continuous automatic focus and exposure.
        device.isSubjectAreaChangeMonitoringEnabled = isUserInitiated
#endif

        // Release the lock.
        device.unlockForConfiguration()
    }

    // MARK: - Photo capture
    func capturePhoto(with features: PhotoFeatures) async throws -> Photo {
        try await photoCapture.capturePhoto(with: features)
    }

    // MARK: - Movie capture
    /// Starts recording video. The video records until the user stops recording,
    /// which calls the following `stopRecording()` method.
    func startRecording() {
        movieCapture.startRecording()
    }

    /// Stops the recording and returns the captured movie.
    func stopRecording() async throws -> Movie {
        try await movieCapture.stopRecording()
    }

    /// Audio samples stream from the existing `captureSession`.
    ///
    /// Use this for meters/waveforms. Keep the returned stream alive for continuous updates.
//    func makeAudioSampleBufferStream() async -> AsyncStream<CMSampleBuffer> {
//        // Verify audio setup before creating stream
//        verifyAudioConfiguration()
//        
//        return AsyncStream { continuation in
//            // Single-consumer semantics.
//            self.audioStreamContinuation = continuation
//
//            // Install delegate once.
//            if self.audioSampleDelegate == nil {
//                let delegate = AudioSampleOutputDelegate { [weak self] sbuf in
//                    // Hop onto the actor to yield.
//                    Task { await self?.yieldAudioSample(sbuf) }
//                }
//                self.audioSampleDelegate = delegate
//                self.audioDataOutput.setSampleBufferDelegate(
//                    delegate,
//                    queue: self.audioOutputQueue
//                )
//            }
//
//            continuation.onTermination = { [weak self] _ in
//                Task { await self?.clearAudioStream() }
//            }
//        }
//    }
    
    /// Verifies that the audio input is properly connected to the audio data output.
    private func verifyAudioConfiguration() {
        guard let audioInput = activeAudioInput else {
            logger.error("No active audio input configured!")
            return
        }
        
        logger.debug("Active audio device: \(audioInput.device.localizedName)")
        
        // Check if the audio data output has a valid connection
        if let audioConnection = audioDataOutput.connection(with: .audio) {
            logger.debug("Audio connection found - enabled: \(audioConnection.isEnabled), active: \(audioConnection.isActive)")
            
            if !audioConnection.isEnabled {
                logger.warning("Audio connection is disabled. Attempting to enable...")
                audioConnection.isEnabled = true
            }
        } else {
            logger.error("⚠️ NO AUDIO CONNECTION - This is why you're getting zeros!")
            logger.error("Audio input ports: \(audioInput.ports)")
            logger.error("Audio output connections: \(self.audioDataOutput.connections)")
        }
        
        // Log all session inputs and outputs for debugging
        logger.debug("Session inputs: \(self.captureSession.inputs.count)")
        logger.debug("Session outputs: \(self.captureSession.outputs.count)")
    }

    private func yieldAudioSample(_ sbuf: CMSampleBuffer) {
        audioStreamContinuation?.yield(sbuf)
    }

    private func clearAudioStream() {
        audioStreamContinuation = nil
        // Keep the delegate installed to avoid churn; it’s cheap and avoids reconfiguration.
    }

    // Adds an input to the capture session to connect the specified capture device.
    @discardableResult
    internal func addInput(for device: AVCaptureDevice) throws -> AVCaptureDeviceInput {
        let input = try AVCaptureDeviceInput(device: device)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.addInputFailed
        }
        return input
    }

    // Adds an output to the capture session to connect the specified capture device, if allowed.
    private func addOutput(_ output: AVCaptureOutput) throws {
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            throw CameraError.addOutputFailed
        }
    }

    // The device for the active video input.
    private var currentDevice: AVCaptureDevice? {
       get { activeVideoInput?.device }
    }

    var currentAudioDevice: AVCaptureDevice? {
        get { activeAudioInput?.device }
    }

    /// Sets whether the app captures HDR video.
    func setHDRVideoEnabled(_ isEnabled: Bool) {
        // Bracket the following configuration in a begin/commit configuration pair.
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        do {
            // If the current device provides a 10-bit HDR format, enable it for use.
            if isEnabled, let currentDevice, let format = currentDevice.activeFormat10BitVariant {
                try currentDevice.lockForConfiguration()
                currentDevice.activeFormat = format
                currentDevice.unlockForConfiguration()
                isHDRVideoEnabled = true
            } else {
                captureSession.sessionPreset = .high
                isHDRVideoEnabled = false
            }
        } catch {
            logger.error("Unable to obtain lock on device and can't enable HDR video capture.")
        }
    }

    // MARK: - Internal state management
    /// Updates the state of the actor to ensure its advertised capabilities are accurate.
    ///
    /// When the capture session changes, such as changing modes or input devices, the service
    /// calls this method to update its configuration and capabilities. The app uses this state to
    /// determine which features to enable in the user interface.
    internal func updateCaptureCapabilities() {
        // Current device has to be set
        guard let currentDevice else { return }

        // Update the output service configuration.
        outputServices.forEach { $0.updateConfiguration(for: currentDevice) }
        // Set the capture service's capabilities for the selected mode.
        switch captureMode {
            case .photo:
                captureCapabilities = photoCapture.capabilities
            case .video:
                captureCapabilities = movieCapture.capabilities
        }
    }

    /// Merge the `captureActivity` values of the photo and movie capture services,
    /// and assign the value to the actor's property.`
    private func observeOutputServices() {
        Publishers.Merge(photoCapture.$captureActivity, movieCapture.$captureActivity)
            .assign(to: &$captureActivity)
    }

    /// Observe when capture control enter and exit a fullscreen appearance.
    private func observeCaptureControlsState() {
        controlsDelegate.$isShowingFullscreenControls
            .assign(to: &$isShowingFullscreenControls)
    }

    /// Observe capture-related notifications.
    private func observeNotifications() {

        Task {
            // Await notification of the end of an interruption.
            for await _ in NotificationCenter.default.notifications(named: AVCaptureSession.interruptionEndedNotification) {
                isInterrupted = false
            }
        }
    }
}
