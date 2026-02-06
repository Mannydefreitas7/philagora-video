import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    let url: URL
    @EnvironmentObject var appState: IAppState
    @StateObject private var playerManager = VideoPlayerManager()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video player
                VideoPlayer(player: playerManager.player)
                    .disabled(appState.currentTool != .none)
                
                // Play/Pause overlay on tap
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if appState.currentTool == .none {
                            playerManager.togglePlayPause()
                        }
                    }
                
                // Playback controls overlay
                VStack {
                    Spacer()
                    
                    PlaybackControls(playerManager: playerManager)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding()
                        .opacity(playerManager.showControls ? 1 : 0)
                }
            }
        }
        .onAppear {
            playerManager.loadVideo(url: url)
        }
        .onChange(of: url) { _, newURL in
            playerManager.loadVideo(url: newURL)
        }
        .onHover { hovering in
            withAnimation {
                playerManager.showControls = hovering
            }
        }
    }
}

#Preview {
    VideoPlayerView(url: URL(fileURLWithPath: "/path/to/video.mp4"))
        .environmentObject(IAppState())
}
