//
//  RecordingControlsView+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI
import Combine
import CombineAsync

extension RecordingControlsView {

    @MainActor
    final class ViewModel: ObservableObject {

        private var cancellables: Set<AnyCancellable> = []

        @Published var isRecording: Bool = false
        @Published var isTimerEnabled: Bool = false
        @Published var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var isSettingsPresented: Bool = false
        @Published var showRecordButton: Bool = true

        @Published var microphone: AVDeviceInfo = .defaultDevice(.audio)
        @Published var camera: AVDeviceInfo = .defaultDevice(.video)

        var spacing: CGFloat {
            isTimerEnabled || isRecording ? .small : .zero
        }

        var toggleAnimation: Bool {
            isRecording || isTimerEnabled
        }

        init() {

            Publishers.CombineLatest($microphone, $camera)
                .map { (microphone, camera) in
                    let settingsVisible = microphone.showSettings || camera.showSettings
                    if microphone.isOn {
                        return !settingsVisible
                    }
                    if camera.isOn {
                        return !settingsVisible
                    }
                    return false
                }
                .receive(on: RunLoop.main)
                .assign(to: \.showRecordButton, on: self)
                .store(in: &cancellables)
        }
    }
}
