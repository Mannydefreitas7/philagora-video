//
//  View+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//

import SwiftUI


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

