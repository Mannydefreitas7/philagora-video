//
//  CameraInfo.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-17.
//
import Foundation
import AVFoundation

struct CameraInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let position: AVCaptureDevice.Position
    let deviceType: AVCaptureDevice.DeviceType
    let device: AVCaptureDevice
}
