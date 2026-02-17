//
//  Shape.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//
import SwiftUI

struct RecordShape: Shape {

    var isRecording: Bool
    func path(in rect: CGRect) -> Path {
        let color: Color = isRecording ? .white : Color(.recordingRed)
        let rectangle = RoundedRectangle(
            cornerRadius: isRecording ? 7 : 99,
            style: .continuous
        )
//        let filldRectangle = rectangle
//        .fill(
//            RadialGradient(
//                gradient: Gradient(colors: [color.exposureAdjust(-20), .clear]),
//                center: .bottomTrailing,
//                startRadius: 30,
//                endRadius: 30)
//        )
//
//        let glassRectangle = rectangle.glassEffect(.regular.tint(color), in: rectangle)

        let path = rectangle.path(in: rect)

        return path
    }
}
