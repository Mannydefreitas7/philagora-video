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

// MARK: - CGFloat

extension CGFloat {
    var isEven: Bool { truncatingRemainder(dividingBy: 2) == 0 }

    static var recordWidth: Self { 32 }
    static var recordHeight: Self { 32 }


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
