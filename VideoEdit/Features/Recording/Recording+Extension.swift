//
//  Recording+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import SwiftUI

extension RecordingToolbar {

    @ViewBuilder
    func RecordCircleButton() -> some View {
        RecordButton(isRecording: $viewModel.isRecording)
            .padding(.bottom, .small)
            .animation(.bouncy, value: viewModel.showRecordButton)
    }

    @ViewBuilder
    func PauseButton() -> some View {
        PauseButtonView {
                //
        }
        .padding(.horizontal, .small)
        .frame(height: .minHeight)
        .glassEffect()

    }

    @ViewBuilder
    func TimerControl() -> some View {
        TimerPicker(isTimerEnabled: $viewModel.isTimerEnabled, timerSelection: $viewModel.timerSelection)
            .padding(.horizontal, .small)
            .frame(height: .minHeight)
            .glassEffect()
            .toolEffectUnion(
                id: .timer,
                namespace: controlGroup
            )
    }

    @ViewBuilder
    func SettingsButtonView() -> some View {
        SettingsButton(isOn: $viewModel.isSettingsPresented)
            .padding(.horizontal, .small)
            .frame(height: .minHeight)
            .glassEffect()
    }

    @ToolbarContentBuilder
    func topTrailingControls() -> some ToolbarContent {
        ToolbarItem {
            GlassEffectContainer {
                HStack {

                    Toggle(isOn: $viewModel.isTimerEnabled) {
                        Label("Timer", systemImage: "timer")
                            .font(.title2)
                    }
                    .labelStyle(.iconOnly)
                    .toggleStyle(.automatic)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)


                    if viewModel.isTimerEnabled {
                        Picker("Timer", selection: $viewModel.timerSelection) {
                            ForEach(TimeInterval.options) { option in
                                Text("\(option.rawValue)s").tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .buttonStyle(.glass)
                    }
                }

                .glassEffect(.regular)
              //  .glassEffectUnion(id: viewModel.isTimerEnabled ? 2 : 1, namespace: toolbarGroup)
                .animation(.bouncy.delay(viewModel.isTimerEnabled ? 0.2 : 0), value: viewModel.isTimerEnabled)
                .glassEffectTransition(.materialize)
            }
        }

        ToolbarItemGroup {
            GlassEffectContainer {
                HStack {
//                    Toggle(
//                        Constants.showGuidesTitle,
//                        systemImage: "viewfinder",
//                        isOn: $showSafeGuides
//                    )
//                    .help(Constants.showGuidesHelp)
//                    .toggleStyle(.button)
//                    .glassEffectID("toolbar.glass.guide", in: toolbarGroup)
//
//                    Toggle(
//                        Constants.showMaskTitle,
//                        systemImage: "circle.rectangle.filled.pattern.diagonalline",
//                        isOn: $showAspectMask
//                    )
//                    .help(Constants.showMaskHelp)
//                    .toggleStyle(.button)
//                    .glassEffectID("toolbar.glass.mask", in: toolbarGroup)
//                    .animation(
//                        .spring(
//                            response: 0.35,
//                            dampingFraction: 0.85
//                        ),
//                        value: showAspectMask
//                    )

                   // if showAspectMask {

//                        Picker(Constants.ratioMenuTitle, systemImage: "aspectratio", selection: $aspectPreset) {
//                            ForEach(AspectPreset.allCases) { preset in
//                                Label(preset.rawValue.capitalized, systemImage: preset.icon)
//                                    .tag(preset)
//                                    .labelStyle(.titleAndIcon)
//                            }
//                        }
                      //  .pickerStyle(.automatic)
                     //   .buttonStyle(.glass)
                     //   .glassEffectID("toolbar.glass.focus", in: toolbarGroup)
                    }
                }
            }
       //     .glassEffectTransition(.materialize)
        }

       // ToolbarSpacer(.flexible)

//        ToolbarItem {
//            Toggle(
//                Constants.mirrorTitle,
//                systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right",
//                isOn: $isMirrored
//            )
//            .help(Constants.mirrorHelp)
//            .toggleStyle(.button)
//        }
    //}
}
