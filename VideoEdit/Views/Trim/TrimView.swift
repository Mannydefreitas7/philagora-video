import SwiftUI
import AVFoundation
import AVKit

struct TrimView: View {
    @EnvironmentObject var appState: IAppState
    @State private var videoDuration: Double = 1
    @State private var thumbnails: [CGImage] = []
    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    @State private var currentPreviewTime: Double = 0
    @State private var isLoadingThumbnails = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Trim range display
            HStack {
                Text("Trim Range")
                    .font(.headline)
                
                Spacer()
                
                Text("\(formatTime(appState.trimStart * videoDuration)) - \(formatTime(appState.trimEnd * videoDuration))")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
                
                Text("(\(formatTime((appState.trimEnd - appState.trimStart) * videoDuration)))")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal)
            
            // Timeline with thumbnails
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Thumbnail strip
                    HStack(spacing: 0) {
                        if thumbnails.isEmpty {
                            // Placeholder while loading
                            ForEach(0..<10, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: geometry.size.width / 10)
                            }
                        } else {
                            ForEach(Array(thumbnails.enumerated()), id: \.offset) { row, image in
                                Image(image, scale: 1, label: Text(""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width / CGFloat(thumbnails.count))
                                    .clipped()
                            }
                        }
                    }
                    
                    // Dim areas outside trim range
                    HStack(spacing: 0) {
                        // Left dimmed area
                        Rectangle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: geometry.size.width * appState.trimStart)
                        
                        // Selected range (transparent)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geometry.size.width * (appState.trimEnd - appState.trimStart))
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.accentColor, lineWidth: 2)
                            )
                        
                        // Right dimmed area
                        Rectangle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: geometry.size.width * (1 - appState.trimEnd))
                    }
                    
                    // Start handle
                    TrimHandle(position: appState.trimStart, width: geometry.size.width, isStart: true)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = min(value.location.x / geometry.size.width, appState.trimEnd - 0.01)
                                    appState.trimStart = max(0, newValue)
                                    isDraggingStart = true
                                }
                                .onEnded { _ in
                                    isDraggingStart = false
                                }
                        )
                    
                    // End handle
                    TrimHandle(position: appState.trimEnd, width: geometry.size.width, isStart: false)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = max(value.location.x / geometry.size.width, appState.trimStart + 0.01)
                                    appState.trimEnd = min(1, newValue)
                                    isDraggingEnd = true
                                }
                                .onEnded { _ in
                                    isDraggingEnd = false
                                }
                        )
                    
                    // Playhead
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2)
                        .offset(x: geometry.size.width * (currentPreviewTime / max(videoDuration, 1)))
                        .opacity(0.8)
                }
                .cornerRadius(4)
            }
            .frame(height: 50)
            .padding(.horizontal)
            
            // Time inputs
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TimeInputField(
                        time: Binding(
                            get: { appState.trimStart * videoDuration },
                            set: { appState.trimStart = $0 / videoDuration }
                        ),
                        maxTime: videoDuration
                    )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("End")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TimeInputField(
                        time: Binding(
                            get: { appState.trimEnd * videoDuration },
                            set: { appState.trimEnd = $0 / videoDuration }
                        ),
                        maxTime: videoDuration
                    )
                }
                
                Spacer()
                
                // Quick actions
                Button(action: { appState.trimStart = 0; appState.trimEnd = 1 }) {
                    Text("Reset")
                }
                .buttonStyle(.bordered)
                
                Button(action: applyTrim) {
                    Label("Apply Trim", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .onAppear {
            loadVideoInfo()
        }
        .onChange(of: appState.videoURL) { _, _ in
            loadVideoInfo()
        }
    }
    
    private func loadVideoInfo() {
        guard let url = appState.videoURL else { return }
        
        isLoadingThumbnails = true
        
        Task {
            let asset = AVURLAsset(url: url)
            if let duration = try? await asset.load(.duration) {
                await MainActor.run {
                    videoDuration = CMTimeGetSeconds(duration)
                }
            }
            
            // Generate thumbnails
            let editor = VideoEditor()
            let thumbs = await editor.generateTimelineThumbnails(from: url, count: 15)
            
            await MainActor.run {
                thumbnails = thumbs
                isLoadingThumbnails = false
            }
        }
    }
    
    private func applyTrim() {
        appState.currentTool = .none
        // The trim values are stored in appState and will be used during export
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let frames = Int((time.truncatingRemainder(dividingBy: 1)) * 30)
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }
}

struct TrimHandle: View {
    let position: Double
    let width: CGFloat
    let isStart: Bool
    
    var body: some View {
        ZStack {
            // Handle bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor)
                .frame(width: 12, height: 50)
            
            // Handle grip
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white)
                        .frame(width: 6, height: 2)
                }
            }
        }
        .offset(x: width * position - 6)
        .cursor(.resizeLeftRight)
    }
}

// Custom cursor modifier
extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    TrimView()
        .environmentObject(IAppState())
        .frame(height: 120)
}
