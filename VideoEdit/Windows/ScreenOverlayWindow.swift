//
//  ScreenOverlayWindow.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-14.
//

import SwiftUI
import ScreenCaptureKit
import SFSafeSymbols


struct TextView: View {
    @Environment(\.window) var backgroundStyle

    @Environment(\.styleMask) var styleMask

    @Environment(\.openWindow) var openWindow
    var body: some View {
        Button {
            openWindow(id: .window(.recording))
        } label: {
            Text("Hello, World!")
                .padding()
                .background(.red)
        }
        //.styleMask([.])
    }
}

struct FloatingVideoWindow: Scene {
    var body: some Scene {

        Window("", id: "main") {
            TextView()
                .padding()
        }
    }
}

