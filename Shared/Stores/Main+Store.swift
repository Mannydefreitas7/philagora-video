//
//  App+Store.swift
//  VideoEdit
//
//  Created by Emmanuel on 2/2/26.
//

import SwiftUI



@MainActor
@Observable
final class MainStore {

    // MARK: - Singleton
    /// Global, shared instance of the main app store.
    static let shared = MainStore()

    /// Prevent external instantiation; use `MainStore.shared`.
    private init() {}

    // MARK: - State
    /// Current capture pipeline status (idle, preparing, recording, etc.).
    var status: CaptureStatus = .idle

    /// Convenience flag that mirrors whether we're actively recording.
    var isRecording: Bool = false
}
