//
//  AVCaptureVideo+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-29.
//
import AVFoundation

actor AVCaptureVideoService {

    static let shared = AVCaptureVideoService()

    // MARK: - outputs
    var cameraCapture = MovieCapture()
    // MARK: - device lookup service
    private let deviceLookup = DeviceLookup()
    // MARK: - application
    private let audioApplication = AVAudioApplication.shared
    // MARK: - error message
    var errorMessage: String?
    //
    private var videoDevices: [AVDeviceInfo] = []
    // A serial dispatch queue to use for capture control actions.
    private let sessionQueue = DispatchSerialQueue(label: .dispatchQueueKey(.captureVideoOutput))
    // MARK: - access authorization
    var isAuthorized: Bool {
        let authorized = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
        if !authorized {
            Task { return await AVCaptureDevice.requestAccess(for: .audio) }
        }
        return authorized
    }

    // MARK: - get audio devices
    func mapDevices(_ device: AVDeviceInfo? = nil) async throws -> [AVDeviceInfo] {
        let devices = devices()
        let selected = device?.id
        // updates camera devices
        let _videoDevices = devices.map {
            AVDeviceInfo(
                id: $0.uniqueID,
                kind: .video,
                name: $0.localizedName,
                isOn: $0.uniqueID == selected,
                showSettings: false,
                device: $0
            )
        }
        return _videoDevices
    }


    private func devices() -> [AVCaptureDevice] {
        deviceLookup.cameras
    }
    // Sets the session queue as the actor's executor.
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

}
