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
        GlassEffectContainer(spacing: .zero) {
            HStack(alignment: .center, spacing: .medium) {

                    // MARK: Record button
                    RecordButton()
                        .glassEffect(
                            viewModel.isRecording ? .regular
                                .tint(.recordingRed) : .regular
                        )
                        .glassEffectUnion(
                            id: ControlGroup.record,
                            namespace: controlGroup
                        )

                    if !viewModel.isRecording {
                        // MARK: Timer Control
                        TimerControl()
           
                            .padding(.horizontal, viewModel.isTimerEnabled ? .small : .zero)
                            .frame(height: .minHeight)
                            .glassEffect()
                            .glassEffectUnion(
                                id: viewModel.isTimerEnabled ? ControlGroup.timer : ControlGroup.all,
                                namespace: controlGroup
                            )
                    }



                HStack(spacing: 0) {

                    if viewModel.isRecording {
                        // MARK: Pause Button
                        PauseButton()
                    }

                    // MARK: Audio Input
                    AudioInput()

                    // MARK: Video Input
                    VideoInput()

                    // MARK: Settings Input
                    SettingsButton()

                }
               // .padding(.vertical, 6)
                .padding(.trailing, .small)
                .padding(.leading, viewModel.isTimerEnabled || viewModel.isRecording ? .small : .zero)
                .frame(height: .minHeight)
                .glassEffect()
                .glassEffectUnion(
                    id: viewModel.isTimerEnabled ? ControlGroup.options : ControlGroup.all,
                    namespace: controlGroup
                )



            }
            .animation(.bouncy, value: viewModel.isTimerEnabled)
            .glassEffectTransition(.materialize)
            .controlSize(.large)
        }

    }
}

extension CGFloat {

    static let small: Self = 8
    static let  medium: Self  = 16
    static let  large: Self  = 24
    static let  extraLarge: Self  = 32

    static let  minHeight: Self  = 54

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
    func SettingsButton() -> some View {
        Button {
            //
            viewModel.isSettingsPresented.toggle()
        } label: {
            Label("Settings", systemImage: "gearshape")
                .font(.title2)
                .labelStyle(.iconOnly)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.glassToolBar)
        .sheet(isPresented: $viewModel.isSettingsPresented) {
            SettingsModal()
                .presentedWindowToolbarStyle(.unified)
                .frame(width: .windowWidth * 0.6, height: 360)
        }
    }

    @ViewBuilder
    func SettingsModal() -> some View {
        EditorSettingsModal()

    }
}



#Preview {
    PlayerControlsView(viewModel: .init())
}
