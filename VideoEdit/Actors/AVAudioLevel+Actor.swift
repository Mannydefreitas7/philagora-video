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
    var audioLevel: Float = 0
    // Callback for audio level updates
    private var onLevelUpdate: (@Sendable (Float) -> Void)?

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
        let level = calculateAudioLevel(from: sampleBuffer)

        Task { @MainActor in
            await self.notifyLevelUpdate(level)
        }
    }

    nonisolated
    func start(with audioOutput: AVCaptureAudioDataOutput) -> AVCaptureAudioDataOutput {
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        return audioOutput
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
}
