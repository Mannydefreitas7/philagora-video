//
//  FloatingPanel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-15.
//

import Foundation
import SwiftUI

class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool

    init(
        contentRect: NSRect,
        isPresented: Binding<Bool>,
        @ViewBuilder contient: () -> Content
    ) {
            self._isPresented = isPresented

            super.init(
                contentRect: contentRect,
                styleMask: [.utilityWindow],
                backing: .buffered,
                defer: false)

            isFloatingPanel = true
            level = .floating

            animationBehavior = .utilityWindow
            isMovableByWindowBackground = true

            hidesOnDeactivate = true
            contentView = NSHostingView(rootView: contient())
            backgroundColor = .clear
        }


    override func resignMain() {
        super.resignMain()
        close()
    }

    override func close() {
        super.close()
        isPresented = false
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}
