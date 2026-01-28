//
//  EnvironmentValues.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//


import SwiftUI
import SwiftUIIntrospect

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
    var window: WindowBox {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }

    @Entry
    var styleMask: NSWindow.StyleMask = .unifiedTitleAndToolbar

    /// Live microphone input level normalized to 0.0...1.0
    @Entry
    var audioInputWave: Float = .zero

    /// Rolling history of microphone levels normalized to 0.0...1.0
    @Entry
    var audioInputWaveHistory: [Double] = []

    @Entry
    var audioDevices: [AVDeviceInfo] = []

    @Entry
    var videoDevices: [AVDeviceInfo] = []

    @Entry
    var isCameraOn: Bool = false

    @Entry
    var isMicrophoneOn: Bool = false

}

private struct WindowStyleMask: ViewModifier {
    @Binding var mask: NSWindow.StyleMask

    func body(content: Content) -> some View {

        return content
            .introspect(.window, on: .macOS(.v26)) { window in

                let panel = NSPanel()

                panel.animationBehavior = .utilityWindow
                panel.backgroundColor = .clear
                panel.isMovableByWindowBackground = true
                panel.styleMask = mask

        //        panel.becomesKeyOnlyIfNeeded = true
                panel.contentView = window.contentView

             //   window.styleMask = mask
            }
            .environment(\.styleMask, mask)
    }
}

extension View {
    /// Injects a live `Binding<NSWindow.StyleMask>` for the current window into the environment.
    /// Also keeps `EnvironmentValues.styleMask` in sync with the binding's value.
    func styleMask(_ styles: NSWindow.StyleMask) -> some View {
        modifier(WindowStyleMask(mask: .constant(styles)))
    }

    func styleMask(_ styles: Binding<NSWindow.StyleMask>) -> some View {
        modifier(WindowStyleMask(mask: styles))
    }
}

extension NSWindow.StyleMask {
    /// A common "standard" window mask for document-style windows.
    static let standardDocumentWindow: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable,
        .resizable
    ]

    /// A common "utility" window mask (no resize by default).
    static let standardUtilityWindow: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable
    ]

    /// Titled + closable + miniaturizable, but not resizable.
    static let titledNonResizable: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable
    ]
}
