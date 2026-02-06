import SwiftUI

struct VideoTimeline: View {
    @EnvironmentObject var appState: IAppState
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1

    var body: some View {
        VStack(spacing: 8) {
            // Waveform / thumbnail strip (simplified)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: geometry.size.width * currentTime / max(duration, 1))

                    // Playhead
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 2)
                        .offset(x: geometry.size.width * currentTime / max(duration, 1))
                }
            }
            .frame(height: 30)
            .padding(.horizontal)

            // Time display
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatTime(duration))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let frames = Int((time.truncatingRemainder(dividingBy: 1)) * 30)
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }
}
