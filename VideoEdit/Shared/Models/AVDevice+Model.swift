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
}


