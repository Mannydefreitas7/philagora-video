//
//  EditorSettingsModal.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-12.
//

import SwiftUI

struct EditorSettingsModal: View {

    @Environment(\.dismiss) var dismiss
    @StateObject var cameraManager: CameraPreviewViewModel = .init()
    var body: some View {
        NavigationStack {
            //VStack {

                TabView {

                    Tab("Video", systemImage: "web.camera") {
                        CameraSettingsView(cameraManager: cameraManager)
                            .navigationSubtitle("Video")
                    }

                    Tab("Audio", systemImage: "microphone") {
                        Text("Settings")
                            .navigationSubtitle("Audio")
                    }
                }
                .tabViewStyle(.grouped)
          //  }

            .toolbar {

                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .buttonBorderShape(.circle)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .toolbarTitleDisplayMode(.automatic)
            .presentedWindowToolbarStyle(.automatic)
            .navigationTitle("Settings")

        }

    }
}

#Preview {

        EditorSettingsModal()
        .frame(width: 600, height: 300)

}
