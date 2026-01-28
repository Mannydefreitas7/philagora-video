//
//  DisclosureGroup.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-27.
//

import SwiftUI
import SwiftUIIntrospect

// MARK: - Indicator Type
enum DisclosureIndicator {
    case arrow
    case plusMinus
    case chevron
    case custom(collapsed: Image, expanded: Image)
}

// MARK: - Indicator Position
enum DisclosureIndicatorPosition {
    case leading
    case trailing
}

// MARK: - Introspect Configuration
struct DisclosureIntrospectConfig {
    var cornerRadius: CGFloat = .medium
    var applyShadow: Bool = false
    var shadowRadius: CGFloat = 2
    var shadowOpacity: Float = 0.1
    var useNativeCursor: Bool = true
    var customBackgroundColor: Color? = nil
    var enableAccessibility: Bool = true
    var accessibilityHint: String? = nil
}

// MARK: - Styles

struct CollapsibleDisclosureGroupStyle: DisclosureGroupStyle {
    //let indicator: DisclosureIndicator
    let position: DisclosureIndicatorPosition

    func makeBody(configuration: Configuration) -> some View {
        IntrospectDisclosureGroupStyleBody(
            configuration: configuration,
            indicator: .chevron,
            position: position,
            enableHover: true,
            accentColor: .primary,
            hoverColor: .primary.opacity(0.3),
            introspectConfig: .init()
        )
    }
}

// MARK: - Custom Disclosure Group Style
struct IntrospectDisclosureGroupStyle: DisclosureGroupStyle {
    let indicator: DisclosureIndicator
    let position: DisclosureIndicatorPosition
    let enableHover: Bool
    let accentColor: Color
    let hoverColor: Color
    let introspectConfig: DisclosureIntrospectConfig

    init(
        indicator: DisclosureIndicator = .arrow,
        position: DisclosureIndicatorPosition = .leading,
        enableHover: Bool = true,
        accentColor: Color = .primary,
        hoverColor: Color = .blue.opacity(0.1),
        introspectConfig: DisclosureIntrospectConfig = DisclosureIntrospectConfig()
    ) {
        self.indicator = indicator
        self.position = position
        self.enableHover = enableHover
        self.accentColor = accentColor
        self.hoverColor = hoverColor
        self.introspectConfig = introspectConfig
    }

    func makeBody(configuration: Configuration) -> some View {
        IntrospectDisclosureGroupStyleBody(
            configuration: configuration,
            indicator: indicator,
            position: position,
            enableHover: enableHover,
            accentColor: accentColor,
            hoverColor: hoverColor,
            introspectConfig: introspectConfig
        )
    }
}

// MARK: - Style Body Implementation
private struct IntrospectDisclosureGroupStyleBody: View {
    let configuration: DisclosureGroupStyleConfiguration
    let indicator: DisclosureIndicator
    let position: DisclosureIndicatorPosition
    let enableHover: Bool
    let accentColor: Color
    let hoverColor: Color
    let introspectConfig: DisclosureIntrospectConfig

    @State private var isHovered = false
    @State private var headerView: NSView?

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Button {
                withAnimation(.bouncy) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(spacing: .small) {
                    if position == .leading {
                        indicatorView
                    }

                    configuration.label
                        .font(.default)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if position == .trailing {
                        indicatorView
                    }
                }
                .contentShape(.rect)
                .padding(.small)
                .background(
                    RoundedRectangle(cornerRadius: introspectConfig.cornerRadius)
                        .fill(backgroundColor.opacity(0.5))
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if enableHover {
                    isHovered = hovering
                    updateCursor(hovering: hovering)
                }
            }
            .introspect(.button, on: .macOS(.v13, .v14, .v15)) { nsButton in
                configureButton(nsButton)
            }
            .if(introspectConfig.enableAccessibility) { view in
                view.accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityHint(introspectConfig.accessibilityHint ?? "Double tap to \(configuration.isExpanded ? "collapse" : "expand")")
            }

            if configuration.isExpanded {
                configuration.content
                //.padding(.leading, position == .leading ? .large : .medium)
                    .padding(.vertical, .small)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .introspect(.view, on: .macOS(.v13, .v14, .v15)) { nsView in
                        configureContentView(nsView)
                    }
            }
        }
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        if let customColor = introspectConfig.customBackgroundColor {
            return customColor
        }
        return configuration.isExpanded || enableHover && isHovered ? hoverColor : Color.clear
    }

    private var accessibilityLabel: String {
        configuration.isExpanded ? "Expanded section" : "Collapsed section"
    }

    // MARK: - Indicator View

    @ViewBuilder
    private var indicatorView: some View {
        Group {
            switch indicator {
                case .arrow:
                    Image(systemSymbol: .arrowRight)
                        .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))

                case .plusMinus:
                    Image(systemSymbol: configuration.isExpanded ? .minus : .plus)

                case .chevron:
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))

                case .custom(let collapsed, let expanded):
                    if configuration.isExpanded {
                        expanded
                    } else {
                        collapsed
                    }
            }
        }
        .foregroundColor(accentColor)
        .font(.system(size: .small * 1.5, weight: .bold))
        .frame(width: .medium, height: .medium)
        .animation(.bouncy, value: configuration.isExpanded)
    }

    // MARK: - Introspect Configuration Methods

    private func configureButton(_ nsButton: NSButton) {
        nsButton.isBordered = false
        nsButton.bezelStyle = .recessed

        if let trackingArea = nsButton.trackingAreas.first {
            nsButton.removeTrackingArea(trackingArea)
        }

        let trackingArea = NSTrackingArea(
            rect: nsButton.bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: nsButton,
            userInfo: nil
        )
        nsButton.addTrackingArea(trackingArea)
    }

    private func configureView(_ nsView: NSView) {
        if introspectConfig.applyShadow {
            nsView.wantsLayer = true
            nsView.shadow = NSShadow()
            nsView.layer?.shadowRadius = introspectConfig.shadowRadius
            nsView.layer?.shadowOpacity = introspectConfig.shadowOpacity
            nsView.layer?.shadowOffset = CGSize(width: 0, height: 1)
            nsView.layer?.shadowColor = NSColor.black.cgColor
        }

        nsView.wantsLayer = true
        nsView.layer?.cornerRadius = introspectConfig.cornerRadius
        nsView.layer?.masksToBounds = false
        nsView.layer?.drawsAsynchronously = true
    }

    private func configureContentView(_ nsView: NSView) {
        nsView.wantsLayer = true
        nsView.layer?.speed = 1.0

        if nsView.layer?.opacity == 0 {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.2
            nsView.layer?.add(animation, forKey: "fadeIn")
            nsView.layer?.opacity = 1
        }
    }

    private func updateCursor(hovering: Bool) {
        guard introspectConfig.useNativeCursor else { return }

        if hovering {
            NSCursor.pointingHand.push()
        } else {
            NSCursor.pop()
        }
    }
}
