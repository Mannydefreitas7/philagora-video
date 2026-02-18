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

        //var selectedDevice: AVDevice = .defaultDevice(.audio)
        
        @ObservationIgnored
        @Published public var showSettings: Bool = false

        @ObservationIgnored
        @Published public var selectedDevice: AVDevice = .defaultDevice(.audio)

        @ObservationIgnored
        @Published public var availableDevices: [AVDevice] = []

        @ObservationIgnored
        @Published public var deviceId: AVDevice.ID = AVDevice.defaultDevice(.audio).id

    }
}
