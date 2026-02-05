//
//  View+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-03.
//

import SwiftUI
//import Engine

extension View {

    //
    func store(with store: Store) -> some View {
        switch store {
            case .main:
                modifier(StoreModifier())
            default:
                modifier(StoreModifier())
        }
    }
}
