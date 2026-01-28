//
//  PlayerControlsView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//


import SwiftUI
import Combine

struct RecordingControlsView: View {

    @ObservedObject var viewModel: ViewModel
    @Namespace var controlGroup
    @Namespace var toolbarGroup

    @Preference(\.showSafeGuides) var showSafeGuides
    @Preference(\.isMirrored) var isMirrored
    @Preference(\.showAspectMask) var showAspectMask
    @Preference(\.aspectPreset) var aspectPreset

    var body: some View {
        
        VStack {
            if viewModel.showRecordButton {
                // MARK: - Record button
                RecordCircleButton()
            }

            GlassEffectContainer(spacing: .zero) {

                    HStack(alignment: .bottom, spacing: .small) {

                        if !viewModel.isRecording {
                            // MARK: Timer Control
                            TimerControl()
                        }

                        if viewModel.isRecording {
                            // MARK: Pause Button
                            PauseButton()
                                .animation(.bouncy, value: viewModel.isRecording)
                        }

                        // MARK: Audio Input
                        AudioInput()

                        // MARK: Video Input
                        VideoInput()

                        // MARK: Settings Input
                        SettingsButtonView()

                    }
                    .animation(.bouncy, value: viewModel.toggleAnimation)
                    .glassEffectTransition(.matchedGeometry)
                    .controlSize(.large)
            }
        }
        .environment(\.isCameraOn, viewModel.camera.isOn)
        .environment(\.isMicrophoneOn, viewModel.microphone.isOn)
        
    }
}


