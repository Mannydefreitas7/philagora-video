import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: IAppState

    @AppStorage("defaultRecordingQuality") private var defaultRecordingQuality = "Balanced"
    @AppStorage("defaultGifFrameRate") private var defaultGifFrameRate = 15
    @AppStorage("showCountdown") private var showCountdown = true
    @AppStorage("countdownDuration") private var countdownDuration = 3
    @AppStorage("saveLocation") private var saveLocation = "Movies"
    @AppStorage("autoOptimizeGifs") private var autoOptimizeGifs = true
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("soundEffects") private var soundEffects = true
    
    var body: some View {
        TabView {
            // General
            GeneralSettingsView(
                showCountdown: $showCountdown,
                countdownDuration: $countdownDuration,
                saveLocation: $saveLocation,
                showNotifications: $showNotifications,
                soundEffects: $soundEffects
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            // Recording
            RecordingSettingsView(
                defaultRecordingQuality: $defaultRecordingQuality
            )
            .tabItem {
                Label("Recording", systemImage: "record.circle")
            }
            
            // Export
            ExportSettingsView(
                defaultGifFrameRate: $defaultGifFrameRate,
                autoOptimizeGifs: $autoOptimizeGifs
            )
            .tabItem {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            // Shortcuts
            ShortcutsSettingsView()
            .tabItem {
                Label("Shortcuts", systemImage: "keyboard")
            }
            
            // About
            AboutSettingsView()
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
        .environmentObject(IAppState())
}
