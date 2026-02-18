//
//  VideoInput+View.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//

import SwiftUI
import SFSafeSymbols
import AVFoundation
import AVKit
import AppState

struct VideoInputView: View {

    var controlGroup: Namespace.ID
    /// View model
    @Environment(\.videoDevices) var videoDevices
    @EnvironmentObject var viewModel: RecordingToolbar.ViewModel

    var body: some View {

        VStack(spacing: .small) {
            if viewModel.videoInputViewModel.showSettings {
                    ToolBarOptions()
                        .glassEffect(.regular, in: .rect(cornerRadius: .large))
                        .toolEffectUnion(
                            id: .settings,
                            namespace: controlGroup
                        )
                        .task { await viewModel.videoInputViewModel.start() }
                }

                ToolButton()
                    .frame(height: .minHeight)
                    .padding(.horizontal, .small)
                    .glassEffect(.regular, in: .capsule)
                    .toolEffectUnion(
                        id: viewModel.camera.isOn ? .video : .options,
                        namespace: controlGroup
                    )
            }
            .onDisappear {
                Task { await viewModel.videoInputViewModel.stop() }
            }
            .task {  await viewModel.videoInputViewModel.initialize() }
    }

}
