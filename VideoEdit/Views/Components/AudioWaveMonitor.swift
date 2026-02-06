//
//  AudioWaveMonitor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-31.
//

import SwiftUI
import Accelerate
import Charts
import AVFoundation

struct AudioWaveMonitor: View {

    var style: Style
    @Binding var isActive: Bool
    @Environment(\.audioInputWave) var audioInputWave
    // Gradients for the chart
    private let chartGradient = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple, .red]),
        startPoint: .leading,
        endPoint: .trailing
    )

    @State private var drawingHeight = false
    @State private var isRecording = false
    @EnvironmentObject var captureState: CaptureView.Store

    private var animation: Animation {
        return .linear(duration: 0.5)
    }

    init(style: Style, isActive: Binding<Bool>) {
        self.style = style
        self._isActive = isActive
        self.drawingHeight = false
    }


    var body: some View {
        VStack {
            if style == .indicator {
                indicatorStyle()
                    .onAppear { drawingHeight.toggle() }
            } else {
                chartStyle()
            }
        }
    }
}

extension AudioWaveMonitor {

    enum Style {
        case indicator
        case chart
        case pills
    }

    @ViewBuilder
    func indicatorStyle() -> some View {
        HStack(spacing: .spacing * 0.4) {
            let samples = captureState.downsampledMagnitudes.map { CGFloat(($0 - 0) / (1 - 0)) }
            ForEach(0...4, id:\.self) { index in
                let value = samples[index] + .small
                bar(high: value > .medium ? .medium : value)
                    .animation(animation.speed(1.2), value: isActive)
            }
        }
        .frame(width: .extraLarge * 1.5)
    }

    @ViewBuilder
    func pillStyle() -> some View {
        let pillWidthSpace: CGFloat = CGSize.pill.width + .spacing
        let segments = .popoverWidth / pillWidthSpace

        SegmentedPillBar(
            value: audioInputWave.isNaN ? 0 : audioInputWave,
            segments: Int(segments)
        )
        .padding(.leading, .medium)
    }

    @ViewBuilder
    func bar(low: CGFloat = 1.0, high: CGFloat = 1.0) -> some View {
        RoundedRectangle(cornerRadius: .small)
            .glassEffect(.clear.tint(abs(high) > .small ? Color.successGreen : Color.secondary))
            .frame(height: isActive ? abs(high) : .small)
            .frame(width: .spacing * 0.7, height: .small)
    }


    @ViewBuilder
    func chartStyle() -> some View {
        Chart(captureState.downsampledMagnitudes.indices, id: \.self) { index in
            // 2. The LineMark
            LineMark(
                // a. frequency bins adjusted by Constants.downsampleFactor to spread points apart
                x: .value("Frequency", index * .downsampleFactor),
                // b. the magnitude (intensity) of each frequency
                y: .value("Magnitude", captureState.downsampledMagnitudes[index])
            )
            // 3. Smoothing the curves
            .interpolationMethod(.catmullRom)
            // The line style
            .lineStyle(StrokeStyle(lineWidth: 3))
            // The color
            .foregroundStyle(chartGradient)
        }
        .chartYScale(
            domain: 0...max(
                captureState.fftMagnitudes.max() ?? 0,
                .magnitudeLimit
            )
        )
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .animation(.easeOut, value: captureState.downsampledMagnitudes)
    }
}

#Preview {
    AudioWaveMonitor(style: .indicator, isActive: .constant(true))
}
