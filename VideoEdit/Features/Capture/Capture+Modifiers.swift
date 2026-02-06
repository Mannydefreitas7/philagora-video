//
//  Capture+Modifiers.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI

struct CaptureViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: .minWindowWidth, minHeight: .minWindowHeight)
            .isHovering()
    }
}
