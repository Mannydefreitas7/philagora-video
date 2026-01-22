//
//  DeviceInfo+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 1/18/26.
//
import SwiftUI
import AVFoundation

struct DeviceInfo: Identifiable, Equatable {
    enum Kind: Equatable { case video, audio }

    let id: String
    var kind: Kind
    var name: String
    var position: AVCaptureDevice.Position
    var isOn: Bool
    var showSettings: Bool
    var volume: Double = 0

    var shape: AnyShape { shape(for: self) }
    var toolGroup: ToolGroup = .options

    private func shape(for device: Self) -> AnyShape {
        return device.isOn || device.showSettings ? AnyShape(.rect(cornerRadius: .large, style: .continuous)) : AnyShape(
            .capsule
        )
    }
}
