import SwiftUI
import AVFoundation

struct CropView: View {
    @EnvironmentObject var appState: IAppState
    @State private var selectedAspectRatio: AspectRatio = .free
    @State private var customWidth: String = ""
    @State private var customHeight: String = ""

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Crop")
                    .font(.headline)
                
                Spacer()
                
                Button("Reset") {
                    appState.cropRect = .zero
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            
            Divider()
            
            // Aspect ratio presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Aspect Ratio")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(AspectRatio.allCases, id: \.self) { ratio in
                        AspectRatioButton(
                            ratio: ratio,
                            isSelected: selectedAspectRatio == ratio
                        ) {
                            selectedAspectRatio = ratio
                            applyAspectRatio(ratio)
                        }
                    }
                }
            }
            
            // Custom size inputs
            if selectedAspectRatio == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Size")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Width", text: $customWidth)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        
                        Text("×")
                        
                        TextField("Height", text: $customHeight)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        
                        Button("Apply") {
                            applyCustomSize()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            
            Divider()
            
            // Current crop info
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Crop")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !appState.cropRect.isEmpty {
                    HStack {
                        Text("Size:")
                        Spacer()
                        Text("\(Int(appState.cropRect.width)) × \(Int(appState.cropRect.height))")
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("Position:")
                        Spacer()
                        Text("(\(Int(appState.cropRect.origin.x)), \(Int(appState.cropRect.origin.y)))")
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                } else {
                    Text("No crop applied")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Apply button
            Button(action: applyCrop) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Apply Crop")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(appState.cropRect.isEmpty)
        }
        .padding()
    }
    
    private func applyAspectRatio(_ ratio: AspectRatio) {
        guard let videoURL = appState.videoURL else { return }
        
        Task {
            let asset = AVAsset(url: videoURL)
            guard let track = try? await asset.loadTracks(withMediaType: .video).first,
                  let size = try? await track.load(.naturalSize) else { return }
            
            await MainActor.run {
                if let aspectRatio = ratio.ratio {
                    let width = size.width
                    let height = width / aspectRatio
                    
                    let x = (size.width - width) / 2
                    let y = (size.height - height) / 2
                    
                    appState.cropRect = CGRect(
                        x: max(0, x),
                        y: max(0, y),
                        width: min(width, size.width),
                        height: min(height, size.height)
                    )
                }
            }
        }
    }
    
    private func applyCustomSize() {
        guard let width = Double(customWidth),
              let height = Double(customHeight) else { return }
        
        appState.cropRect = CGRect(
            x: appState.cropRect.origin.x,
            y: appState.cropRect.origin.y,
            width: width,
            height: height
        )
    }
    
    private func applyCrop() {
        appState.currentTool = .none
    }
}

#Preview {
    CropView()
        .environmentObject(IAppState())
        .frame(width: 280)
}
