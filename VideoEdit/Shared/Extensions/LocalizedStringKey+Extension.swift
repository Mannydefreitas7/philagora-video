//
//  LocalizedStringKey+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import Foundation
import SwiftUI

extension LocalizedStringKey {

    static var notAvailableTitle: Self { .init("Not available") }
    static var notDevicesAvailableDescription: Self { .init("Select a device from the menu below.") }

    static var inputLabel: Self { .init("Inputs") }

    // Control
    static var pauseButton: Self { .init("Pause") }
    static var closeButton: Self { .init("Close") }
}
