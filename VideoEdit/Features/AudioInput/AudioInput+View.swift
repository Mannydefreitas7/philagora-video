//
//  AudioInput+View.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-07.
//

import SwiftUI
import SFSafeSymbols
import AppState

struct AudioInputView: View {

    var controlGroup: Namespace.ID
    @Environment(\.isRecording) var isRecording
    @Binding var viewModel: ViewModel

    var body: some View {
        Group {
            if viewModel.showSettings {
                ToolBarOptions()
                    .frame(minHeight: nil, alignment: .center)
            } else {
                ToolbarButton()
                    .frame(minHeight: .minHeight, alignment: .center)
            }
        }
        .glassEffect(
            .regular,
            in: viewModel.selectedDevice.shape
        )
        .toolEffectUnion(
            id: viewModel.selectedDevice.isOn ? .audio : .options,
            namespace: controlGroup
        )
    }
}
