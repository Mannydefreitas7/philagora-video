//
//  PlayerControlsView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI

struct PlayerControlsView: View {

    @Namespace var controlGroup
    @ObservedObject var viewModel: ViewModel


    var body: some View {
        VStack {

            // MARK: - Record button
            RecordCircleButton()
                .padding(.bottom, .small)

            GlassEffectContainer(spacing: .small) {

                HStack(alignment: .center, spacing: .small) {

                    if !viewModel.isRecording {
                        // MARK: Timer Control
                        TimerControl()
                            .padding(viewModel.isTimerEnabled ? .horizontal : .leading, .small)
                            .frame(height: .minHeight)
                            .glassEffect(.clear)
                            .glassEffectUnion(
                                id: viewModel.isTimerEnabled ? ControlGroup.timer : ControlGroup.all,
                                namespace: controlGroup
                            )
                    }

                    if viewModel.isRecording {
                        // MARK: Pause Button
                        PauseButton()
                            .padding(.horizontal, .small)
                            .frame(height: .minHeight)
                            .glassEffect(.clear)

                    }

                    HStack(spacing: .zero) {

                        // MARK: Audio Input
                        AudioInput()

                        // MARK: Video Input
                        VideoInput()

                    }
                    .padding(.trailing, .small)
                    .padding(.leading, viewModel.isTimerEnabled ? .small : .zero)
                    .frame(height: .minHeight)
                    .glassEffect(.clear)
                    .glassEffectUnion(
                        id: viewModel.isTimerEnabled ? ControlGroup.options : ControlGroup.all,
                        namespace: controlGroup
                    )

                    // MARK: Settings Input
                    SettingsButtonView()
                        .padding(.horizontal, .small)
                        .frame(height: .minHeight)
                        .glassEffect(.clear)
                        //
                }
                .animation(.bouncy, value: viewModel.isTimerEnabled)
                .glassEffectTransition(.materialize)
                .controlSize(.large)

            }
        }
    }
}

extension CGFloat {

    static let small: Self = 8
    static let  medium: Self  = 16
    static let  large: Self  = 24
    static let  extraLarge: Self  = 32
    static let  minHeight: Self  = 48

}

extension PlayerControlsView {

    enum ControlGroup: Hashable {
        case all
        case record
        case options
        case timer
        case settings
    }


    @MainActor
    final class ViewModel: ObservableObject {
        @Published var isRecording: Bool = false
        @Published var isTimerEnabled: Bool = false
        @Published var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var isOn: Bool = false
        @Published var isSettingsPresented: Bool = false

        var spacing: CGFloat {
            isTimerEnabled || isRecording ? 8 : 0
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
        AudioInputView(isOn: $viewModel.isOn)
    }

    @ViewBuilder
    func VideoInput() -> some View {

        VideoInputView {
            //
        }
    }

    @ViewBuilder
    func SettingsButtonView() -> some View {
        SettingsButton(isOn: $viewModel.isSettingsPresented)
    }
}



#Preview {
    PlayerControlsView(viewModel: .init())
}
