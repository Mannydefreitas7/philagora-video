import Foundation
import AVFoundation
import AVKit
import CoreImage
import AppKit

@MainActor
class VideoEditor: ObservableObject {
    @Published var progress: Double = 0
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // MARK: - Trim Video
    
    func trimVideo(
        sourceURL: URL,
        outputURL: URL,
        startTime: Double,
        endTime: Double
    ) async throws {
        isProcessing = true
        progress = 0
        
        defer {
            isProcessing = false
        }
        
        let asset = AVURLAsset(url: sourceURL)

        // Create export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoEditorError.exportSessionCreationFailed
        }
        
        // Set time range
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.timeRange = timeRange
        
        // Remove existing file
        try? FileManager.default.removeItem(at: outputURL)

        _ = try await exportSession.export(to: outputURL, as: .mp4)
        
        progress = 1.0
    }
    
    // MARK: - Crop Video
    
    func cropVideo(
        sourceURL: URL,
        outputURL: URL,
        cropRect: CGRect,
        videoSize: CGSize
    ) async throws {
        isProcessing = true
        progress = 0
        
        defer {
            isProcessing = false
        }
        
        let asset = AVURLAsset(url: sourceURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoEditorError.noVideoTrack
        }
        
        let naturalSize = try await videoTrack.load(.naturalSize)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        
        // Calculate actual video size considering transform
        var videoWidth = naturalSize.width
        var videoHeight = naturalSize.height
        
        if preferredTransform.a == 0 {
            // Video is rotated
            videoWidth = naturalSize.height
            videoHeight = naturalSize.width
        }
        
        // Scale crop rect to actual video dimensions
        let scaleX = videoWidth / videoSize.width
        let scaleY = videoHeight / videoSize.height
        
        let scaledCropRect = CGRect(
            x: cropRect.origin.x * scaleX,
            y: cropRect.origin.y * scaleY,
            width: cropRect.width * scaleX,
            height: cropRect.height * scaleY
        )
        
        // Create composition
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()

        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoEditorError.compositionFailed
        }
        
        let duration = try await asset.load(.duration)
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        
        try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        
        // Add audio if present
        if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) {
            try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
        }
        
        // Create instruction for cropping
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)

        // Create transform to crop
        var transform = preferredTransform
        transform = transform.translatedBy(x: -scaledCropRect.origin.x, y: -scaledCropRect.origin.y)
        layerInstruction.setTransform(transform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = scaledCropRect.size
        
        let frameRate = try await videoTrack.load(.nominalFrameRate)
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
        
        // Export
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoEditorError.exportSessionCreationFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        try? FileManager.default.removeItem(at: outputURL)

        _ = try await exportSession.export(to: outputURL, as: .mp4)
        
        progress = 1.0
    }
    
    // MARK: - Resize Video
    
     func resizeVideo(
        sourceURL: URL,
        outputURL: URL,
        targetSize: CGSize
     ) async throws -> AVAssetExportSession {
        isProcessing = true
        
        defer {
            isProcessing = false
        }
        
        let asset = AVURLAsset(url: sourceURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw VideoEditorError.noVideoTrack
        }
        
        let naturalSize = try await videoTrack.load(.naturalSize)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        
        // Create composition
        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw VideoEditorError.compositionFailed
        }
        
        let duration = try await asset.load(.duration)
        let timeRange = CMTimeRange(start: .zero, duration: duration)
        
        try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        
        // Add audio if present
        if let audioTrack = try await asset.loadTracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) {
            try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
        }
        
        // Calculate scale
        let scaleX = targetSize.width / naturalSize.width
        let scaleY = targetSize.height / naturalSize.height
        let scale = min(scaleX, scaleY)
        
        // Create instruction for resizing
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        var transform = preferredTransform
        transform = transform.scaledBy(x: scale, y: scale)
        layerInstruction.setTransform(transform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        
        videoComposition.instructions = [instruction]
        videoComposition.renderSize = targetSize
        
        let frameRate = try await videoTrack.load(.nominalFrameRate)
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
        
        // Export
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoEditorError.exportSessionCreationFailed
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        try? FileManager.default.removeItem(at: outputURL)

        _ = try await exportSession.export(to: outputURL, as: .mp4)
        return exportSession

    }
    
    // MARK: - Get Video Thumbnail
    
    func generateThumbnail(from url: URL, at time: Double = 0) async throws -> CGImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)

        let (image, actualTime) = try await imageGenerator.image(at: cmTime)
        return image
    }

    func getIntervalTimes(from asset: AVAsset, intervals n: Int, includeEnd: Bool = false) async -> [CMTime] {
        guard let duration = try? await asset.load(.duration) else { return [] }

        let totalSeconds = duration.seconds
        let intervalDuration = totalSeconds / Double(n)

        let count = includeEnd ? n + 1 : n

        return (0..<count).map { i in
            CMTime(seconds: intervalDuration * Double(i), preferredTimescale: 600)
        }
    }


    // MARK: - Generate Timeline Thumbnails
    
    func generateTimelineThumbnails(
        from url: URL,
        count: Int = 10
    ) async -> [CGImage] {
        var thumbnails: [CGImage] = []
        let asset = AVURLAsset(url: url)

        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 200, height: 200)

        let times: [CMTime] = await getIntervalTimes(from: asset, intervals: count) //å array of times at which to create images.
        for await result in imageGenerator.images(for: times) {
            switch result {
            case .success(requestedTime: let requested, image: let image, actualTime: let actual):
                // Process the image for the requested time.
                thumbnails.append(image)
            case .failure(requestedTime: let requested, error: let error):
                // Handle the failure for the requested time.
                print("Error generating thumbnail at \(requested): \(error)")
            }
        }
        
        return thumbnails
    }
}

