import os
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


// General logger
let logger = Logger()
