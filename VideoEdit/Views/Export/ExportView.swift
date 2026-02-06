import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ExportView: View {
    @EnvironmentObject var appState: IAppState
    @StateObject private var videoEditor = VideoEditor()
    @StateObject private var gifExporter = GIFExporter()
    
    @State private var selectedPreset: ExportPreset = .original
    @State private var customWidth: String = ""
    @State private var customHeight: String = ""
    @State private var maintainAspectRatio = true
    @State private var videoCodec: VideoCodec = .h264
    @State private var videoBitrate: VideoBitrate = .high
    @State private var audioBitrate: AudioBitrate = .standard
    @State private var estimatedSize: String = "--"
    @State private var isExporting = false
    @State private var exportError: String?
    
    enum ExportPreset: String, CaseIterable {
        case original = "Original"
        case hd1080 = "1080p HD"
        case hd720 = "720p HD"
        case sd480 = "480p SD"
        case instagram = "Instagram"
        case twitter = "Twitter/X"
        case tiktok = "TikTok"
        case custom = "Custom"
        
        var size: CGSize? {
            switch self {
            case .original: return nil
            case .hd1080: return CGSize(width: 1920, height: 1080)
            case .hd720: return CGSize(width: 1280, height: 720)
            case .sd480: return CGSize(width: 854, height: 480)
            case .instagram: return CGSize(width: 1080, height: 1080)
            case .twitter: return CGSize(width: 1280, height: 720)
            case .tiktok: return CGSize(width: 1080, height: 1920)
            case .custom: return nil
            }
        }
    }
    
    enum VideoCodec: String, CaseIterable {
        case h264 = "H.264"
        case hevc = "HEVC (H.265)"
        case prores = "ProRes"
    }
    
    enum VideoBitrate: String, CaseIterable {
        case low = "Low (5 Mbps)"
        case medium = "Medium (10 Mbps)"
        case high = "High (20 Mbps)"
        case veryHigh = "Very High (50 Mbps)"
        
        var value: Int {
            switch self {
            case .low: return 5_000_000
            case .medium: return 10_000_000
            case .high: return 20_000_000
            case .veryHigh: return 50_000_000
            }
        }
    }
    
    enum AudioBitrate: String, CaseIterable {
        case low = "Low (64 kbps)"
        case standard = "Standard (128 kbps)"
        case high = "High (256 kbps)"
        case lossless = "Lossless"
        
        var value: Int {
            switch self {
            case .low: return 64_000
            case .standard: return 128_000
            case .high: return 256_000
            case .lossless: return 320_000
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(appState.exportFormat == .gif ? "Export as GIF" : "Export Video")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { appState.showExportSheet = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Format selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Format")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            FormatButton(
                                icon: "film",
                                title: "Video",
                                subtitle: "MP4/MOV",
                                isSelected: appState.exportFormat == .movie
                            ) {
                                appState.exportFormat = .movie
                            }
                            
                            FormatButton(
                                icon: "photo.on.rectangle",
                                title: "GIF",
                                subtitle: "Animated",
                                isSelected: appState.exportFormat == .gif
                            ) {
                                appState.exportFormat = .gif
                            }
                            
                            FormatButton(
                                icon: "photo.stack",
                                title: "APNG",
                                subtitle: "Animated PNG",
                                isSelected: appState.exportFormat == .animatedPNG
                            ) {
                                appState.exportFormat = .animatedPNG
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Size/resolution
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Size")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(ExportPreset.allCases, id: \.self) { preset in
                                Text(preset.rawValue).tag(preset)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        if selectedPreset == .custom {
                            HStack {
                                TextField("Width", text: $customWidth)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                
                                Text("×")
                                
                                TextField("Height", text: $customHeight)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                
                                Toggle("Lock Ratio", isOn: $maintainAspectRatio)
                            }
                        }
                    }
                    
                    // GIF-specific settings
                    if appState.exportFormat == .gif || appState.exportFormat == .animatedPNG {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Animation Settings")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("Frame Rate")
                                Spacer()
                                Picker("", selection: $appState.gifFrameRate) {
                                    Text("10 fps").tag(10)
                                    Text("15 fps").tag(15)
                                    Text("20 fps").tag(20)
                                    Text("25 fps").tag(25)
                                    Text("30 fps").tag(30)
                                }
                                .pickerStyle(.menu)
                                .frame(width: 100)
                            }
                            
                            HStack {
                                Text("Scale")
                                Spacer()
                                Slider(value: $appState.gifScale, in: 0.25...1.0, step: 0.25)
                                    .frame(width: 150)
                                Text("\(Int(appState.gifScale * 100))%")
                                    .frame(width: 40)
                            }
                            
                            Toggle("Optimize for smaller file size", isOn: $appState.gifOptimize)
                            
                            HStack {
                                Text("Loop")
                                Spacer()
                                Picker("", selection: $appState.gifLoopCount) {
                                    Text("Forever").tag(0)
                                    Text("Once").tag(1)
                                    Text("Twice").tag(2)
                                    Text("3 times").tag(3)
                                }
                                .pickerStyle(.menu)
                                .frame(width: 100)
                            }
                        }
                    }
                    
                    // Video-specific settings
                    if appState.exportFormat == .movie {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Video Settings")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                Text("Codec")
                                Spacer()
                                Picker("", selection: $videoCodec) {
                                    ForEach(VideoCodec.allCases, id: \.self) { codec in
                                        Text(codec.rawValue).tag(codec)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 150)
                            }
                            
                            HStack {
                                Text("Video Quality")
                                Spacer()
                                Picker("", selection: $videoBitrate) {
                                    ForEach(VideoBitrate.allCases, id: \.self) { bitrate in
                                        Text(bitrate.rawValue).tag(bitrate)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180)
                            }
                            
                            HStack {
                                Text("Audio Quality")
                                Spacer()
                                Picker("", selection: $audioBitrate) {
                                    ForEach(AudioBitrate.allCases, id: \.self) { bitrate in
                                        Text(bitrate.rawValue).tag(bitrate)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180)
                            }
                        }
                    }
                    
                    // Trim info if applicable
                    if appState.trimStart > 0 || appState.trimEnd < 1 {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trim Applied")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Only the selected portion will be exported.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Crop info if applicable
                    if !appState.cropRect.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Crop Applied")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("The video will be cropped to the selected area.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Export progress or button
            VStack(spacing: 12) {
                if isExporting {
                    VStack(spacing: 8) {
                        ProgressView(value: appState.exportFormat == .gif ? gifExporter.progress : videoEditor.progress)
                        
                        Text("Exporting... \(Int((appState.exportFormat == .gif ? gifExporter.progress : videoEditor.progress) * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Estimated Size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(estimatedSize)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Button("Cancel") {
                            appState.showExportSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Export") {
                            performExport()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                if let error = exportError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .frame(width: 450, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            updateEstimatedSize()
        }
    }
    
    private func updateEstimatedSize() {
        // Simple estimation
        guard let url = appState.videoURL else { return }
        
        Task {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                
                var estimatedBytes = size
                
                // Adjust for format
                if appState.exportFormat == .gif {
                    estimatedBytes = Int64(Double(size) * 0.3) // GIFs are typically larger per frame but shorter
                }
                
                // Adjust for scale
                estimatedBytes = Int64(Double(estimatedBytes) * appState.gifScale * appState.gifScale)
                
                await MainActor.run {
                    estimatedSize = ByteCountFormatter.string(fromByteCount: estimatedBytes, countStyle: .file)
                }
            }
        }
    }
    
    private func performExport() {
        guard let sourceURL = appState.videoURL else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = appState.exportFormat == .gif ? [.gif] : 
        appState.exportFormat == .animatedPNG ? [.png] : [.mpeg4Movie]
        
        let defaultName: String
        switch appState.exportFormat {
        case .gif, .animatedGIF: defaultName = "export.gif"
        case .animatedPNG: defaultName = "export.png"
        case .movie, .video: defaultName = "export.mp4"
            
            panel.nameFieldStringValue = defaultName
            
            guard panel.runModal() == .OK, let outputURL = panel.url else { return }
            
            isExporting = true
            exportError = nil
            
            Task {
                do {
                    switch appState.exportFormat {
                    case .gif, .animatedGIF:
                        gifExporter.frameRate = appState.gifFrameRate
                        gifExporter.scale = appState.gifScale
                        gifExporter.optimize = appState.gifOptimize
                        gifExporter.loopCount = appState.gifLoopCount
                        
                        if !appState.cropRect.isEmpty {
                            gifExporter.cropRect = appState.cropRect
                        }
                        
                        try await gifExporter.exportToGIF(from: sourceURL, to: outputURL)
                        
                    case .animatedPNG:
                        gifExporter.frameRate = appState.gifFrameRate
                        gifExporter.scale = appState.gifScale
                        try await gifExporter.exportToAnimatedPNG(from: sourceURL, to: outputURL)
                        
                    case .movie, .video:
                        // Apply trim if needed
                        if appState.trimStart > 0 || appState.trimEnd < 1 {
                            let asset = AVURLAsset(url: sourceURL)
                            let duration = try await asset.load(.duration)
                            let durationSeconds = CMTimeGetSeconds(duration)
                            
                            try await videoEditor.trimVideo(
                                sourceURL: sourceURL,
                                outputURL: outputURL,
                                startTime: appState.trimStart * durationSeconds,
                                endTime: appState.trimEnd * durationSeconds
                            )
                        } else {
                            // Just copy with settings applied
                            try FileManager.default.copyItem(at: sourceURL, to: outputURL)
                        }
                    }
                    
                    await MainActor.run {
                        isExporting = false
                        appState.showExportSheet = false
                        
                        // Show in Finder
                        NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: outputURL.deletingLastPathComponent().path)
                    }
                } catch {
                    await MainActor.run {
                        isExporting = false
                        exportError = error.localizedDescription
                    }
                }
            }
        }
    }
}
#Preview {
    ExportView()
        .environmentObject(IAppState())
}
