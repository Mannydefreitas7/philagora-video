//
//  Recording+Application.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import AppState

extension Application {

    @MainActor
    var recordingStore: Dependency<RecordingView.Store> {
        dependency(.init())
    }

}
