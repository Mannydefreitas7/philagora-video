//
//  String+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-04.
//

import Foundation

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
}
