//
//  View+Modifier.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-03.
//
import SwiftUI


// Store modifier
struct StoreModifier: ViewModifier {

    @State private var mainStore: MainStore = MainStore.shared

    func body(content: Content) -> some View {
        content
            .environmentObject(mainStore)
    }
}
