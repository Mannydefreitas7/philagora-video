//
//  Capture+Application.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import AppState
import SwiftUI

extension Application {

    @MainActor
    var captureStore: Dependency<CaptureView.Store> {
        dependency(.init())
    }

}
