//
//  Capture+Modifiers.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI

struct CaptureWindowStyle: WindowStyle {
    func body(configuration: Configuration) -> some Scene {
        configuration
            .windowStyle(.hiddenTitleBar)
            .windowToolbarStyle(.unified)
            .defaultSize(width: .defaultRecordWidth, height: .defaultRecordHeight)
            .windowResizability(.contentSize)
            .windowBackgroundDragBehavior(.enabled)
    }
}

struct CaptureViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: .minWindowWidth, minHeight: .minWindowHeight)
            .isHovering()
            .environmentObject(appState)
    }
}
