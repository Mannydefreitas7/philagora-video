//
//  Constants.swift
//  Claquette
//
//  Created by Emmanuel on 2026-01-01.
//
import SwiftUI

class Constants {

    enum Window: CaseIterable, RawRepresentable, Hashable {
        init?(rawValue: String) {
            switch rawValue {
                case "main": self = .main
                case "settings": self = .settings
                case "welcome": self = .welcome
                case "recording": self = .recording
                default: return nil
            }
        }


        var rawValue: Self.RawValue {
            switch self {
                case .main: return "main"
                case .settings: return "settings"
                case .welcome: return "welcome"
                case .recording: return "recording"
            }
        }

        case main
        case settings
        case welcome
        case recording
    }

    enum SceneID: String, CaseIterable, Hashable {
        case welcome
        case about
        case editor
        case settings
    }

    struct Assets {
        static let appIcon = NSApplication.shared.applicationIconImage.suggestedFilename ?? "AppIcon"
    }

    static let cameraToolbarID = "camera-toolbar"
    static let guideToggleID = "guide-toggle"
    static let mirrorToggleID = "mirror-toggle"
    static let maskToggleID = "mask-toggle"
    static let aspectRatioPickerID = "aspect-ratio-picker2"

    static let showGuidesTitle = "Show Guides"
    static let showGuidesHelp = "Show/hide the Guides for the current selected platform"

    static let showMaskTitle = "Show Mask"
    static let showMaskHelp = "Show/hide the mask for the current aspect ratio"

    static let ratioMenuTitle = "Ratio"
    static let ratioMenuHelp = "Change the aspect ratio"

    static let mirrorTitle = "Mirror video"
    static let mirrorHelp = "Mirror the video horizontally"

    static let screenshareMode = "Screenshare"
    static let cameraMode = "Camera"

    static let youtubePreset = "YouTube"
    static let tiktokPreset = "TikTok"
    static let instagramPreset = "Instagram"

    enum StorageKey: String {
        case aspectPreset = "aspect_preset"
        case showAspectMask = "show_aspect_mask"
        case showSafeGuides = "show_safe_guides"
        case showPlatformGuides = "show_platform_safe"
        case isMirrored = "is_mirrored"
        case audioVolume = "audio_volume"
        case selectedAudioID = "selected_audio_id"
        case selectedVideoID = "selected_video_id"
        case selectedSecondaryVideoID = "selected_secondary_video_id"
    }

    static let screen_capture_security_key: String = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

    

}
