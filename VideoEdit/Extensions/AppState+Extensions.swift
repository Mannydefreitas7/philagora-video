//
//  AppState+Extensions.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-19.
//

import SwiftUI
import AVFoundation
import CoreMedia
import Combine

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var videoURL: URL?
    @Published var currentTool: EditingTool = .none
    @Published var showRecordingSheet = false
    @Published var showExportSheet = false
    @Published var exportFormat: ExportFormat = .movie
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0

    // Capture view model
    @Published var captureViewModel: CaptureViewModel = .init()
    @Published var previewViewModel: CaptureViewModel = .init()

    // Crop settings
    @Published var cropRect: CGRect = .zero
    @Published var isCropping = false

    // Trim settings
    @Published var trimStart: Double = 0
    @Published var trimEnd: Double = 1

    // Recording settings
    @Published var recordMicrophone = true
    @Published var recordSystemAudio = false
    @Published var showCameraOverlay = false
    @Published var visualizeClicks = true
    @Published var recordingQuality: RecordingQuality = .high

    // GIF settings
    @Published var gifFrameRate: Int = 15
    @Published var gifLoopCount: Int = 0 // 0 = infinite
    @Published var gifScale: Double = 1.0
    @Published var gifOptimize = true

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .video, .mpeg4Movie, .quickTimeMovie, .gif]

        if panel.runModal() == .OK {
            videoURL = panel.url
            currentTool = .none
            cropRect = .zero
            trimStart = 0
            trimEnd = 1
        }
    }

    func saveFile(completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = exportFormat == .gif ? [.gif] : [.mpeg4Movie]
        panel.nameFieldStringValue = exportFormat == .gif ? "export.gif" : "export.mp4"

        if panel.runModal() == .OK {
            completion(panel.url)
        } else {
            completion(nil)
        }
    }
}


@MainActor
final class CaptureViewModel: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []

    // Published UI state
    @Published var status: CaptureStatus = .idle
    @Published var videoDevices: [DeviceInfo] = []
    @Published var audioDevices: [DeviceInfo] = []
    @Published var selectedVideoID: String?
    @Published var selectedAudioID: String?
    @Published var session: AVCaptureSession = .init()
    @Published var showRecordingButton: Bool = true

    @Published var selectedVideoDevice = DeviceInfo(
        id: "placeholder",
        kind: .video,
        name: "Not found",
        position: .unspecified,
        isOn: false,
        showSettings: false
    )

    @Published var selectedAudioDevice = DeviceInfo(
        id: "placeholder",
        kind: .audio,
        name: "Not found",
        position: .unspecified,
        isOn: false,
        showSettings: false
    )

    @Published var controlsBarViewModel: PlayerControlsView.ViewModel = .init()

    // The engine
    let engine = CaptureEngine()

    init() {
        // Set engine session
        session = engine.session
        // Forward the session to respective viewModels

        // Set video device when available
        $selectedVideoID
            .compactMap { $0 }
            .combineLatest($videoDevices)
            .map {
                let selectedID = $0
                let availableDevices = $1
                return availableDevices.first(where: { $0.id == selectedID })
            }
            .compactMap { $0 }
            .assign(to: \.camera, on: controlsBarViewModel)
            .store(in: &cancellables)

        // Set audio device when available
        $selectedAudioID
            .compactMap { $0 }
            .combineLatest($audioDevices)
            .map {
                let selectedID = $0
                let availableDevices = $1
                return availableDevices.first(where: { $0.id == selectedID })
            }
            .compactMap { $0 }
            .assign(to: \.microphone, on: controlsBarViewModel)
            .store(in: &cancellables)

    }

    // Modern observation tasks (async sequences)
    private var observationTasks: [Task<Void, Never>] = []


    // A box to allow passing CMSampleBuffer across concurrency domains when needed on macOS
    struct SampleBufferBox: @unchecked Sendable { let buffer: CMSampleBuffer }

    private var observers: [NSObjectProtocol] = []
    private var frameTask: Task<Void, Never>?
    private var audioTask: Task<Void, Never>?

    // Coalescer for hot device updates
    private var deviceChangeTask: Task<Void, Never>?

    func onAppear() async {
        installObservers(for: engine.session)
        status = .configuring

        // Permissions
        let ok = await engine.requestPermissions()
        guard ok else {
            status = .unauthorized
            return
        }

        // Initial discovery + configure + start
        await refreshDeviceLists(keepSelectionIfPossible: true)
        do {
            try await configureAndStart()
            status = .running
            await startConsumingStreams()
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    func onDisappear() {
        observationTasks.forEach { $0.cancel() }
        observationTasks.removeAll()

        deviceChangeTask?.cancel()
        deviceChangeTask = nil

        frameTask?.cancel()
        frameTask = nil

        audioTask?.cancel()
        audioTask = nil

        Task { await engine.stopRunning() }
        status = .stopped
    }

    func selectVideo(id: String) async {
        selectedVideoID = id
        await engine.setSelection(videoID: id, audioID: selectedAudioID)
        do {
            try await engine.configureSession()
            session = engine.session
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    func selectAudio(id: String) async {
        selectedAudioID = id
        await engine.setSelection(videoID: selectedVideoID, audioID: id)
        do {
            try await engine.configureSession()
            session = engine.session
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    func start() async {
        do {
            try await configureAndStart()
            status = .running
            await startConsumingStreams()
            session = engine.session
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    func stop() async {
        await engine.stopRunning()
        status = .stopped
    }

    // MARK: - Internals

    private func configureAndStart() async throws {
        await engine.setSelection(videoID: selectedVideoID, audioID: selectedAudioID)
        try await engine.configureSession()
        await configureAudioSessionForCapture()
        await engine.startRunning()
    }

    private func refreshDeviceLists(keepSelectionIfPossible: Bool) async {
        let v = await engine.refreshVideoDevices()
        let a = await engine.refreshAudioDevices()

        let vInfos = v.map {
            DeviceInfo(
                id: $0.uniqueID,
                kind: .video,
                name: $0.localizedName,
                position: $0.position,
                isOn: false,
                showSettings: false
            )
        }
        let aInfos = a.map {
            DeviceInfo(id: $0.uniqueID, kind: .audio, name: $0.localizedName, position: $0.position, isOn: false, showSettings: false)
        }

        videoDevices = vInfos
        audioDevices = aInfos

        let current = await engine.currentSelection()

        // Preserve selection if possible, else choose defaults
        if keepSelectionIfPossible,
           let vid = current.videoID,
           vInfos.contains(where: { $0.id == vid }) {
            selectedVideoID = vid
        } else {
            selectedVideoID = vInfos.first(where: { $0.position == .back })?.id ?? vInfos.first?.id
        }

        if keepSelectionIfPossible,
           let aid = current.audioID,
           aInfos.contains(where: { $0.id == aid }) {
            selectedAudioID = aid
        } else {
            selectedAudioID = aInfos.first?.id
        }

        await engine.setSelection(videoID: selectedVideoID, audioID: selectedAudioID)
    }

    private func installObservers(for session: AVCaptureSession) {
        let nc = NotificationCenter.default
        // Hot device updates (coalesced)
        observationTasks.append(Task { @MainActor in
            for await _ in nc.notifications(named: AVCaptureDevice.wasConnectedNotification) {
                coalesceDeviceChange()
            }
        })

        observationTasks.append(Task { @MainActor in
            for await _ in nc.notifications(named: AVCaptureDevice.wasDisconnectedNotification) {
                coalesceDeviceChange()
            }
        })

        // Capture session interruptions
        observationTasks.append(
            Task { @MainActor in
                for await _ in nc.notifications(named: AVCaptureSession.wasInterruptedNotification) {
                    status = .interrupted(reason: .mediaDiscontinuity)
                }
            })

        observationTasks.append(Task { @MainActor in
            for await _ in nc.notifications(named: AVCaptureSession.interruptionEndedNotification) {
                do {
                    try await configureAndStart()
                    status = .running
                } catch {
                    status = .failed(message: String(describing: error))
                }
            }
        })

        // Runtime errors (optionally recover from mediaServicesWereReset)
        observationTasks.append(Task { @MainActor in
            for await note in nc.notifications(named: AVCaptureSession.runtimeErrorNotification) {
                let err = note.userInfo?[AVCaptureSessionErrorKey] as? NSError
                status = .failed(message: err?.localizedDescription ?? "AVCaptureSession runtime error")

                if let avErr = err as? AVError, avErr.code == .mediaDiscontinuity {
                    do {
                        try await configureAndStart()
                        status = .running
                    } catch {
                        status = .failed(message: String(describing: error))
                    }
                }
            }
        })

    }

    private func coalesceDeviceChange(delayNanoseconds: UInt64 = 200_000_000) {
        deviceChangeTask?.cancel()
        deviceChangeTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            guard !Task.isCancelled else { return }
            await self.handleDeviceChange()
        }
    }


    private func handleDeviceChange() async {
        await refreshDeviceLists(keepSelectionIfPossible: true)
        do {
            try await engine.configureSession()
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    private func handleAudioRouteChange() async {
        // Route changes may affect available mic inputs.
        await refreshDeviceLists(keepSelectionIfPossible: true)
        do {
            try await configureAndStart()
            status = .running
        } catch {
            status = .failed(message: String(describing: error))
        }
    }

    private func configureAudioSessionForCapture() async {
#if os(iOS)
        // Make this match your needs (bluetooth, speaker, etc.)
        // This runs on main actor; AVAudioSession expects main-thread friendliness.
        let a = AVAudioSession.sharedInstance()
        do {
            try a.setCategory(.playAndRecord,
                              mode: .videoRecording,
                              options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try a.setActive(true, options: [])
        } catch {
            status = .failed(message: "AVAudioSession error: \(error)")
        }
#else
        // AVAudioSession is unavailable on macOS; nothing to configure here.
        return
#endif
    }

    private func startConsumingStreams() async {
        // Video frames
        if frameTask == nil {
            let stream = await engine.makeVideoSampleBufferStream()
            frameTask = Task { @MainActor in
                for await sampleBuffer in stream {
                    if Task.isCancelled { break }
                    // Handle sampleBuffer on the main actor to avoid Sendable crossing on macOS
                    _ = sampleBuffer
                }
            }
        }

        // Audio samples (optional)
        if audioTask == nil {
            let stream = await engine.makeAudioSampleBufferStream()
            audioTask = Task { @MainActor in
                for await sampleBuffer in stream {
                    if Task.isCancelled { break }
                    // Handle audio sampleBuffer on the main actor to avoid Sendable crossing on macOS
                    _ = sampleBuffer
                }
            }
        }
    }
}
