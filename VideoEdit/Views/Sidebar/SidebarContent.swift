import SwiftUI

struct SidebarContent: View {
    @EnvironmentObject var appState: IAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Info section
                if let url = appState.videoURL {
                    VideoInfoSection(url: url)
                }

                Divider()

                // Quick actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)

                    QuickActionButton(icon: "crop", title: "Crop Video", subtitle: "Adjust frame dimensions") {
                        appState.currentTool = .crop
                    }

                    QuickActionButton(icon: "scissors", title: "Trim Video", subtitle: "Cut start and end") {
                        appState.currentTool = .trim
                    }

                    QuickActionButton(icon: "photo.on.rectangle", title: "Export as GIF", subtitle: "Create animated GIF") {
                        appState.exportFormat = .gif
                        appState.showExportSheet = true
                    }

                    QuickActionButton(icon: "film", title: "Export as Movie", subtitle: "Save as MP4/MOV") {
                        appState.exportFormat = .movie
                        appState.showExportSheet = true
                    }
                }

                Divider()

                // Presets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Social Media Presets")
                        .font(.headline)

                    PresetButton(title: "Instagram Story", size: "1080 × 1920")
                    PresetButton(title: "Instagram Post", size: "1080 × 1080")
                    PresetButton(title: "Twitter/X", size: "1280 × 720")
                    PresetButton(title: "YouTube", size: "1920 × 1080")
                    PresetButton(title: "TikTok", size: "1080 × 1920")
                }
            }
            .padding()
        }
    }
}
