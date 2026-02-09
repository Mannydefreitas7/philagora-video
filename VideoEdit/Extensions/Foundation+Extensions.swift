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


enum ToolGroup: String, Hashable, Sendable {
    case all
    case record
    case video
    case audio
    case options
    case timer
    case settings
}
