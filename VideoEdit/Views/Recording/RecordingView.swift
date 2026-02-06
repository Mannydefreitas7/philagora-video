import SwiftUI
import ScreenCaptureKit
import AVFoundation

struct IRecordingView: View {
    @EnvironmentObject var appState: IAppState
    @StateObject private var recorder = ScreenRecorder()
    @State private var recordingURL: URL?
    @State private var showingRecordingControls = false
    @State private var countdownValue = 0
    @State private var isCountingDown = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Screen Recording")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { appState.showRecordingSheet = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            if recorder.isRecording || showingRecordingControls {
                // Recording in progress view
                RecordingInProgressView(recorder: recorder) {
                    stopRecording()
                }
            } else {
                // Setup view
                RecordingSetupView(recorder: recorder, appState: appState) {
                    startRecording()
                }
            }
        }
        .frame(width: 500, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
    }


    private func startRecording() {
        // Start countdown
        isCountingDown = true
        countdownValue = 3
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdownValue -= 1
            if countdownValue <= 0 {
                timer.invalidate()
                isCountingDown = false
                
                // Start actual recording
                Task { @MainActor in
                    do {
                        recorder.recordMicrophone = appState.recordMicrophone
                        recorder.recordSystemAudio = appState.recordSystemAudio
                        recorder.showCursor = true
                        recorder.highlightClicks = appState.visualizeClicks
                        recorder.quality = appState.recordingQuality
                        
                        recordingURL = try await recorder.startRecording()
                        showingRecordingControls = true
                        
                        // Minimize the sheet during recording
                        appState.showRecordingSheet = false
                    } catch {
                        print("Failed to start recording: \(error)")
                    }
                }
            }
        }
    }
    
    private func stopRecording() {
        Task {
            do {
                let url = try await recorder.stopRecording()
                await MainActor.run {
                    appState.videoURL = url
                    appState.showRecordingSheet = false
                    showingRecordingControls = false
                }
            } catch {
                print("Failed to stop recording: \(error)")
            }
        }
    }
}
