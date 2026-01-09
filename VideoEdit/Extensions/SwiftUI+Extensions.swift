import SwiftUI

// MARK: - Color Extensions

extension Color {
    
    static let pausedOrange = Color(red: 0.95, green: 0.6, blue: 0.1)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Image Extensions

extension Image {
    public static let appIcon: Self = .init(
        nsImage: NSApplication.shared.applicationIconImage ?? NSApp.applicationIconImage
    )

}


// MARK: - View Extensions

extension View {

    // Hides the window control buttons
    func hideWindowControls(close: Bool = true, minimize: Bool = true, zoom: Bool = true) -> some View {
        modifier(WindowControlsModifier(hideClose: close, hideMinimize: minimize, hideZoom: zoom))
    }

    // Hides the window control buttons
    func centerWindow() -> some View {
        modifier(WindowCenteredModifier())
    }

    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }

    func heartBeatAnimation() -> some View {
        modifier(HeartBeatModifier())
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack {
                Rectangle()

                mask()
                    .blendMode(.destinationOut)
            }
        )
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View, ElseContent: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content,
        @ViewBuilder else elseTransform: (Self) -> ElseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }

  

    /// Changes the cursor appearance when hovering attached View
    /// - Parameters:
    ///   - active: onHover() value
    ///   - isDragging: indicate that dragging is happening. If true this will not change the cursor.
    ///   - cursor: the cursor to display on hover
    func isHovering(_ active: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
        if isDragging { return }
        if active {
            cursor.push()
        } else {
            NSCursor.pop()
        }
    }

    func pressPushEffect() -> some View {
        modifier(PushDownEffect())
    }
}

extension ButtonStyle where Self == WelcomeButtonStyle {
    static var welcome: WelcomeButtonStyle { get { .init() }}
}

extension ButtonStyle {
    static func pushDown(glass: AnyGlassStyle?) -> PushDownButtonStyle {
        return PushDownButtonStyle(glass: glass)
    }
}

extension PrimitiveButtonStyle where Self == PushDownButtonStyle {

    static func pushDown(glass: AnyGlassStyle?) -> PushDownButtonStyle {
        return PushDownButtonStyle(glass: glass)
    }
}

extension ButtonStyle where Self == ShineEffectButtonStyle {
    static func shineEffect(isEnabled: Binding<Bool>) -> ShineEffectButtonStyle {
        return ShineEffectButtonStyle(isEnabled: isEnabled)
    }
}
