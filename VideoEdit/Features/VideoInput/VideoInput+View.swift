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
    @Binding var device: AVDevice
        /// View model
    @EnvironmentObject var viewModel: RecordingToolbar.ViewModel

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
                    .frame(height: .popoverWidth)
            } else {
                ToolButton()
                    .frame(height: .minHeight)
            }
        }
        .padding(.horizontal, .small)
        .glassEffect(.regular, in: device.shape)
        .toolEffectUnion(
            id: device.isOn ? .video : .options,
            namespace: controlGroup
        )
    }
}
