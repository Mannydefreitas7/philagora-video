//
//  MultiCamLayout+Model.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-09.
//

import Foundation

enum MultiCamLayout: String, CaseIterable, Identifiable {
    case pictureInPicture
    case sideBySide
    case stacked

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pictureInPicture:
            return "PIP"
        case .sideBySide:
            return "Side by Side"
        case .stacked:
            return "Stacked"
        }
    }
}
