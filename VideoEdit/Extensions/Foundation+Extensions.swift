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

extension CGSize {
    var aspectRatio: CGFloat {
        width.isZero ? 1.0 : CGFloat(height) / CGFloat(width)
    }


    var windowSize: Self {
        guard let window = NSApplication.shared.keyWindow else {
            return .zero
        }
        return window.frame.size
    }

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

    enum Spacing: Int {

        case oneOfTwelve = 1
        case twoOfTwelve = 2
        case threeOfTwelve = 3
        case fourOfTwelve = 4
        case fiveOfTwelve = 5
        case sixOfTwelve = 6
        case sevenOfTwelve = 7
        case eightOfTwelve = 8
        case nineOfTwelve = 9
        case tenOfTwelve = 10
        case elevenOfTwelve = 11
        case twelveOfTwelve = 12
    }


}

// MARK: - CGFloat

extension CGFloat {
    var isEven: Bool { truncatingRemainder(dividingBy: 2) == 0 }

    static var recordWidth: Self { 28 }
    static var recordHeight: Self { 28 }
    static var popoverWidth: Self { 248 }
    static var thumbnail: Self { 128 }
    static var pillWidth: Self { 12 }
    static var pillHeight: Self { 18 }
    static var spacing: Self { 6 }

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

}

