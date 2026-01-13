import SwiftUI
import AVFoundation
import Combine
import CombineAsync


struct CameraInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let position: AVCaptureDevice.Position
    let deviceType: AVCaptureDevice.DeviceType
    let device: AVCaptureDevice
}

actor VCDeviceCameraManager {


    func loadAvailableCameras() -> [CameraInfo] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )

        return discoverySession.devices.map { device in
                CameraInfo(
                    id: device.uniqueID,
                    name: device.localizedName,
                    position: device.position,
                    deviceType: device.deviceType,
                    device: device
                )
            }
    }


    func start(_ session: AVCaptureSession, with selectedCamera: CameraInfo?) async throws -> AVCaptureDeviceInput {
        guard !session.isRunning else {
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Remove existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }

        // Add video input
        guard let camera = selectedCamera, let input = try? AVCaptureDeviceInput(device: camera.device), session.canAddInput(input) else {
            session.commitConfiguration()
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        session.addInput(input)
        await MainActor.run {
            session.startRunning()
        }
        return input
    }

    func stop(_ session: AVCaptureSession) async -> Void {
        guard session.isRunning else { return }

        await MainActor.run {
            session.stopRunning()
        }
    }


}

@MainActor
public final class CameraPreviewViewModel: ObservableObject {
    @Published var session = AVCaptureSession()

    private let cameraManager: Manager = .init()
    var cancellables: Set<AnyCancellable> = []

    @Published var isRunning = false
    @Published var availableCameras: [CameraInfo] = []
    @Published var selectedCamera: CameraInfo? =  nil
    @Published var isMirrored = true
    @Published var isConnected: Bool = false
    @Published var errorMessage: String? = nil
    @Published var error: Error? = nil
    @Published var isLoading: Bool = true

    // One serial queue for session ops + sample callbacks => no races.
    private let captureQueue = DispatchQueue(label: "camera.capture.queue")

    private var isConfigured = false
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()

    func addInputs() async {
      _ = await cameraManager.addAudioInput(session)
       _ = await cameraManager.addVideoInput(session)
    }

    init() {

        if !session.isRunning {
            session.startRunning()
        }

        Task {
            await loadCameras()
        }

        $session
            .compactMap { $0 }
            .map { $0.isRunning }
            .assign(to: \.isRunning, on: self)
            .store(in: &cancellables)


        $availableCameras
            .map { cameras in
                cameras.first {
                    $0.device.isConnected
               }
            }
            .assign(to: \.selectedCamera, on: self)
            .store(in: &cancellables)

        $selectedCamera
            .compactMap { $0?.device }
            .map { $0.isConnected  }
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)


        $availableCameras
            .map(\.isEmpty)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)

    }

    @Sendable func loadCameras() async -> Void {
        let cameras = await cameraManager.loadAvailableCameras()
        availableCameras = cameras.map {
            CameraInfo(
                id: $0.uniqueID,
                name: $0.localizedName,
                position: $0.position,
                deviceType: $0.deviceType,
                device: $0
            )
        }
        print("Available Cameras: \(availableCameras)")
    }

    func start(_ device: CameraInfo? = nil) async {
        do {
            videoInput =
            try await cameraManager.start(session, with: device)
            await addInputs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop() async {
        videoInput = nil
        await cameraManager.stop(session)
    }

    func selectCamera(_ device: CameraInfo) async {
        selectedCamera = device
        if session.isRunning { await cameraManager.stop(session) }
        await start(device)
    }
}
