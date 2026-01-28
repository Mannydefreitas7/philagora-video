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
        return device.isOn || device.showSettings ? AnyShape(.rect(cornerRadius: .extraLarge, style: .continuous)) : AnyShape(
            .capsule
        )
    }
    var thumbnail: Image {
        if isExternal {
            return Image(kind == .video ? .goPro : .microphone15535673)
        }
        return Image(.imac)
    }

    static func defaultDevice(_ kind: Kind) -> Self {
        let _default = kind == .video ? DeviceLookup.defaultCamera : DeviceLookup.defaultMicrophone
        let device: Self = _default
        return device
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
}
