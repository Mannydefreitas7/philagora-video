//
//  RecordButtonView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI


/// - Usage:
///   ```swift
///   RecordButton(isRecording: $isRecording) {
///      // Optional side effect on toggle action.
///   }
///   ```
/// - Parameters:
///  - isRecording: `Binding<Bool>` the recording state of the toggle action.
///   - `true` indicates recording has started.
///   - `false` indicates recording has stopped.
///  - style: `Style` button style, circle or labeled
struct RecordButton: View {

    @Binding var isRecording: Bool
    var style: Style = .circle

    var action: () -> Void = { }
    @State private var isPressed: Bool = false

    var body: some View {
        if style == .circle {
            CircleStyle()
        } else {
            LabeledStyle()
        }
    }
}

extension RecordButton {

    /// RecordButton styles
    enum Style {
        case circle
        case labeled
    }

    @ViewBuilder
    func CircleStyle() -> some View {
        Toggle(isOn: $isRecording) {
            ZStack {
                Circle()
                    .fill(.clear)
                    .glassEffect(.regular.interactive())

                Image(systemSymbol: isRecording ? .appFill : .circleFill)
                    .resizable()
                    .foregroundStyle(Color("recordingRed").gradient)
                    .scaleEffect(isRecording ? 0.5 : 0.8)
            }
            .frame(width: .recordWidth * 2, height: .recordWidth * 2)
        }
        .toggleStyle(.button)
        .buttonStyle(.borderless)
        .buttonBorderShape(.circle)
        .animation(.bouncy, value: isRecording)
    }

    @ViewBuilder
    func LabeledStyle() -> some View {
        Toggle(isRecording ? "Recording..." : "Record", isOn: $isRecording)
            .toggleStyle(.recordButton)
            .sensoryFeedback(.start, trigger: isPressed)
            .keyboardShortcut("r", modifiers: [])
            .conditionalEffect(
                .repeat(.glow(color: Color("recordingRed").exposureAdjust(20), radius: 10), every: 3),
                condition: isRecording
            )
            .buttonStyle(.pushDown(glass: .regular))
    }
}


#Preview("Record Button") {
    @Previewable @State var isRecording: Bool = false

    LazyVStack {
        RecordButton(isRecording: $isRecording)
    }
    .padding()
    .frame(width: 600, height: 600)
}
