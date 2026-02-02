//
//  DeviceInfo+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//
import SwiftUI
import AVFoundation
//


extension AVDeviceInfo {
    private func shape(for device: AVDeviceInfo) -> AnyShape {
        return device.isOn || device.showSettings ?
        AnyShape(.rect(cornerRadius: .extraLarge, style: .continuous)) :
        AnyShape(.capsule)
    }

    init (_ device: AVCaptureDevice) {
        self.id = device.uniqueID
        self.kind = device.deviceType == .microphone ? .audio : .video
        self.name = device.localizedName
        self.showSettings = false
        self.isOn = false
        self.device = device
    }

    var thumbnail: Image {
        if isExternal {
            return Image(kind == .video ? .goPro : .microphone15535673)
        }
        return Image(.imac)
    }

    static var placeholder: Self {
        .init(id: .uuid, kind: .video, name: .unknown, isOn: false, device: nil)
    }

    static var defaultCamera: Self {

        if let systemCamera = DeviceLookup.defaultCamera {
            let defaultCameraDevice = AVDeviceInfo(systemCamera)
            return defaultCameraDevice
        }

        if let first = DeviceLookup.shared.cameras.first {
            let defaultCameraDevice = AVDeviceInfo(first)
            return defaultCameraDevice
        }

        return placeholder
    }

    static var defaultMicrophone: Self {
        if let systemMicrophone = DeviceLookup.defaultMic {
            let defaultMicrophoneDevice = AVDeviceInfo(systemMicrophone)
            return defaultMicrophoneDevice
        }

        if let first = DeviceLookup.shared.microphones.first {
            let defaultMicrophoneDevice = AVDeviceInfo(first)
            return defaultMicrophoneDevice
        }
        
        return placeholder
    }

    static func defaultDevice(_ kind: Kind) -> Self {
        // Kind is camera
        return kind == .video ? self.defaultCamera : self.defaultMicrophone
    }
}

struct AVDeviceInfo: Identifiable, Hashable, Equatable {
    enum Kind: Equatable { case video, audio }

    var id: String
    var kind: Kind
    var name: String
    var isOn: Bool
    var showSettings: Bool = false
    var volume: Double = 0
    var device: AVCaptureDevice?
    var toolGroup: ToolGroup = .options
    // Computed properties
    var shape: AnyShape { shape(for: self) }
    var isExternal: Bool {
        guard let device else { return false }
        return !device.manufacturer.lowercased().contains("apple")
    }
    var input: AVCaptureDeviceInput? {
        guard let device else { return nil }
        return try? AVCaptureDeviceInput(device: device)
    }
}
