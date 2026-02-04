//
//  AVCaptureDevice+Actor.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-02.
//

import AVFoundation
import Accelerate
import Combine

actor VCaptureDevice {

    private let captureSession = AVCaptureSession()
  //  private var videoDelegate = VideoOutputDelegate()
    private var audioLevel: Float = 0.0


}


extension VCaptureDevice {

    // Private class for delegate conformance
    private class Delegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
        weak var manager: AVCaptureDevice?
        let audioQueue = DispatchQueue(label: "audio.queue")

        func captureOutput(_ output: AVCaptureOutput,
                           didOutput sampleBuffer: CMSampleBuffer,
                           from connection: AVCaptureConnection) {
            guard let manager = manager else { return }

           // let samples = extractSamples(from: sampleBuffer)

            // Send to actor
            Task {
             //   await manager.processSamples(samples)
            }
        }
    }

        private func extractSamples(from sampleBuffer: CMSampleBuffer) -> [Float] {
            // Extraction code...
            return []
        }

        private func processSamples(_ samples: [Float]) {
            // Actor-isolated processing
            let rms = samples.reduce(0.0) { $0 + $1 * $1 } / Float(samples.count)
            audioLevel = 20 * log10(sqrt(rms))
        }

        func getAudioLevel() -> Float {
            return audioLevel
        }
}
