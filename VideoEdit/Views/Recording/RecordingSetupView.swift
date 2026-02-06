import SwiftUI
import ScreenCaptureKit

struct RecordingSetupView: View {
    @ObservedObject var recorder: ScreenRecorder
    @ObservedObject var appState: IAppState
    let startAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Capture mode selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Capture Mode")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack(spacing: 12) {
                        CaptureModeButton(
                            icon: "display",
                            title: "Full Screen",
                            isSelected: recorder.captureMode == .display
                        ) {
                            recorder.captureMode = .display
                        }

                        CaptureModeButton(
                            icon: "macwindow",
                            title: "Window",
                            isSelected: recorder.captureMode == .window
                        ) {
                            recorder.captureMode = .window
                        }

                        CaptureModeButton(
                            icon: "crop",
                            title: "Area",
                            isSelected: recorder.captureMode == .area
                        ) {
                            recorder.captureMode = .area
                        }
                    }
                }

                // Display/Window selection
                if recorder.captureMode == .display {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Picker("", selection: $recorder.selectedDisplay) {
                            ForEach(recorder.availableDisplays, id: \.displayID) { display in
                                Text("Display \(display.displayID) (\(Int(display.width))×\(Int(display.height)))")
                                    .tag(Optional(display))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } else if recorder.captureMode == .window {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Window")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Picker("", selection: $recorder.selectedWindow) {
                            ForEach(recorder.availableWindows, id: \.windowID) { window in
                                HStack {
                                    if let appName = window.owningApplication?.applicationName {
                                        Text(appName)
                                    }
                                    if let title = window.title, !title.isEmpty {
                                        Text("- \(title)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .tag(Optional(window))
                            }
                        }
                        .pickerStyle(.menu)

                        Button("Refresh Windows") {
                            Task {
                                await recorder.refreshAvailableContent()
                            }
                        }
                        .font(.caption)
                    }
                }

                Divider()

                // Audio settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Audio")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Toggle("Record Microphone", isOn: $appState.recordMicrophone)
                    Toggle("Record System Audio", isOn: $appState.recordSystemAudio)
                }

                Divider()

                // Video settings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Video Settings")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Toggle("Show Cursor", isOn: .constant(true))
                    Toggle("Visualize Mouse Clicks", isOn: $appState.visualizeClicks)

                    Picker("Quality", selection: $appState.recordingQuality) {
                        ForEach(RecordingQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                // Camera overlay
                VStack(alignment: .leading, spacing: 12) {
                    Text("Camera Overlay")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Toggle("Show Camera Overlay", isOn: $appState.showCameraOverlay)

                    if appState.showCameraOverlay {
                        Text("Camera overlay will appear in the corner of your recording.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }

        Divider()

        // Start button
        HStack {
            Spacer()

            Button(action: startAction) {
                HStack {
                    Image(systemName: "record.circle")
                    Text("Start Recording")
                }
                .frame(width: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.red)

            Spacer()
        }
        .padding()
    }
}
