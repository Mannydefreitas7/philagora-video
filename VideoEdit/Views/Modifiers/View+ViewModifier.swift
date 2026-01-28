//
//  PushDownButtonStyle.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-07.
//
import SwiftUI
import Pow

struct PushDownEffect: ViewModifier {

    @State private var isPressed: Bool = false

    public func body(content: Content) -> some View {
        content
            .opacity(isPressed ? 0.75 : 1)
            .conditionalEffect(
                .pushDown,
                condition: isPressed
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged({ _ in isPressed = true })
                    .onEnded({ _ in isPressed = false })
            )
    }
}

struct HoverEffect: ViewModifier {

    var shape: AnyShape = AnyShape(.rect)
    @State private var isHovered: Bool = false

    init(in shape: any Shape) {
        self.shape = AnyShape(shape)
     //   self.isHovered = isHovered
    }

    public func body(content: Content) -> some View {
        content
            .background(.primary.opacity(isHovered ? 0.5 : 0), in: shape)
            .onHover { isHovered = $0 }
            .animation(.easeInOut, value: isHovered)
    }
}
