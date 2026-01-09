//
//  RecordButtonView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-06.
//

import SwiftUI

/// A metallic / shiny neumorphic record button with animated start/stop transition
/// and a press-down interaction.
struct RecordButtonView: View {

    @Binding var isRecording: Bool
    @State private var isPressed: Bool = false

    var stopRoundedRectShape: RoundedRectangle {
        .init(cornerRadius:  isRecording ? 7 : 99, style: .continuous)
    }

    var fraction: CGFloat {
        .init(.recordWidth / 1.2)
    }

    var gradient: AnyShapeStyle {
        if isRecording {
            .init(
                LinearGradient(
                    stops: [.init(color: .white.opacity(0.4), location: 0.5),
                            .init(color: .clear, location: 0.6),
                            .init(color: .clear, location: 0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            .init(RadialGradient(
                gradient: Gradient(colors: [.white.opacity(0.5), .clear]),
                center: .bottomTrailing,
                startRadius: .recordWidth,
                endRadius: fraction
            ))
        }
    }

    var buttonShapeColor: Color {
        isRecording ? .white : .recordingRed
    }
    @ViewBuilder
    func squareStopShape() -> some View {
        stopRoundedRectShape
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [buttonShapeColor.exposureAdjust(-20), .clear]),
                    center: .bottomTrailing,
                    startRadius: 30,
                    endRadius: 30))

            .frame(
                width: .recordWidth,
                height: .recordHeight
            )
            .glassEffect(.regular.tint(buttonShapeColor), in: stopRoundedRectShape)
            .overlay(gradient, in: stopRoundedRectShape)

    }


    @ViewBuilder
    func buttonShape() -> some View {
        _IconContent(isRecording: $isRecording)
            .scaleEffect(isRecording ? 0.7 : 1.0)
    }


    var body: some View {

        Button {
            withAnimation(.bouncy) {
                isRecording.toggle()
            }
        } label: {
            Label {
                Text("Record")
                    .fontWeight(.medium)
                    .font(.title3)
            } icon: {
                buttonShape()
            }
            .labelIconToTitleSpacing(8)
            .conditionalEffect(.repeat(.glow(color: .white, radius: 10), every: 2), condition: isRecording)
        }
        .buttonBorderShape(.capsule)
        .buttonStyle(.pushDown(glass: isRecording ? .prominent(.recordingRed) : .regular))
        .sensoryFeedback(.start, trigger: isPressed)

    }
}

private struct _IconContent: View {
    @Environment(\._recordButtonIsPressed) private var isPressed
    @Binding var isRecording: Bool
    var body: some View {
        Group {
            RecordButtonView(isRecording: $isRecording)
                .squareStopShape()
        }
        .opacity(isPressed ? 0.95 : 1)
    }
}

extension RecordButtonView {

    struct RecordButtonShape: ViewModifier {

        func body(content: Content) -> some View {
            ZStack {
                content
                    .opacity(0.1)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
        }

    }

}

struct IconOnlyPressTransformLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .accessibilityIdentifier("recordButton.icon")
            configuration.title
        }
    }
}

struct RecordButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
           .modifier(IconPressEffect(isPressed: configuration.isPressed))

    }
}

private struct IconPressEffect: ViewModifier {
    let isPressed: Bool
    func body(content: Content) -> some View {
        content
            .environment(\._recordButtonIsPressed, isPressed)
    }
}

private struct _RecordButtonIsPressedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
private extension EnvironmentValues {
    var _recordButtonIsPressed: Bool {
        get { self[_RecordButtonIsPressedKey.self] }
        set { self[_RecordButtonIsPressedKey.self] = newValue }
    }
}

#Preview("Metallic Record Button") {
    @Previewable @State var isRecording: Bool = false

    LazyVStack {
        RecordButtonView(isRecording: $isRecording)

    }
    .padding()
    .frame(width: 600, height: 600)
}
