//
//  AVCaptureAudio+Actors.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//

import AVFoundation
import Accelerate
import AVFAudio

struct AudioSample {
    let floatData: [Float]
    let level: Float
}

// Audio sample listener
actor AVAudioSampleListener {

    static let shared = AVAudioSampleListener()
    var delegate: Delegate?
    private let historyCapacity = 48
    private let smoothing = 0.75
    private let gain = max(0.1, 18)
    private var input: AVAudioInputNode?
    private let audioInstance = AVAudioApplication.shared
    private let audioEngine = AVAudioEngine()
    // 1. The configuration parameter for the FFT
    private let bufferSize = 8192
    // 2. The FFT configuration
    private var fftSetup: OpaquePointer?
    // 4. Store the results
    var fftMagnitudes = [Float](repeating: 0, count: .sampleAmount)
    // 5. Pick a subset of fftMagnitudes at regular intervals according to the downsampleFacto
    var downsampledMagnitudes: [Float] {
        fftMagnitudes.lazy.enumerated().compactMap { index, value in
            index.isMultiple(of: .downsampleFactor) ? value : nil
        }
    }


    @Published var audioLevel: Float = 0
    @Published var peakLevel: Float = 0
    @Published var time: AVAudioTime = .init()
    @Published var isMonitoring: Bool = false
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.audioLevel))
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    var level: Float { audioLevel }
    //

    internal func processSamples(_ samples: [Float]) {
        // Actor-isolated processing
        let rms = samples.reduce(0.0) { $0 + $1 * $1 } / Float(samples.count)
        audioLevel = 20 * log10(sqrt(rms))
    }

    func setup(using connection: AVCaptureConnection?) throws {
        guard let connection, connection.isActive else { return }
        connection.audioChannels.forEach {
            logger.info("\($0.averagePowerLevel) \($0.peakHoldLevel) \($0.volume)")
            peakLevel = $0.averagePowerLevel
        }
    }

    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let channelDataArray = channelData[0]
        let frameLength = Int(buffer.frameLength)
        // Calculate the average power level (amplitude)
        var totalPower: Float = 0.0
        for i in 0..<frameLength {
            totalPower += abs(channelDataArray[i])
        }
        let averagePower = totalPower / Float(frameLength)
        audioLevel = averagePower * 10
        // You can define a threshold to "detect sound"
        if averagePower > 0.01 {
             // Sound is being detected
        }
    }
    // The methods to be implemented
    func startMonitoring() async {
        // 1. Set up the input node from the audio engine
        let inputNode = audioEngine.inputNode
        // 2. Set up the input format from the audio engine
        let inputFormat = inputNode.inputFormat(forBus: 0)
        // 3. Set the FFT configuration
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, UInt(self.bufferSize), .FORWARD)
        // Listen to microphone input
        let audioStream = AsyncStream<AudioSample> { continuation in

            inputNode.installTap(onBus: 0, bufferSize: UInt32(bufferSize), format: inputFormat) { @Sendable buffer, _ in
                guard let floatData = buffer.floatChannelData else { return }
                // 1. Access the first audio channel
                let channelData = floatData[0]
                let frameCount = Int(buffer.frameLength)
                // Calculate the average power level (amplitude)
                var totalPower: Float = 0.0
                for i in 0..<frameCount {
                    totalPower += abs(channelData[i])
                }
                let averagePower = totalPower / Float(frameCount)
                let level = averagePower * 10
                // 2. Convert it into a Float array
                let data = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
                let audioSample = AudioSample(floatData: data, level: level)
                // 3. Yield into the stream
                continuation.yield(audioSample)
            }
        }

        do {
            // 1. Start the audioEngine
            try audioEngine.start()
            // 3. Retrieving the data from the audioStream
            for await sample in audioStream {
                // 4. For each buffer, compute the FFT and store the results
                self.fftMagnitudes = await self.performFFT(data: sample.floatData)
                self.audioLevel = sample.level
            }
            // 2. Update the property to monitor the state of the audioEngine
            isMonitoring = true
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
            return
        }
    }

    func stopMonitoring() {
        // 1. Stop the audioEngine
        audioEngine.stop()
        // 2. Remove the tap from the microphone input
        audioEngine.inputNode.removeTap(onBus: 0)
        // 3. Reset the fftMagnitudes array to all zeros, to clear the visualization
        fftMagnitudes = [Float](repeating: 0, count: .sampleAmount)
        // 4. Release the FFT setup free system memory
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
            fftSetup = nil
        }
        // 5. Update the audioEngine state property
        isMonitoring = false
    }

    func performFFT(data: [Float]) async -> [Float] {
        // Check the configuration
        guard let setup = fftSetup else {
            return [Float](repeating: 0, count: .sampleAmount)
        }

        // 1. Copy of the audio samples as float
        var realIn = data
        // 2. The imaginary part
        var imagIn = [Float](repeating: 0, count: bufferSize)
        // 3. The transformed values of the real data
        var realOut = [Float](repeating: 0, count: bufferSize)
        // The transformed values of the imaginary data
        var imagOut = [Float](repeating: 0, count: bufferSize)
        // Property storing computed magnitudes
        var magnitudes = [Float](repeating: 0, count: .sampleAmount)
        // 1. Nested loops to safely access all data
        realIn.withUnsafeMutableBufferPointer { realInPtr in
            imagIn.withUnsafeMutableBufferPointer { imagInPtr in
                realOut.withUnsafeMutableBufferPointer { realOutPtr in
                    imagOut.withUnsafeMutableBufferPointer { imagOutPtr in
                        // 2. Execute the Discrete Fourier Transform (DFT)
                        vDSP_DFT_Execute(setup, realInPtr.baseAddress!, imagInPtr.baseAddress!, realOutPtr.baseAddress!, imagOutPtr.baseAddress!)
                        // 3. Hold the DFT output
                        var complex = DSPSplitComplex(realp: realOutPtr.baseAddress!, imagp: imagOutPtr.baseAddress!)
                        // 4. Compute and save the magnitude of each frequency component
                        vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(bitPattern: .sampleAmount))
                    }
                }
            }
        }
        let _magnitudes = magnitudes.map { min($0, .magnitudeLimit) }
        return _magnitudes
    }
}

actor AVCaptureAudioService {

    static let shared = AVCaptureAudioService()
    // MARK: - outputs
    var audioFileCapture = AudioCapture()
    // MARK: - Audio listener
    let listener = AVAudioSampleListener.shared
    // MARK: - audio preview capture
    var audioPreviewCapture = AudioCapturePreview()
    // MARK: - device lookup service
    private let deviceLookup = DeviceLookup()
    // MARK: Data output
    private var audioDataOutput: AVCaptureAudioDataOutput = .init()
    // MARK: - application
    private let audioApplication = AVAudioApplication.shared
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureAudioOutput))
    // MARK: - access authorization
    var isAuthorized: Bool {
        let authorized = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        if !authorized {
            Task { return await AVCaptureDevice.requestAccess(for: .audio) }
        }
        return authorized
    }
    // MARK: - error message
    var errorMessage: String?

    @Published var downsampledMagnitudes: [Float] = []
    @Published var fftMagnitudes: [Float] = []
    @Published var level: Float = 0

    func initialize() async throws {
        guard isAuthorized, let delegate = await listener.delegate else {
            errorMessage = "Access to audio is required to use this feature."
            return
        }

        audioDataOutput.setSampleBufferDelegate(delegate, queue: sessionQueue)
        await listener.startMonitoring()
        ///
        downsampledMagnitudes = await listener.downsampledMagnitudes
        fftMagnitudes = await listener.fftMagnitudes
        level = await listener.level
    }

    func stop() async {
        await listener.stopMonitoring()
    }

    // MARK: - get audio devices
    func mapDevices(_ device: AVDeviceInfo? = nil) async throws -> [AVDeviceInfo] {
        let devices = devices()
        let selected = device?.id

        // updates camera devices
        let _devices = devices.map {
            AVDeviceInfo(
                id: $0.uniqueID,
                kind: .audio,
                name: $0.localizedName,
                isOn: $0.uniqueID == selected,
                showSettings: false,
                device: $0
            )
        }
        return _devices
    }

    // MARK: - get audio devices
    func devices() -> [AVCaptureDevice] {
        deviceLookup.microphones
    }
}
