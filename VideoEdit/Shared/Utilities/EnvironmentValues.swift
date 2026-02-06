//
//  EnvironmentValues.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//


import SwiftUI
import SwiftUIIntrospect
import AVFoundation

struct WindowBox {
    weak var value: NSWindow?
}

struct NSWindowEnvironmentKey: EnvironmentKey {
    typealias Value = WindowBox
    static var defaultValue = WindowBox(value: nil)
}

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct StyleMaskEnvironmentKey: EnvironmentKey {

    // Access current key window
    private static var currentKeyWindow: NSWindow? {
        guard let app = NSApp, let keyWindow = app.keyWindow, keyWindow.isKeyWindow else { return nil }
        return keyWindow
    }

    static let defaultValue: NSWindow.StyleMask = currentKeyWindow?.styleMask ?? []
}


extension EnvironmentValues {

    @Entry
    var window: WindowBox = .init()

    @Entry
    var isFullscreen: Bool = false

    @Entry
    var styleMask: NSWindow.StyleMask = .unifiedTitleAndToolbar

    /// Live microphone input level normalized to 0.0...1.0
    @Entry
    var audioInputWave: Float = .zero

    /// Rolling history of microphone levels normalized to 0.0...1.0
    @Entry
    var audioInputWaveHistory: [Double] = []

    @Entry
    var audioDevices: [AVDevice] = []

    @Entry
    var videoDevices: [AVDevice] = []

    @Entry
    var isCameraOn: Bool = false

    @Entry
    var isRecording: AVMediaType? = nil

    @Entry
    var isMicrophoneOn: Bool = false

    @Entry
    var isHoveringWindow: Bool = false

}


