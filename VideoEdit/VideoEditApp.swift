import SwiftUI
import AVFoundation
import Onboarding
import SFSafeSymbols
//import ScreenCaptureKit

@main
struct VideoEditApp: App {
    @StateObject private var appState = AppState()
    @AppStorage(.onboardingKey) var showOnboarding: Bool = true

    var body: some Scene {

        VEWelcomeWindow()
            .environmentObject(appState)
            .commands {
                // General Commands
                GeneralCommand(appState: appState)
            }

        RecordingWindow()
            .windowBackgroundDragBehavior(.enabled)
            .environmentObject(appState)
            .commands {
                // General Commands
                GeneralCommand(appState: appState)
                // Video Commands
                VideoCommand(appState: appState)
            }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var videoURL: URL?
    @Published var currentTool: EditingTool = .none
    @Published var showRecordingSheet = false
    @Published var showExportSheet = false
    @Published var exportFormat: ExportFormat = .movie
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    
    // Crop settings
    @Published var cropRect: CGRect = .zero
    @Published var isCropping = false
    
    // Trim settings
    @Published var trimStart: Double = 0
    @Published var trimEnd: Double = 1
    
    // Recording settings
    @Published var recordMicrophone = true
    @Published var recordSystemAudio = false
    @Published var showCameraOverlay = false
    @Published var visualizeClicks = true
    @Published var recordingQuality: RecordingQuality = .high
    
    // GIF settings
    @Published var gifFrameRate: Int = 15
    @Published var gifLoopCount: Int = 0 // 0 = infinite
    @Published var gifScale: Double = 1.0
    @Published var gifOptimize = true
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.movie, .video, .mpeg4Movie, .quickTimeMovie, .gif]
        
        if panel.runModal() == .OK {
            videoURL = panel.url
            currentTool = .none
            cropRect = .zero
            trimStart = 0
            trimEnd = 1
        }
    }
    
    func saveFile(completion: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = exportFormat == .gif ? [.gif] : [.mpeg4Movie]
        panel.nameFieldStringValue = exportFormat == .gif ? "export.gif" : "export.mp4"
        
        if panel.runModal() == .OK {
            completion(panel.url)
        } else {
            completion(nil)
        }
    }
}
