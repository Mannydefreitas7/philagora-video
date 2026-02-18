import os
import SwiftUI
import AVFoundation
import SFSafeSymbols
import AppInformation
//import ScreenCaptureKit

@main
struct ApertureApp: App {
    @StateObject private var appState = IAppState()
    @AppStorage(.userDefaultsKey(.onboardingKey)) var showOnboarding: Bool = true
    @Environment(\.appInfo) var appInfo

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
let logger = Logger(subsystem: AppInfo.current.id, category: "DEVELOPMENT")
