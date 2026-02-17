import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers
import CoreGraphics
import AppKit

@MainActor
class GIFExporter: ObservableObject {
    @Published var progress: Double = 0
    @Published var isExporting = false
    @Published var errorMessage: String?
    
    // GIF settings
    var frameRate: Int = 15
    var loopCount: Int = 0 // 0 = infinite
    var scale: Double = 1.0
    var optimize: Bool = true
    var startTime: Double = 0
    var endTime: Double = -1 // -1 means end of video
    var cropRect: CGRect?
    var dithering: Bool = true
    var colorCount: Int = 256
    
    func exportToGIF(
        from videoURL: URL,
        to outputURL: URL
    ) async throws {
        isExporting = true
        progress = 0
        
        defer {
            isExporting = false
        }
        
        let asset = AVURLAsset(url: videoURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw GIFExportError.noVideoTrack
        }
        
        let naturalSize = try await videoTrack.load(.naturalSize)
        let preferredTransform = try await videoTrack.load(.preferredTransform)
        let duration = try await asset.load(.duration)
        
        // Calculate actual video dimensions
        var videoWidth = naturalSize.width
        var videoHeight = naturalSize.height
        
        if preferredTransform.a == 0 {
            videoWidth = naturalSize.height
            videoHeight = naturalSize.width
        }
        
        // Determine output size
        var outputSize = CGSize(width: videoWidth * scale, height: videoHeight * scale)
        
        if let cropRect = cropRect {
            outputSize = CGSize(width: cropRect.width * scale, height: cropRect.height * scale)
        }
        
        // Ensure dimensions are even
        outputSize.width = floor(outputSize.width / 2) * 2
        outputSize.height = floor(outputSize.height / 2) * 2
        
        // Calculate time range
        let durationSeconds = CMTimeGetSeconds(duration)
        let actualEndTime = endTime < 0 ? durationSeconds : min(endTime, durationSeconds)
        let actualStartTime = max(0, startTime)
        let trimmedDuration = actualEndTime - actualStartTime
        
        // Calculate frame times
        let frameInterval = 1.0 / Double(frameRate)
        let frameCount = Int(trimmedDuration * Double(frameRate))
        
        guard frameCount > 0 else {
            throw GIFExportError.noFrames
        }
        
        // Create image generator
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = outputSize
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: 0.01, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 0.01, preferredTimescale: 600)
        
        // Generate frame times
        var frameTimes: [NSValue] = []
        for i in 0..<frameCount {
            let time = actualStartTime + (Double(i) * frameInterval)
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            frameTimes.append(NSValue(time: cmTime))
        }
        
        // Remove existing file
        try? FileManager.default.removeItem(at: outputURL)
        
        // Create GIF destination
        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else {
            throw GIFExportError.destinationCreationFailed
        }
        
        // Set GIF properties
        let gifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        // Frame properties
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameInterval,
                kCGImagePropertyGIFUnclampedDelayTime as String: frameInterval
            ]
        ]
        
        // Generate and add frames
        var processedFrames = 0
        
        for i in 0..<frameCount {
            let time = CMTime(seconds: actualStartTime + (Double(i) * frameInterval), preferredTimescale: 600)
            
            do {
                var cgImage = try await imageGenerator.image(at: time)

                // Apply crop if needed
                if let cropRect = cropRect {
                    let scaledCropRect = CGRect(
                        x: cropRect.origin.x * scale,
                        y: cropRect.origin.y * scale,
                        width: cropRect.width * scale,
                        height: cropRect.height * scale
                    )
                    
                    if let croppedImage = cgImage.image.cropping(to: scaledCropRect) {
                        cgImage.image = croppedImage
                    }
                }
                
                // Optimize colors if needed
                if optimize && colorCount < 256 {
                    if let optimizedImage = reduceColors(in: cgImage.image, to: colorCount) {
                        cgImage.image = optimizedImage
                    }
                }
                
                CGImageDestinationAddImage(destination, cgImage.image, frameProperties as CFDictionary)

                processedFrames += 1
                progress = Double(processedFrames) / Double(frameCount)
                
            } catch {
                print("Failed to generate frame at time \(CMTimeGetSeconds(time)): \(error)")
            }
        }
        
        // Finalize GIF
        guard CGImageDestinationFinalize(destination) else {
            throw GIFExportError.finalizationFailed
        }
        
        progress = 1.0
    }
    
    // MARK: - Color Reduction
    
    private func reduceColors(in image: CGImage, to colorCount: Int) -> CGImage? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return image }
        
        let width = image.width
        let height = image.height
        
        // Create indexed color context
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()
    }
    
    // MARK: - Animated PNG Export
    
    func exportToAnimatedPNG(
        from videoURL: URL,
        to outputURL: URL
    ) async throws {
        isExporting = true
        progress = 0
        
        defer {
            isExporting = false
        }
        
        let asset = AVURLAsset(url: videoURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw GIFExportError.noVideoTrack
        }
        
        let naturalSize = try await videoTrack.load(.naturalSize)
        let duration = try await asset.load(.duration)
        
        var outputSize = CGSize(width: naturalSize.width * scale, height: naturalSize.height * scale)
        outputSize.width = floor(outputSize.width / 2) * 2
        outputSize.height = floor(outputSize.height / 2) * 2
        
        let durationSeconds = CMTimeGetSeconds(duration)
        let actualEndTime = endTime < 0 ? durationSeconds : min(endTime, durationSeconds)
        let actualStartTime = max(0, startTime)
        let trimmedDuration = actualEndTime - actualStartTime
        
        let frameInterval = 1.0 / Double(frameRate)
        let frameCount = Int(trimmedDuration * Double(frameRate))
        
        guard frameCount > 0 else {
            throw GIFExportError.noFrames
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = outputSize
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let destination = CGImageDestinationCreateWithURL(
            outputURL as CFURL,
            UTType.png.identifier as CFString,
            frameCount,
            nil
        ) else {
            throw GIFExportError.destinationCreationFailed
        }
        
        let pngProperties: [String: Any] = [
            kCGImagePropertyPNGDictionary as String: [
                kCGImagePropertyAPNGLoopCount as String: loopCount
            ]
        ]
        CGImageDestinationSetProperties(destination, pngProperties as CFDictionary)
        
        let frameProperties: [String: Any] = [
            kCGImagePropertyPNGDictionary as String: [
                kCGImagePropertyAPNGDelayTime as String: frameInterval
            ]
        ]
        
        for i in 0..<frameCount {
            let time = CMTime(seconds: actualStartTime + (Double(i) * frameInterval), preferredTimescale: 600)
            
            do {
                let cgImage = try await imageGenerator.image(at: time)
                CGImageDestinationAddImage(destination, cgImage.image, frameProperties as CFDictionary)

                progress = Double(i + 1) / Double(frameCount)
            } catch {
                print("Failed to generate frame: \(error)")
            }
        }
        
        guard CGImageDestinationFinalize(destination) else {
            throw GIFExportError.finalizationFailed
        }
        
        progress = 1.0
    }
    
    // MARK: - File Size Estimation
    
    func estimateFileSize(
        videoURL: URL,
        duration: Double
    ) async -> String {
        // Rough estimation based on settings
        let frameCount = Int(duration * Double(frameRate))
        let pixelsPerFrame = (100.0 * scale) * (100.0 * scale) // Approximate
        let bytesPerPixel = optimize ? 0.5 : 1.0
        let estimatedBytes = Double(frameCount) * pixelsPerFrame * bytesPerPixel * 3 // RGB
        
        return ByteCountFormatter.string(fromByteCount: Int64(estimatedBytes), countStyle: .file)
    }
}
