//
//  WindowStyleMask.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import SwiftUI
import SwiftUIIntrospect

struct WindowStyleMask: ViewModifier {
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
