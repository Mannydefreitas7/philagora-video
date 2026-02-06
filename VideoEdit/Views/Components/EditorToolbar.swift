import SwiftUI

struct EditorToolbar: View {
    @EnvironmentObject var appState: IAppState

    var body: some View {
        HStack(spacing: 16) {
            // File name
            if let url = appState.videoURL {
                HStack(spacing: 8) {
                    Image(systemName: "film")
                        .foregroundColor(.secondary)
                    Text(url.lastPathComponent)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Tool buttons
            ToolButton(icon: "crop", title: "Crop", isSelected: appState.currentTool == .crop) {
                appState.currentTool = appState.currentTool == .crop ? .none : .crop
            }

            ToolButton(icon: "scissors", title: "Trim", isSelected: appState.currentTool == .trim) {
                appState.currentTool = appState.currentTool == .trim ? .none : .trim
            }

            Divider()
                .frame(height: 20)

            // Export buttons
            Button(action: {
                appState.exportFormat = .gif
                appState.showExportSheet = true
            }) {
                Label("GIF", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)

            Button(action: {
                appState.exportFormat = .movie
                appState.showExportSheet = true
            }) {
                Label("Export", systemImage: "square.and.arrow.up.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
