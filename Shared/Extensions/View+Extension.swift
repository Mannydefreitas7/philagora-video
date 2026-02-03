//
//  View+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-03.
//

import SwiftUI

extension View {

    //
    func store<T: Store>(with store: T) -> some View {
        switch store {
            case .main:
                modifier(StoreModifier())
            case .cature:
            default:
                EmptyView()
        }
    }

    func windowStyle() -> some View {

    }
}
