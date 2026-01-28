//
//  AVAudioLevel+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-26.
//

import AVFoundation
import Accelerate

actor AVAudioLevelMonitor: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let audioQueue = DispatchQueue(label: .dispatchQueueKey(.audioLevel))
    private let audioDataOutput = AVCaptureAudioDataOutput()
    var audioLevel: Float = 0
    // Callback for audio level updates
    private var onLevelUpdate: (@Sendable (Float) -> Void)?
    private(set) var history: [Float] = []
    private let historyCapacity: Int = 48
    private let smoothing: Float = 0.75
    private let gain: Float = 18

    private func updateLevel(_ level: Float) -> Void {
        self.audioLevel = level
    }

    nonisolated func snapshot() async -> Float {
        return await audioLevel
    }

    func onChange(_ handler: @escaping @Sendable (Float) -> Void) async {
        self.onLevelUpdate = handler
    }

    // AVCaptureAudioDataOutputSampleBufferDelegate method
    nonisolated
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let gain = max(0.1, self.gain)
       // let level = calculateAudioLevel(from: sampleBuffer)
        let alpha = Float(rms(from: sampleBuffer))
        let normalized = min(max(alpha * gain, 0), 1)

        Task { @MainActor in
            await self.notifyLevelUpdate(normalized)
        }
    }

    private func push(_ newLevel: Float) async {
        let smoothed = (audioLevel * smoothing) + (newLevel * (1 - smoothing))

        var nextHistory = history
        nextHistory.append(smoothed)
        if nextHistory.count > historyCapacity {
            nextHistory.removeFirst(nextHistory.count - historyCapacity)
        }

        audioLevel = smoothed
        history = nextHistory
    }

    nonisolated
    func startMonitor() async -> AVCaptureAudioDataOutput {
        await audioDataOutput.setSampleBufferDelegate(self, queue: audioQueue)
        return await audioDataOutput
    }

    /// Verifies that the audio input is properly connected to the audio data output.
    func verifyAudioConfiguration(_ audioInput: AVCaptureDeviceInput?) {
        guard let audioInput else {
            logger.error("No active audio input configured!")
            return
        }

        logger.debug("Active audio device: \(audioInput.device.localizedName)")

        // Check if the audio data output has a valid connection
        if let audioConnection = audioDataOutput.connection(with: .audio) {
            logger.debug("Audio connection found - enabled: \(audioConnection.isEnabled), active: \(audioConnection.isActive)")

            if !audioConnection.isEnabled {
                logger.warning("Audio connection is disabled. Attempting to enable...")
                audioConnection.isEnabled = true
            }
        } else {
            logger.error("⚠️ NO AUDIO CONNECTION - This is why you're getting zeros!")
            logger.error("Audio input ports: \(audioInput.ports)")
            logger.error("Audio output connections: \(self.audioDataOutput.connections)")
        }
    }

    @MainActor
    private func notifyLevelUpdate(_ level: Float) async {
        await onLevelUpdate?(level)
        await updateLevel(level)
    }

    private nonisolated func calculateAudioLevel(from sampleBuffer: CMSampleBuffer) -> Float {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return 0.0
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?

        CMBlockBufferGetDataPointer(blockBuffer,
                                    atOffset: 0,
                                    lengthAtOffsetOut: nil,
                                    totalLengthOut: &length,
                                    dataPointerOut: &dataPointer)

        guard let data = dataPointer else { return 0.0 }

        // Convert to Float array
        let samples = UnsafeBufferPointer<Int16>(
            start: UnsafeRawPointer(data).assumingMemoryBound(to: Int16.self),
            count: length / MemoryLayout<Int16>.size
        )

        // Calculate RMS (Root Mean Square) level
        var sum: Float = 0
        for sample in samples {
            let normalized = Float(sample) / Float(Int16.max)
            sum += normalized * normalized
        }

        let rms = sqrt(sum / Float(samples.count))

        // Convert to decibels (dB)
        let db = 20 * log10(rms)

        // Normalize to 0-1 range (assuming -50 dB to 0 dB range)
        let normalizedLevel = max(0, min(1, (db + 50) / 50))

        return normalizedLevel
    }


    private nonisolated func rms(from sampleBuffer: CMSampleBuffer) -> Double {
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return 0 }
        guard let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return 0 }
        let asbd = asbdPtr.pointee

        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return 0 }

        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?

        let status = CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: &lengthAtOffset,
            totalLengthOut: &totalLength,
            dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr,
              let dataPointer,
              totalLength > 0 else { return 0 }

        // Common cases from AVCaptureAudioDataOutput:
        // - 16-bit signed int PCM
        // - 32-bit float PCM
        let isFloat = (asbd.mFormatFlags & kAudioFormatFlagIsFloat) != 0
        let bytesPerFrame = Int(asbd.mBytesPerFrame)
        let channels = Int(asbd.mChannelsPerFrame)
        guard bytesPerFrame > 0, channels > 0 else { return 0 }

        // Treat interleaved samples as one long vector.
        if isFloat {
            let sampleCount = totalLength / MemoryLayout<Float>.size
            guard sampleCount > 0 else { return 0 }

            let floatPtr = dataPointer.withMemoryRebound(to: Float.self, capacity: sampleCount) { $0 }

            var sumSquares: Float = 0
            vDSP_svesq(floatPtr, 1, &sumSquares, vDSP_Length(sampleCount))
            let meanSquares = sumSquares / Float(sampleCount)
            return Double(sqrt(meanSquares))
        } else {
            // Assume signed integer PCM (typically Int16)
            if asbd.mBitsPerChannel == 16 {
                let sampleCount = totalLength / MemoryLayout<Int16>.size
                guard sampleCount > 0 else { return 0 }

                let int16Ptr = dataPointer.withMemoryRebound(to: Int16.self, capacity: sampleCount) { $0 }

                // Convert to float in [-1, 1] then compute RMS.
                var floatBuf = [Float](repeating: 0, count: sampleCount)
                vDSP_vflt16(int16Ptr, 1, &floatBuf, 1, vDSP_Length(sampleCount))

                var scale: Float = 1.0 / Float(Int16.max)
                vDSP_vsmul(floatBuf, 1, &scale, &floatBuf, 1, vDSP_Length(sampleCount))

                var sumSquares: Float = 0
                vDSP_svesq(floatBuf, 1, &sumSquares, vDSP_Length(sampleCount))
                let meanSquares = sumSquares / Float(sampleCount)
                return Double(sqrt(meanSquares))
            } else {
                // Fallback: unknown integer depth
                return 0
            }
        }
    }
}
