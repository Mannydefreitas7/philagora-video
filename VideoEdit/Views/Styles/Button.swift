//
//  Button.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-03.
//
import SwiftUI
import Pow

struct WelcomeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        @ViewBuilder var buttonBody: some View {
            let base = configuration.label
                .contentShape(Rectangle())
                .padding(.vertical, 7)
                .padding(.leading, 14)
                .frame(height: 36)
                .background(Color(.labelColor).opacity(configuration.isPressed ? 0.1 : 0.05))

            if #available(macOS 26, *) {
                base.clipShape(Capsule())
            } else {
                base.clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        return buttonBody
    }
}


enum AnyGlassStyle {
    case regular
    case prominent(Color)
}


struct PushDownButtonStyle: PrimitiveButtonStyle {

    var glass: AnyGlassStyle?
    @State private var isPressed: Bool = false

    init(glass: AnyGlassStyle? = nil) {
        self.glass = glass
    }

    func makeBody(configuration: Configuration) -> some View {

      Button(role: configuration.role) {
          isPressed = true
          configuration.trigger()
          Task.perform(after: 0.1) { isPressed = false }
        } label: {
            configuration.label
        }
        .conditionalEffect(
            .pushDown,
            condition: isPressed
        )
        .if(glass != nil) { button in
            switch glass {
            case .regular:
                    button.buttonStyle(.glass)
            case .prominent(let style):
                    button
                        .buttonStyle(.glassProminent)
                        .tint(style)

            default:
                button.buttonStyle(.automatic)
            }
        }
    }
}

struct ShineEffectButtonStyle: ButtonStyle {

    @Binding var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.interactiveSpring, value: isEnabled)
            .changeEffect(
                .shine.delay(0.5),
                value: isEnabled,
                isEnabled: isEnabled
            )

    }
}

