//
//  MicrophoneInfo+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-17.
//
import Foundation
import AVFoundation

struct MicrophoneInfo: Hashable, Identifiable {

    let id: String
    let name: String
    let position: AVCaptureDevice.Position
    let deviceType: AVCaptureDevice.DeviceType
    let device: AVCaptureDevice

}
