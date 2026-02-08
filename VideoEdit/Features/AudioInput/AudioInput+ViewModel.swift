//
//  AudioInput+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-07.
//

import SwiftUI
import AVFoundation

extension AudioInputView {

    @MainActor
    @Observable final class ViewModel {

        var showSettings: Bool = false
        var selectedDevice: AVDevice = .defaultDevice(.audio)

    }
}
