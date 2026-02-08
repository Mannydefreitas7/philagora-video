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
    @Binding var viewModel: ViewModel
    @Preference(\.isMirrored) var isMirrored: Bool?

    var body: some View {
        Group {
            if viewModel.showSettings {
                ToolBarOptions()
                    .clipShape(viewModel.selectedDevice.shape)
                    .task { await viewModel.start() }
            } else {
                ToolButton()
                     .frame(height: .minHeight)
                    .padding(.horizontal, .small)
            }
        }
        .glassEffect(.regular, in: viewModel.selectedDevice.shape)
        .toolEffectUnion(
            id: viewModel.selectedDevice.isOn ? .video : .options,
            namespace: controlGroup
        )
        .onDisappear {
            Task { await viewModel.stop() }
        }
        .task {  await viewModel.initialize() }
    }
}
