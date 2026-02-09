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
    @Environment(\.videoDevices) var videoDevices

    var body: some View {

        VStack(spacing: .small) {
                if viewModel.showSettings {
                    ToolBarOptions()
                        .glassEffect(.regular, in: .rect(cornerRadius: .large))
                        .toolEffectUnion(
                            id: .settings,
                            namespace: controlGroup
                        )
                        .task { await viewModel.start() }
                }

                ToolButton()
                    .frame(height: .minHeight)
                    .padding(.horizontal, .small)
                    .glassEffect(.regular, in: .capsule)
                    .toolEffectUnion(
                        id: viewModel.selectedDevice.isOn ? .video : .options,
                        namespace: controlGroup
                    )
            }
            .onDisappear {
                Task { await viewModel.stop() }
            }
            .task {  await viewModel.initialize() }
    }

}
