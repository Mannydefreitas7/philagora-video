import Foundation
import SwiftUI
import AppKit

// MARK: - Double Extensions
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Date Extensions
extension Date {
    var formattedRecordingName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return "Recording \(formatter.string(from: self))"
    }
}

// MARK: - CGSize
extension CGSize {
    var aspectRatio: CGFloat {
        width.isZero ? 1.0 : CGFloat(height) / CGFloat(width)
    }

    /// Current window size
    var windowSize: Self {
        guard let window = NSApplication.shared.keyWindow else {
            return .zero
        }
        return window.frame.size
    }

    /// Minimum window recording size - (width: ``

    /// Record circle shape height, inherit record width - value: `self.recordWidth`
    static var recordCircle: Self { .init(width: .recordWidth, height: .recordHeight) }
    /// PillWidth size - width:`12` / height: `18`
    static var pill: Self { .init(width: 12, height: 18) }

    static var systemSize: SystemSize {
        return SystemSize()
    }

    struct SystemSize {
        let recordButton: CGSize = .init(width: .recordWidth, height: .recordHeight)
    }

}

// MARK: - Int
extension Double {

    static var columnWidth: Double {
        let gridColumns: Double = 12
        return Double(CGFloat.windowWidth) / gridColumns
    }

    /// Grid spacing helper representing a number of 12-column grid units.
    /// Use with layout helpers like `CGFloat.columnWidth(spacing:)` to get widths
    /// that span a given number of columns based on the current window width.
    enum Spacing: Int {
        /// Spans 1 of 12 grid columns
        case oneOfTwelve = 1
        /// Spans 2 of 12 grid columns
        case twoOfTwelve = 2
        /// Spans 3 of 12 grid columns
        case threeOfTwelve = 3
        /// Spans 4 of 12 grid columns
        case fourOfTwelve = 4
        /// Spans 5 of 12 grid columns
        case fiveOfTwelve = 5
        /// Spans 6 of 12 grid columns
        case sixOfTwelve = 6
        /// Spans 7 of 12 grid columns
        case sevenOfTwelve = 7
        /// Spans 8 of 12 grid columns
        case eightOfTwelve = 8
        /// Spans 9 of 12 grid columns
        case nineOfTwelve = 9
        /// Spans 10 of 12 grid columns
        case tenOfTwelve = 10
        /// Spans 11 of 12 grid columns
        case elevenOfTwelve = 11
        /// Spans 12 of 12 grid columns (full width)
        case twelveOfTwelve = 12
    }

    /// Window minimum width: `1600 / 1.5`
    static var minWindowWidth: Self { 1600 / 1.5 }
    /// Window minimum height: `900 / 1.5`
    static var minWindowHeight: Self { 900 / 1.5 }
    /// Window default recording width: `1600`
    static var defaultRecordWidth: Self { 1600 }
    /// Window default recording height: `900`
    static var defaultRecordHeight: Self { 900 }
}

// MARK: - Int

extension Int {

    /// Sample amount for audio wave: `300`
    static var sampleAmount: Self { 300 }
    /// Down sample factor: `16`
    static var downsampleFactor: Self { 16 }


}

extension Float {
    /// Magnitude limit: `50`
    static var magnitudeLimit: Self { 50 }
}

// MARK: - CGFloat
extension CGFloat {
    var isEven: Bool { truncatingRemainder(dividingBy: 2) == 0 }

    /// Small size - value: `8`
    static var small: Self { 8 }
    /// Medium size - value: `16`
    static var medium: Self { 16 }
    /// Large size - value: `24`
    static var large: Self { 24 }
    /// Extra Large size - value: `32`
    static var extraLarge: Self { 32 }
    /// Minium Height for toolbar height - value: `48`
    static var minHeight: Self { 48 }
    /// Record circle shape width - value: `28`
    static var recordWidth: Self { 28 }
    /// Record circle shape height, inherit record width - value: `self.recordWidth`
    static var recordHeight: Self { 28 }
    /// Popeper Width - value: `280`
    static var popoverWidth: Self { 280 }
    /// Thumbnail size - value: `188`
    static var thumbnail: Self { 128 }
    /// Spacing size - value: `6`
    static var spacing: Self { 6 }

    /// Window minimum width: `1600 / 1.5`
    static var minWindowWidth: Self { 1600 / 1.5 }
    /// Window minimum height: `900 / 1.5`
    static var minWindowHeight: Self { 900 / 1.5 }
    /// Window default recording width: `1600`
    static var defaultRecordWidth: Self { 1600 }
    /// Window default recording height: `900`
    static var defaultRecordHeight: Self { 900 }

    // c. Handle high spikes distortion in the chart


    /// Corners radius - value: `32`
    static var cornerRadius: Self { 32 }
    /// Border width - value: `1`
    static var borderWidth: Self { 1 }

    /// Top padding - value: `54`
    static var topPadding: Self { 54 }
    /// Bottom padding radius - value: `64`
    static var bottomPadding: Self { 64 }
    /// Dimming alpha - value: `0.5`
    static var dimmingAlpha: Self { 0.5 }

    static func columnWidth(spacing: Double.Spacing) -> CGFloat {
        let totalColumns: CGFloat = 12
        let columnWidth = CGFloat.windowWidth / totalColumns
        return columnWidth * CGFloat(spacing.rawValue)
    }

    static var windowWidth: Self {
        guard let window = NSApplication.shared.keyWindow else {
            return .zero
        }
        return window.frame.width
    }
}

// MARK: - URL
extension URL {
    /// A unique output location to write a movie.
    static var movieFileURL: URL {
        URL.temporaryDirectory.appending(component: UUID().uuidString).appendingPathExtension(for: .quickTimeMovie)
    }
}

// MARK: - CGRect
extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    func normalized() -> CGRect {
        CGRect(
            x: origin.x / size.width,
            y: origin.y / size.height,
            width: size.width / size.width,
            height: size.height / size.height
        )
    }

    func denormalized(to size: CGSize) -> CGRect {
        CGRect(
            x: origin.x * size.width,
            y: origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}

// MARK: - Task Extensions
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    static func performWithoutThrowing(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    static func loop(condition: @autoclosure () -> Bool, _ body: @escaping () async throws -> Void) async throws {
        while condition() {
            try await body()
        }
    }

    static func loop<T: FloatingPoint>(condition: @autoclosure () -> Bool, _ body: @escaping (T) async throws -> Void, initialValue: T) async throws {
        while condition() {
            try await body(initialValue.advanced(by: 1))
        }
    }

    static func perform(after delay: TimeInterval, _ body: @escaping () async throws -> Void) async throws {
        try await Task.sleep(seconds: delay)
        try await body()
    }

    static func perform(after delay: TimeInterval, _ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let recordingDidStart = Notification.Name("recordingDidStart")
    static let recordingDidStop = Notification.Name("recordingDidStop")
    static let recordingDidPause = Notification.Name("recordingDidPause")
    static let recordingDidResume = Notification.Name("recordingDidResume")
    static let exportDidStart = Notification.Name("exportDidStart")
    static let exportDidFinish = Notification.Name("exportDidFinish")
    static let exportDidFail = Notification.Name("exportDidFail")
}

extension URL {
    var isVideo: Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "webm", "wmv", "flv"]
        return videoExtensions.contains(pathExtension.lowercased())
    }

    var isGIF: Bool {
        pathExtension.lowercased() == "gif"
    }

    var isImage: Bool {
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "heic"]
        return imageExtensions.contains(pathExtension.lowercased())
    }

    var fileSize: Int64? {
        guard let resources = try? resourceValues(forKeys: [.fileSizeKey]) else { return nil }
        return Int64(resources.fileSize ?? 0)
    }

    var formattedFileSize: String {
        guard let size = fileSize else { return "Unknown" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

extension NSObject: NamePrintable {}

extension String {
    typealias RawValue = Self

    static var uuid: Self {
        UUID().uuidString
    }

    enum DispatchQueueKey: String {
        case windowCoordinator = "io.philagora.windowcoordinator.queue"
        case captureSession = "io.philagora.captureSession.queue"
        case captureVideoOutput = "io.philagora.captureVideoOutput.queue"
        case captureAudioOutput = "io.philagora.captureAudioOutput.queue"
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

enum ToolGroup: String, Hashable, Sendable {
    case all
    case record
    case video
    case audio
    case options
    case timer
    case settings
}
