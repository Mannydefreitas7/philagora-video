//
//  AVDeviceInfo.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//
import AVFoundation

struct AVDevice: Identifiable, Hashable, Equatable {
    enum Kind: Equatable { case video, audio }

    var id: String
    var kind: Kind
    var name: String
    var isOn: Bool
    var showSettings: Bool = false
    var volume: Double = 0
    var device: AVCaptureDevice?
}
