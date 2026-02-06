import SwiftUI
import AVKit
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: IAppState
    @StateObject private var recorder = ScreenRecorder()
    @State private var isDragging = false


    func toggleRecording() async {
        do {
            if recorder.isRecording {
                _ = try await recorder.stopRecording()
                return
            }
            _ = try await recorder.startRecording()
        } catch {
            print(error)
        }
    }

    var body: some View {
        ZStack {
            VideoPlayer(player: appState.videoURL.flatMap(AVPlayer.init(url:))) {
                VStack {
                    Spacer()
                    
                    
                    
                    Button {
                        Task {
                            await toggleRecording()
                        }
                        
                    } label: {
                        Text("Record")
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

            let supportedTypes = ["mp4", "mov", "m4v", "gif", "webm", "avi", "mkv"]
            if supportedTypes.contains(url.pathExtension.lowercased()) {
                DispatchQueue.main.async {
                    appState.videoURL = url
                }
            }
        }
        return true
    }
}

#Preview {
    ContentView()
        .environmentObject(IAppState())
}


//var body: some View {
//    ZStack {
//        // Background
//        Color(nsColor: .windowBackgroundColor)
//            .ignoresSafeArea()
//
//        if let videoURL = appState.videoURL {
//            // Main editor view
//            HSplitView {
//                // Video preview area
//                VStack(spacing: 0) {
//                    // Toolbar
//                    EditorToolbar()
//                        .environmentObject(appState)
//
//                    Divider()
//
//                    // Video player with overlay tools
//                    ZStack {
//                        VideoPlayerView(url: videoURL)
//                            .environmentObject(appState)
//
//                        if appState.currentTool == .crop {
//                            CropOverlay()
//                                .environmentObject(appState)
//                        }
//                    }
//                    .background(Color.black)
//
//                    Divider()
//
//                    // Timeline / trim controls
//                    if appState.currentTool == .trim {
//                        TrimView()
//                            .environmentObject(appState)
//                            .frame(height: 100)
//                    } else {
//                        VideoTimeline()
//                            .environmentObject(appState)
//                            .frame(height: 60)
//                    }
//                }
//                .frame(minWidth: 600)
//
//                // Right sidebar
//                VStack(alignment: .leading, spacing: 0) {
//                    SidebarContent()
//                        .environmentObject(appState)
//                }
//                .frame(width: 280)
//                .background(Color(nsColor: .controlBackgroundColor))
//            }
//        } else {
//            RecordingInProgressView(recorder: recorder) {
//                //
//            }
//            // Welcome / Drop zone
//            WelcomeView(isDragging: $isDragging)
//                .environmentObject(appState)
//        }
//    }
//    .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
//        handleDrop(providers: providers)
//    }
//    .sheet(isPresented: $appState.showRecordingSheet) {
//        RecordingView()
//            .environmentObject(appState)
//    }
//    .sheet(isPresented: $appState.showExportSheet) {
//        ExportView()
//            .environmentObject(appState)
//    }
//}
