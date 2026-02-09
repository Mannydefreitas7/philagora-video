//
//  String+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import Foundation
import AppKit

extension String {

    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        // Use String(format:) for leading zeros
        return String(format: "%d:%02d", minutes, remainingSeconds)
        // For HH:MM:SS format you would need more logic
    }

    static let notAvailable: Self  = "Not available"
    static let notAvailbleDescription: Self = "Select a device from the menu below."

    var applicationName: Self {
        return Bundle.appName
    }

        typealias RawValue = Self

        static var uuid: Self {
            UUID().uuidString
        }

        enum DispatchQueueKey: String {
            case windowCoordinator = "io.philagora.windowcoordinator.queue"
            case captureSession = "io.philagora.captureSession.queue"
            case captureVideoOutput = "io.philagora.captureVideoOutput.queue"
            case captureAudioOutput = "io.philagora.captureAudioOutput.queue"
            case metadataOutput = "io.philagora.metadataOutput.queue"
            case audioLevel = "io.philagora.audio-level.queue"
            case videoExport = "io.philagora.videoExport.queue"
        }

            /// Returns the raw string identifier for a given application window.
            ///
            /// Use this helper to obtain the string value associated with a specific
            /// window identifier defined in `Constants.Window`. This is useful when
            /// interacting with APIs that expect a string-based window identifier,
            /// such as SwiftUI's `.window(id:)`, AppKit window lookups, or persistence
            /// keys.
            ///
            /// - Parameter id: A case of `Constants.Window` representing a specific window in the app.
            /// - Returns: The `String` raw value associated with the provided window identifier.
            ///
            /// - Note: Ensure that `Constants.Window` is a `RawRepresentable` (typically an `enum`)
            ///         with `String` raw values so that each window case maps to a unique identifier.
        static func window(_ id: Constants.Window) -> Self {
            return id.rawValue
        }

        static func storageKey(_ id: Constants.StorageKey) -> Self {
            return id.rawValue
        }

        static func userDefaultsKey(_ id: Constants.StorageKey) -> Self {
            return id.rawValue
        }

        static func dispatchQueueKey(_ id: DispatchQueueKey) -> Self {
            return id.rawValue
        }

        static func controlGroup(_ id: ToolGroup) -> some Hashable {
            return id.rawValue
        }

        static let selectedAudioVolume: Self = "selected_audio_volume"
        static let unknown: Self = "unknown"


}
