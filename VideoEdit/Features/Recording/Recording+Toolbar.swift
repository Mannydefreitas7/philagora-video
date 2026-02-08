//
//  RecordingToolbar.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//
import SwiftUI
import AppState

struct RecordingToolbar: View {

    @Namespace var controlGroup
    @StateObject var viewModel: RecordingToolbar.ViewModel = .init()

    var body: some View {
        VStack {
            if viewModel.showRecordButton {
                // MARK: - Record button
                RecordCircleButton()
                    .transition(.move(edge: .bottom).combined(with: .blurReplace))
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
                    AudioInputView(controlGroup: controlGroup, viewModel: $viewModel.audioInputViewModel)
                    // MARK: Video Input
                    VideoInputView(controlGroup: controlGroup, viewModel: $viewModel.videoInputViewModel)

                }
                .animation(.bouncy, value: viewModel.toggleAnimation)
                .glassEffectTransition(.matchedGeometry)
                .controlSize(.large)
                .environmentObject(viewModel)
            }
        }
    }
}
