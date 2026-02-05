//
//  Application+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import AppState
import SwiftUI

extension Application {

    var selectedCamera: State<AVDevice> {
        state(initial: .defaultDevice(.video), id: .uuid)
    }

    var selectedMicrophone: State<AVDevice> {
        state(initial: .defaultDevice(.audio), id: .uuid)
    }

    @MainActor
    var mainStore: Dependency<MainStore> {
        dependency(.shared)
    }

}
