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
    @Preference(\.isRecording) var isRecording: Bool
    @State var viewModel: ViewModel = .init()

    var body: some View {
        VStack {
            if viewModel.showRecordButton {
                // MARK: - Record button
                RecordCircleButton()
                    .transition(
                        .move(edge: .bottom)
                        .combined(with: .blurReplace)
                    )
            }

            GlassEffectContainer(spacing: .zero) {

                HStack(alignment: .bottom, spacing: .small) {

                    if !isRecording {
                        // MARK: Timer Control
                        TimerControl()
                    }

                    if isRecording {
                        // MARK: Pause Button
                        PauseButton()
                            .animation(.bouncy, value: isRecording)
                    }

                    // MARK: Audio Input
                    AudioInputView(controlGroup: controlGroup, viewModel: $viewModel.audioInput)
                        .onChange(of: viewModel.audioInput.deviceId) { previousId, newId in
                            viewModel.onDeviceChange(previousId: previousId, newId: newId)
                        }
                    // MARK: Video Input
                    VideoInputView(controlGroup: controlGroup, viewModel: $viewModel.videoInput)
                        .onChange(of: viewModel.videoInput.deviceId) { previousId, newId in
                             viewModel.onDeviceChange(previousId: previousId, newId: newId)
                        }
                }
                .animation(.bouncy, value: viewModel.toggleAnimation)
                .glassEffectTransition(.matchedGeometry)
                .controlSize(.large)
                .task { await viewModel.prepare() }
                .onDisappear {
                    Task {
                        await viewModel.destroy()
                    }
                }
            }
        }
    }
}
