//
//  Float+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-08.
//

import SwiftUI


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
        /// Preview Menu video Width - value: `512`
    static var previewVideoWidth: Self { 512 }
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
