//
//  EditorSettingsModal.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-12.
//

import SwiftUI


struct EditorSettingsView: View {
    @Environment(\.dismiss) var dismiss
    //@StateObject var cameraManager: CameraPreviewViewModel = .init()
   // @EnvironmentObject var editorViewModel: CameraCaptureView.CaptureState
    @ObservedObject var viewModel: ViewModel = .init()

    var body: some View {

      //  NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Label("Settings", systemImage: "gearshape")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    SettingsTabs()
                }
                .padding(.horizontal, .medium)
                .padding(.top, .medium)
                .padding(.bottom, .small)

                List {

                 ///   DisclosureGroup("Video") {
                       // CameraSettingsView(cameraManager: cameraManager)
                 //   }

                }
                .toolbar {
                    ToolbarSpacer()
                    ToolbarItem {
                      //  SettingsButton(systemImage: "sidebar.trailing", isOn: $editorViewModel.isSettingsPresented)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
//        }
    }
}

extension EditorSettingsView {

    enum Tab: String, Hashable, CaseIterable {
        case video = "Video"
        case audio = "Audio"
    }

    @ViewBuilder
    func SettingsTabs() -> some View {

        TabPicker(selection: $viewModel.tab) {

            Label(Tab.video.rawValue, systemImage: "camera")
                .id(Tab.video)
            Label(Tab.audio.rawValue, systemImage: "microphone")
                .id(Tab.audio)
        } 
        .controlSize(.extraLarge)
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    class ViewModel: ObservableObject {

        @Published var tab: Tab = .video

    }

}

#Preview {

        EditorSettingsView()
            .frame(width: 600, height: 300)

}
