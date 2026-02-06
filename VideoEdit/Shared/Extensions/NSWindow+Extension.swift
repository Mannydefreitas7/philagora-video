//
//  NSWindow+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-05.
//
import AppKit

extension NSWindow.StyleMask {
        /// A common "standard" window mask for document-style windows.
    static let standardDocumentWindow: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable,
        .resizable
    ]

        /// A common "utility" window mask (no resize by default).
    static let standardUtilityWindow: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable
    ]

        /// Titled + closable + miniaturizable, but not resizable.
    static let titledNonResizable: NSWindow.StyleMask = [
        .titled,
        .closable,
        .miniaturizable
    ]
}
