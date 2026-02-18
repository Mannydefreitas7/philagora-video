//
//  AVDeviceInfo.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import AVFoundation
import AppState

struct AVDevice: Identifiable, Hashable, Equatable {

    var id: String
    var kind: AVMediaType
    var name: String
    var isOn: Bool
    var showSettings: Bool = false
    var volume: Double = 0
    var device: AVCaptureDevice?
    var isMirrored: Bool = false
    var toolGroup: ToolGroup = .options

    init (id: String, kind: AVMediaType, name: String, isOn: Bool, device: AVCaptureDevice? = nil) {
        self.id = id
        self.kind = kind
        self.name = name
        self.showSettings = false
        self.isOn = isOn
        self.device = device
    }

    init (_ device: AVCaptureDevice) {
        self.id = device.uniqueID
        self.kind = device.deviceType == .microphone ? .audio : .video
        self.name = device.localizedName
        self.showSettings = false
        self.isOn = false
        self.device = device
    }

    init (from input: AVCaptureDeviceInput) {
        // Attempt to extract an associated device from the input
        let dev = input.device
        self.id = dev.uniqueID
        self.kind = dev.deviceType == .microphone ? .audio : .video
        self.name = dev.localizedName
        self.isOn = false
        self.showSettings = false
        self.volume = 0
        self.device = dev
        self.toolGroup = .options
    }
}

