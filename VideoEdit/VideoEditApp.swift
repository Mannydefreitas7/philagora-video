import os
import SwiftUI
import AVFoundation
import Onboarding
import SFSafeSymbols
//import ScreenCaptureKit

@main
struct VideoEditApp: App {
    @StateObject private var appState = IAppState()
    @AppStorage(.onboardingKey) var showOnboarding: Bool = true

    var body: some Scene {

        VEWelcomeWindow()
            .environmentObject(appState)

        CaptureWindow()
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}


// General logger
let logger = Logger()
