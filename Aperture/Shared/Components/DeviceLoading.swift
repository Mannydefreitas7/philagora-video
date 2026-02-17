//
//  DeviceLoading.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-09.
//

import SwiftUI
import SFSafeSymbols
import Shimmer

struct DeviceLoading: View {
    @State private var isDrawing = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemSymbol: .webCamera)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.drawOff, isActive: isDrawing)
                .imageScale(.large)
                .scaleEffect(1.5)
                .accessibilityHidden(true)
            Text("Loading...")
        }
        .task {
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.9)) {
                    isDrawing = true
                }
                try? await Task.sleep(for: .seconds(0.9))
                withAnimation(.easeInOut(duration: 0.9)) {
                    isDrawing = false
                }
                try? await Task.sleep(for: .seconds(0.9))
            }
        }
    }
}
struct DeviceConnectionLoading: View {
    let device: AVDevice
    private let leftIcon: SFSymbol
    private let rightIcon: SFSymbol
    private let duration: TimeInterval = 3

    @State private var leftVisible = false
    @State private var rightVisible = false
    @State private var activeDotIndex = -1

    private let dotCount = 12

    init(
        _ device: AVDevice
    ) {
        self.device = device
        self.leftIcon = .macwindow
        self.rightIcon = device.symbol
    }

    var body: some View {
        VStack(spacing: .small) {
            HStack(spacing: .medium) {
                Image(systemSymbol: leftIcon)
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.large)
                    .symbolEffect(.drawOn, isActive: !leftVisible)
                    .scaleEffect(1.2)
                    //  .opacity(leftVisible ? 1.0 : 0.0)
                ConnectionDots(activeDotIndex: activeDotIndex, count: dotCount)
                    .frame(height: 6)
                    .opacity(leftVisible ? 1.0 : 0.0)
                Image(systemSymbol: rightIcon)
                    .symbolRenderingMode(.hierarchical)
                    .imageScale(.large)
                    .symbolEffect(.drawOn, isActive: !rightVisible)
                    .scaleEffect(1.2)
            }
            .task {
                while !Task.isCancelled {
                    let revealIconDuration = max(0.2, duration * 0.14)
                    let dotStepDuration = max(0.06, duration * 0.06)
                    let dotStepDelay = max(0.05, duration * 0.05)
                    let tailDelay = max(0.3, duration * 0.4)

                    leftVisible = false
                    rightVisible = false
                    activeDotIndex = -1
                    try? await Task.sleep(for: .seconds(0.1))

                    withAnimation(.easeOut(duration: revealIconDuration)) {
                        leftVisible = true
                    }
                    try? await Task.sleep(for: .seconds(revealIconDuration))

                    for index in 0..<dotCount {
                        withAnimation(.easeInOut(duration: dotStepDuration)) {
                            activeDotIndex = index
                        }
                        try? await Task.sleep(for: .seconds(dotStepDelay))
                    }

                    withAnimation(.easeOut(duration: revealIconDuration)) {
                        rightVisible = true
                    }
                    try? await Task.sleep(for: .seconds(tailDelay))
                }
            }
            Text("Connecting to \(device.name)")
                .font(.caption)
                .shimmering(animation: .easeInOut.repeatForever().speed(duration / Double(dotCount)), mode: .mask)
        }
    }
}

private struct ConnectionDots: View {
    let activeDotIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: .spacing) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(.primary)
                    .frame(width: .spacing, height: .spacing)
                    .opacity(activeDotIndex >= index ? 1.0 : 0.2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DeviceConnectionLoading(.defaultDevice(.video))
    }
    .padding()
}
