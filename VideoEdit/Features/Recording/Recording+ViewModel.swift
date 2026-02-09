//
//  Recording+ViewModel.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import Combine
import SwiftUI

extension RecordingToolbar {

    @MainActor
    final class ViewModel: ObservableObject {
        private var cancellables: Set<AnyCancellable> = []

        private let session = CaptureSession()

        @Published var isRecording: Bool = false
        @Published var isTimerEnabled: Bool = false
        @Published var timerSelection: TimeInterval.Option = .threeSeconds
        @Published var isSettingsPresented: Bool = false
        @Published var showRecordButton: Bool = true

        @Published var microphone: AVDevice = .defaultDevice(.audio)
        @Published var camera: AVDevice = .defaultDevice(.video)

        @Published var videoInputViewModel: VideoInputView.ViewModel = .init()
        @Published var audioInputViewModel: AudioInputView.ViewModel = .init()

        var spacing: CGFloat {
            isTimerEnabled || isRecording ? .small : .zero
        }

        var toggleAnimation: Bool {
            isRecording || isTimerEnabled
        }

        init() {

            guard videoInputViewModel.isRunning.inverted else {
                return
            }

            videoInputViewModel.setSession(session)

            $microphone
                .drop(while: { $0.showSettings.isFalsy })
                .map { $0.showSettings.inverted }
                .receive(on: RunLoop.main)
                .sink { self.camera.showSettings = $0 }
                .store(in: &cancellables)

            $camera
                .drop(while: { $0.showSettings.isFalsy })
                .map { $0.showSettings.inverted }
                .receive(on: RunLoop.main)
                .sink { self.microphone.showSettings = $0 }
                .store(in: &cancellables)

            Publishers.CombineLatest($microphone, $camera)
                .map { (microphone, camera) in
                    let settingsVisible = microphone.showSettings || camera.showSettings
                    if microphone.isOn { return !settingsVisible }
                    if camera.isOn { return !settingsVisible }
                    return false
                }
                .receive(on: RunLoop.main)
                .assign(to: \.showRecordButton, on: self)
                .store(in: &cancellables)
        }
    }
}
