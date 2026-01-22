//
//  PlayerControlsView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import Combine

struct PlayerControlsView: View {

    @Namespace var controlGroup
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack {
            if viewModel.showRecordButton {
                // MARK: - Record button
                RecordCircleButton()
                    .padding(.bottom, .small)
                    .animation(.bouncy, value: viewModel.showRecordButton)
            }

            GlassEffectContainer(spacing: .zero) {

                    HStack(alignment: .bottom, spacing: .small) {

                        if !viewModel.isRecording {
                            // MARK: Timer Control
                            TimerControl()
                                .padding(.horizontal, .small)
                                .frame(height: .minHeight)
                                .glassEffect()
                                .toolEffectUnion(
                                    id: .timer,
                                    namespace: controlGroup
                                )
                        }

                        if viewModel.isRecording {
                            // MARK: Pause Button
                            PauseButton()
                                .padding(.horizontal, .small)
                                .frame(height: .minHeight)
                                .glassEffect()
                        }

                        // MARK: Audio Input
                        AudioInput()

                        // MARK: Video Input
                        VideoInput()

                        // MARK: Settings Input
                        SettingsButtonView()
                            .padding(.horizontal, .small)
                            .frame(height: .minHeight)
                            .glassEffect()
                    }
                    .animation(.bouncy, value: viewModel.toggleAnimation)
                    .glassEffectTransition(.matchedGeometry)
                    .controlSize(.large)
            }
        }

    }
}


extension PlayerControlsView {

    final class ViewModel: ObservableObject {
        @Published var isRecording: Bool = false
        @Published var isTimerEnabled: Bool = false
        @Published var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var isSettingsPresented: Bool = false
        @Published var showRecordButton: Bool = true

        private var cancellables: Set<AnyCancellable> = []

        @Published var microphone: DeviceInfo = .init(
            id: UUID().uuidString,
            kind: .audio,
            name: "Unknown",
            position: .unspecified,
            isOn: false,
            showSettings: false
        )
        @Published var camera: DeviceInfo = .init(
            id: UUID().uuidString,
            kind: .video,
            name: "Unknown",
            position: .unspecified,
            isOn: false,
            showSettings: false
        )

        var spacing: CGFloat {
            isTimerEnabled || isRecording ? .small : .zero
        }

        var toggleAnimation: Bool {
            isRecording || isTimerEnabled
        }

        init() {

                $microphone
                    .map { !$0.showSettings }
                    .assign(to: \.showRecordButton, on: self)
                    .store(in: &cancellables)

                $camera
                    .map { !$0.showSettings }
                    .assign(to: \.showRecordButton, on: self)
                    .store(in: &cancellables)
        }
    }
}


extension PlayerControlsView {
    @ViewBuilder
    func RecordButton() -> some View {
        RecordButtonView(isRecording: $viewModel.isRecording)
            .keyboardShortcut("r", modifiers: [])
            .conditionalEffect(
                .repeat(.glow(color: .recordingRed.exposureAdjust(20), radius: 10), every: 3),
                condition: viewModel.isRecording
            )
            .buttonStyle(.pushDown(glass: .regular))
    }

    @ViewBuilder
    func RecordCircleButton() -> some View {
            Button {
                withAnimation(.bouncy) {
                    viewModel.isRecording.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.clear)
                        .glassEffect(.regular.interactive())

                    Image(systemSymbol: viewModel.isRecording ? .appFill : .circleFill)
                        .resizable()
                        .foregroundStyle(.recordingRed.gradient)
                        .scaleEffect(viewModel.isRecording ? 0.5 : 0.8)
                }
                .frame(width: .recordWidth * 2, height: .recordWidth * 2)
            }
            .buttonStyle(.borderless)
            .buttonBorderShape(.circle)
        }

    @ViewBuilder
    func PauseButton() -> some View {
        PauseButtonView {
            //
        }
    }

    @ViewBuilder
    func TimerControl() -> some View {
        TimerPicker(isTimerEnabled: $viewModel.isTimerEnabled, timerSelection: $viewModel.timerSelection)
    }

    @ViewBuilder
    func AudioInput() -> some View {
        AudioInputView(controlGroup: controlGroup, device: $viewModel.microphone)
    }

    @ViewBuilder
    func VideoInput() -> some View {
        VideoInputView(controlGroup: controlGroup, device: $viewModel.camera)
    }

    @ViewBuilder
    func SettingsButtonView() -> some View {
        SettingsButton(isOn: $viewModel.isSettingsPresented)
    }
}

