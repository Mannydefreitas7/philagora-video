//
//  AudioInputProxy.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-23.
//

import SwiftUI
import AVFoundation

/// A SwiftUI view proxy that injects live audio input monitoring values into the view
/// hierarchy via environment values.
///
/// AudioInputProxy wraps arbitrary content and manages an internal audio monitor,
/// exposing:
/// - The current input level as a normalized "wave" value through the `audioInputWave`
///   environment key.
/// - A rolling history of recent levels through the `audioInputWaveHistory`
///   environment key.
///
/// It starts monitoring when the view appears (via `.task`) and stops when the view
/// disappears, ensuring resources are managed appropriately.
struct AudioInputProxy<Content: View>: View {


    /// Behavior:
    /// - Creates an `AVCaptureAudioMonitor` with the provided tuning parameters and binds it
    ///   to an internal `CaptureState`.
    /// - Injects `viewModel.level` into the environment as `audioInputWave`.
    /// - Injects `viewModel.history` into the environment as `audioInputWaveHistory`.
    /// - Starts monitoring in a task when the view appears, and stops on disappearance.
    ///
    /// Usage:
    /// Embed your UI that needs audio-reactive visuals inside the proxy. Downstream views
    /// can read `Environment(\.audioInputWave)` and `Environment(\.audioInputWaveHistory)`
    /// to drive meters or waveforms.
    ///
    /// Example:
    ///     AudioInputProxy(viewModel: captureViewModel) {
    ///         AudioMeterView() // reads audioInputWave and/or audioInputWaveHistory
    ///     }
    ///
    /// Threading:
    /// - Monitoring starts asynchronously; consumers should be resilient to initial
    ///   placeholder values until the stream becomes active.

    /// Internal `ViewModel` state to be initialized accordingly with the actor binding.
   // @ObservedObject var viewModel: CaptureView.ViewModel

    /// Generic Parameters:
    /// - Content: The SwiftUI `View` type being wrapped.
    @ViewBuilder
    var content: Content

    var body: some View {
        content
         //   .environment(\.audioInputWave, viewModel.audioLevel)
           // .environment(\.audioInputWaveHistory, viewModel.audioHistory)
        }
}
