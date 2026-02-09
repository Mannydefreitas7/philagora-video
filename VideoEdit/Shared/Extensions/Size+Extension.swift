//
//  Size+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-08.
//
import Foundation
import SwiftUI
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
