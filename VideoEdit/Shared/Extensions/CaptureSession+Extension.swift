//
//  CaptureSession+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import AVFoundation
import Accelerate

extension CaptureSession {

    internal func processSamples(_ samples: [Float]) {
        // Actor-isolated processing
        let rms = samples.reduce(0.0) { $0 + $1 * $1 } / Float(samples.count)
        audioLevel = 20 * log10(sqrt(rms))
    }

    func performFFT(data: [Float]) async -> [Float] {
        // Check the configuration
        guard let setup = fftSetup else {
            return [Float](repeating: 0, count: .sampleAmount)
        }

        // 1. Copy of the audio samples as float
        var realIn = data
        // 2. The imaginary part
        var imagIn = [Float](repeating: 0, count: bufferSize)
        // 3. The transformed values of the real data
        var realOut = [Float](repeating: 0, count: bufferSize)
        // The transformed values of the imaginary data
        var imagOut = [Float](repeating: 0, count: bufferSize)
        // Property storing computed magnitudes
        var magnitudes = [Float](repeating: 0, count: .sampleAmount)
        // 1. Nested loops to safely access all data
        realIn.withUnsafeMutableBufferPointer { realInPtr in
            imagIn.withUnsafeMutableBufferPointer { imagInPtr in
                realOut.withUnsafeMutableBufferPointer { realOutPtr in
                    imagOut.withUnsafeMutableBufferPointer { imagOutPtr in
                        // 2. Execute the Discrete Fourier Transform (DFT)
                        vDSP_DFT_Execute(setup, realInPtr.baseAddress!, imagInPtr.baseAddress!, realOutPtr.baseAddress!, imagOutPtr.baseAddress!)
                        // 3. Hold the DFT output
                        var complex = DSPSplitComplex(realp: realOutPtr.baseAddress!, imagp: imagOutPtr.baseAddress!)
                        // 4. Compute and save the magnitude of each frequency component
                        vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(bitPattern: .sampleAmount))
                    }
                }
            }
        }
        let _magnitudes = magnitudes.map { min($0, .magnitudeLimit) }
        return _magnitudes
    }

}
