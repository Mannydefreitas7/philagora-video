/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An object that retrieves camera and microphone devices.
*/

import AVFoundation
import Combine

/// An object that retrieves camera and microphone devices.
final class DeviceLookup {
    
    // Discovery sessions to find the front and back cameras, and external cameras in iPadOS.
    private let frontCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let backCameraDiscoverySession: AVCaptureDevice.DiscoverySession
    private let externalCameraDiscoverSession: AVCaptureDevice.DiscoverySession
    private let audioDiscoverySession: AVCaptureDevice.DiscoverySession

    init() {
        backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
                .builtInWideAngleCamera
        ],
                                                                      mediaType: .video,
                                                                      position: .back)
        frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
           // .builtInTrueDepthCamera,
                .builtInWideAngleCamera],
                                                                       mediaType: .video,
                                                                       position: .front)
        externalCameraDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.external],
                                                                         mediaType: .video,
                                                                         position: .unspecified)

        audioDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.microphone],
                                                                 mediaType: .audio,
                                                                 position: .unspecified)

        // If the host doesn't currently define a system-preferred camera device, set the user's preferred selection to the back camera.
        if AVCaptureDevice.systemPreferredCamera == nil {
            AVCaptureDevice.userPreferredCamera = backCameraDiscoverySession.devices.first
        }
    }
    
    /// Returns the system-preferred camera for the host system.
    var defaultCamera: AVCaptureDevice {
        get throws {
            guard let videoDevice = AVCaptureDevice.systemPreferredCamera else {
                throw CameraError.videoDeviceUnavailable
            }
            return videoDevice
        }
    }
    
    /// Returns the default microphone for the device on which the app runs.
    var defaultMic: AVCaptureDevice {
        get throws {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                throw CameraError.audioDeviceUnavailable
            }
            return audioDevice
        }
    }

    var cameras: [AVCaptureDevice] {
        // Populate the cameras array with the available cameras.
        var cameras: [AVCaptureDevice] = []
        if let backCamera = backCameraDiscoverySession.devices.first {
            cameras.append(backCamera)
        }
        if let frontCamera = frontCameraDiscoverySession.devices.first {
            cameras.append(frontCamera)
        }
        // iPadOS supports connecting external cameras.
        if let externalCamera = externalCameraDiscoverSession.devices.first {
            cameras.append(externalCamera)
        }

#if !targetEnvironment(simulator)
        if cameras.isEmpty {
            fatalError("No camera devices are found on this system.")
        }
#endif
        return cameras
    }


    var microphones : [AVCaptureDevice] {
        let devices = audioDiscoverySession.devices
        logger.info("devices \(devices)")
        return devices
    }
}


extension DeviceLookup {

    static var defaultCamera: AVDeviceInfo {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return .init(id: UUID().uuidString, kind: .video, name: "Unknown", isOn: false)
        }
        return .init(
            id: device.uniqueID,
            kind: .video,
            name: device.localizedName,
            isOn: false
         )
    }

    static var defaultMicrophone: AVDeviceInfo {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            return .init(id: UUID().uuidString, kind: .audio, name: "Unknown", isOn: false)
        }
        return .init(
            id: device.uniqueID,
            kind: .audio,
            name: device.localizedName,
            isOn: false
        )
    }

}
