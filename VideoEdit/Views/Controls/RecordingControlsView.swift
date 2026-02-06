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
        VStack {}
        
        .environment(\.isCameraOn, viewModel.camera.isOn)
        .environment(\.isMicrophoneOn, viewModel.microphone.isOn)
        .animation(.bouncy, value: viewModel.showRecordButton)
    }
}


