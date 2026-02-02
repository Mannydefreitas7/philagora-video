//
//  View+Modifiers.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//
import SwiftUI

struct WindowControlsModifier: ViewModifier {
    var hideClose: Bool = true
    var hideMinimize: Bool = true
    var hideZoom: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                WindowControlsAccessor(
                    hideClose: hideClose,
                    hideMinimize: hideMinimize,
                    hideZoom: hideZoom
                )
            )
            .presentedWindowStyle(.hiddenTitleBar)
            
    }
}

struct WindowCenteredModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(WindowCenteredAccessor())
    }
}

struct HoverableModifier: ViewModifier {

    @State private var isHovered: Bool = false
    @Environment(\.isHoveringWindow) var isHoveringWindow

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                withAnimation(.easeInOut) {
                    isHovered = hovering
                }
            }
            .environment(\.isHoveringWindow, isHovered)
    }
}
