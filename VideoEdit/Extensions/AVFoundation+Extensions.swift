import AVFoundation

extension AVMetadataItem {

    var formattedDuration: String {
        let totalSeconds = CMTimeGetSeconds(duration)
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}


// MARK: - AVAsset

extension AVURLAsset {

    var fileSize: Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }

    private func getMetadata(key: AVMetadataIdentifier) async throws -> AVMetadataItem? {
        // Load the asset's metadata.
        let metadata = try await load(.metadata)
        let item = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier:  key)
        guard let first = item.first else { return nil }
        return first
    }

    private func getVideoTrack() async throws -> AVAssetTrack {
        let videoTracks = try await loadTracks(withMediaType: .video)
        guard let videoTrack = videoTracks.first else {
            fatalError("Could not load video track.")
        }
        return videoTrack
    }

    private func getNaturalSize(videoTrack: AVAssetTrack?) async throws -> CGSize {
        var track = try await getVideoTrack()
        if videoTrack != nil {
            track = videoTrack.unsafelyUnwrapped
        }
        return try await track.load(.naturalSize)
    }

    private func getFrameRate(videoTrack: AVAssetTrack?) async throws -> Float {
        var track = try await getVideoTrack()
        if videoTrack != nil {
            track = videoTrack.unsafelyUnwrapped
        }
        return try await track.load(.nominalFrameRate)
    }

    // Changed parameter type from CMFormatDescription.MediaSubType to FourCharCode
    private func fourCCToString(_ fourCC: FourCharCode) -> String {
        let bytes: [CChar] = [
            CChar(truncatingIfNeeded: (fourCC >> 24) & 0xFF),
            CChar(truncatingIfNeeded: (fourCC >> 16) & 0xFF),
            CChar(truncatingIfNeeded: (fourCC >> 8) & 0xFF),
            CChar(truncatingIfNeeded: fourCC & 0xFF),
            0
        ]
        return String(cString: bytes)
    }

    private func getCodec(videoTrack: AVAssetTrack?) async throws -> String? {
        var track = try await getVideoTrack()
        if videoTrack != nil {
            track = videoTrack.unsafelyUnwrapped
        }
        let descriptions = try await track.load(.formatDescriptions)
        if let formatDescription = descriptions.first {
            let fourCC = CMFormatDescriptionGetMediaSubType(formatDescription)
            return fourCCToString(fourCC)
        }

        return nil

    }

}

// MARK: - CMTime Extensions

extension CMTime {
    var displayString: String {
        let totalSeconds = CMTimeGetSeconds(self)
        guard totalSeconds.isFinite else { return "00:00" }

        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var displayStringWithFrames: String {
        let totalSeconds = CMTimeGetSeconds(self)
        guard totalSeconds.isFinite else { return "00:00:00" }

        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        let frames = Int((totalSeconds.truncatingRemainder(dividingBy: 1)) * 30)

        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
        }
        return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
    }

    static func from(seconds: Double) -> CMTime {
        CMTime(seconds: seconds, preferredTimescale: 600)
    }
}


// AVAudioListener extensions
extension AVAudioSampleListener {
    // Private class for delegate conformance
    internal class Delegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
        weak var listener: AVAudioSampleListener?
        let audioQueue = DispatchQueue(label: .dispatchQueueKey(.audioLevel))

        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            guard let listener = listener else { return }

            let samples = extractSamples(from: sampleBuffer)

            // Send to actor
            Task {
                await listener.processSamples(samples)
            }
        }

        private func extractSamples(from sampleBuffer: CMSampleBuffer) -> [Float] {
            // Extraction code...
            return []
        }
    }
}
