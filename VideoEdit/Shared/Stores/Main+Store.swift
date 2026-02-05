//
//  App+Store.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI

@MainActor
final class MainStore: ObservableObject {

    // MARK: - Singleton
    /// Global, shared instance of the main app store.
    static let shared = MainStore()
    private let devices = DeviceDiscovery.shared
    /// Prevent external instantiation; use `MainStore.shared`.
    private init() {}

    // MARK: - State
    /// Current capture pipeline status (idle, preparing, recording, etc.).
    @Published var status: CaptureStatus = .idle

    /// Convenience flag that mirrors whether we're actively recording.
    @Published var isRecording: Bool = false

   /// Devices when loaded
   @Published var cameras: [AVDevice] = []
   @Published var microphones: [AVDevice] = []

    func loadDevices() async {
        self.cameras = await self.devices.cameras
        self.microphones = await self.devices.microphones
    }
}
