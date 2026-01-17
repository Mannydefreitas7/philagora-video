//
//  ScreenOverlayWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-14.
//

import SwiftUI
import ScreenCaptureKit
import SFSafeSymbols
import SwiftUIIntrospect

struct FloatingWindow<Content: View>: Scene {

    var title: String? = nil
    var id: Constants.Window
    var content: () -> Content

    var body: some Scene {

        Window(title ?? "", id: .window(id)) {
            content()
                .background(.clear)
                .edgesIgnoringSafeArea(.all)
                .introspect(.window, on: .macOS(.v26), scope: .ancestor) { window in
                    window.backingType = .buffered
                    window.animationBehavior = .utilityWindow
                    window.backgroundColor = .clear
                    window.isMovableByWindowBackground = true
                    window.contentView?.needsDisplay = true
                    window.isReleasedWhenClosed = true
                    window.styleMask = [.borderless, .resizable, .utilityWindow]
                }
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .windowBackgroundDragBehavior(.enabled)
        .windowLevel(.floating)
        .windowResizability(.contentSize)
        .windowStyle(.plain)
    }
}

