//
//  Capture+Window.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI

struct CaptureWindow: Scene {

    var body: some Scene {
        WindowGroup(id: .window(.recording)) {
            CaptureView()
                .frame(minWidth: .minWindowWidth, minHeight: .minWindowHeight)
                .isHovering()
        }
        .commands {
            // General Commands
            GeneralCommand()
            // Video Commands
            VideoCommand()
        }
        // Window styles
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: .defaultRecordWidth, height: .defaultRecordHeight)
        .windowResizability(.contentSize)
        .windowBackgroundDragBehavior(.enabled)
    }
}
