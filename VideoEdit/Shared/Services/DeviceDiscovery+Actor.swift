//
//  DeviceDiscovery+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-03.
//
import Foundation
import AVFoundation

actor DeviceDiscovery {

    static let shared = DeviceDiscovery()

    nonisolated
    var microphones: [AVDevice] {
        get { discoverDevices(.audio) }
    }

    nonisolated
    var cameras: [AVDevice] {
        get { discoverDevices(.video) }
    }

    private init() { }

    #if os(iOS)
     func discoverDevices() async {
        let video = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .continuityCamera, .deskViewCamera],
            mediaType: .video,
            position: .unspecified
        )
        let audio = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInMicrophone],
            mediaType: .audio,
            position: .unspecified
        )
        self.microphones = audio.devices
        self.cameras = video.devices
    }
    #endif

    #if os(macOS)
    nonisolated
    func discoverDevices(_ type: Kind) -> [AVDevice] {
        let video = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .continuityCamera, .deskViewCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        let audio = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone],
            mediaType: .audio,
            position: .unspecified
        )
         let microphones = audio.devices.map { AVDevice($0) }
         let cameras = video.devices.map { AVDevice($0) }
        return type == .video ? cameras : microphones
    }
    #endif

    static var defaultCamera: AVDevice {
        return AVDevice.defaultDevice(.video)
    }

    static var defaultMicrophone: AVDevice {
        return AVDevice.defaultDevice(.audio)
    }

     func getDevice(withUniqueID id: String) -> AVDevice? {
        guard let device = AVCaptureDevice(uniqueID: id) else {
            return nil
        }
        return .init(device)
    }

}
