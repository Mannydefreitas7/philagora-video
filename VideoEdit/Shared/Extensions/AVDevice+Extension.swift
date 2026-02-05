//
//  AVDevice+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import AVFoundation
import SwiftUI

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
        AnyShape(.rect(cornerRadius: .extraLarge, style: .continuous)) :
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

}

extension AVDevice {

    static var placeholder: Self {
        .init(id: .uuid, kind: .video, name: .unknown, isOn: false, device: nil)
    }

    static private var defaultCamera: Self {

        if let systemCamera = DeviceLookup.defaultCamera {
            let defaultCameraDevice = AVDevice(systemCamera)
            return defaultCameraDevice
        }

        if let first = DeviceLookup.shared.cameras.first {
            let defaultCameraDevice = AVDevice(first)
            return defaultCameraDevice
        }

        return Self.placeholder
    }

    static private var defaultMicrophone: Self {
        if let systemMicrophone = DeviceLookup.defaultMic {
            let defaultMicrophoneDevice = AVDevice(systemMicrophone)
            return defaultMicrophoneDevice
        }

        if let first = DeviceLookup.shared.microphones.first {
            let defaultMicrophoneDevice = AVDevice(first)
            return defaultMicrophoneDevice
        }

        return Self.placeholder
    }

    static func defaultDevice(_ kind: Kind) -> Self {
        // Kind is camera
        return kind == .video ? .defaultCamera : .defaultMicrophone
    }

}


extension AVDevice {

    @MainActor
    @Observable
    class ViewModel {

        @Published var isOn: Bool = false


    }

}
