//
//  AVDevice+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import AVFoundation
import SwiftUI
import SFSafeSymbols

extension AVDevice {

    // Computed properties
    var shape: AnyShape { shape(for: self) }
    //
    var isExternal: Bool {
        guard let device else { return false }
        return !device.manufacturer.lowercased().contains("apple")
    }
    //
    var input: AVCaptureDeviceInput {
        get throws {
            guard let device else { throw AVError(.deviceNotConnected) }
            return try AVCaptureDeviceInput(device: device)
        }
    }

    private func shape(for device: Self) -> AnyShape {
        return device.isOn || device.showSettings ?
        AnyShape(.rect(cornerRadius: kind == .audio ? .extraLarge : .large, style: .continuous)) :
        AnyShape(.capsule)
    }

    var videoDataOutput: AVCaptureVideoDataOutput {
        get { .init() }
    }

    var audioDataOutput: AVCaptureAudioDataOutput {
        get { .init() }
    }

    var recordingFileOutput: AVCaptureMovieFileOutput {
        get { .init() }
    }

    var thumbnail: Image {
        if isExternal {
            return Image(kind == .video ? .goPro : .microphone15535673)
        }
        return Image(.imac)
    }

    var symbol: SFSymbol {
        return isExternal ? .webCamera : .video
    }

}

extension AVDevice {

    static var placeholder: Self {
        .init(id: .uuid, kind: .video, name: .unknown, isOn: false, device: nil)
    }

    static private var defaultCamera: Self {

        if let systemCamera = AVCaptureDevice.userPreferredCamera {
            let defaultCameraDevice = AVDevice(systemCamera)
            return defaultCameraDevice
        }

        if let first = DeviceDiscovery.shared.cameras.first {
            return first
        }

        return Self.placeholder
    }

    static private var defaultMicrophone: Self {
        if let systemMicrophone = AVCaptureDevice.default(for: .audio) {
            let defaultMicrophoneDevice = AVDevice(systemMicrophone)
            return defaultMicrophoneDevice
        }

        if let first = DeviceDiscovery.shared.microphones.first {
            return first
        }

        return Self.placeholder
    }

    static func defaultDevice(_ kind: Kind) -> Self {
        // Kind is camera
        return kind == .video ? .defaultCamera : .defaultMicrophone
    }

}
