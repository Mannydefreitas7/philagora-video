//
//  SettingsButton.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-13.
//

import SwiftUI

struct SettingsButton: View {

    var systemImage: String?
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label("Settings", systemImage: systemImage ?? "gearshape")
                .font(.title2)
                .labelStyle(.iconOnly)
        }
        .toggleStyle(.button)
        .buttonBorderShape(.circle)
        .buttonStyle(.glassToolBar)
    }
}

#Preview {
    SettingsButton(isOn: .constant(false))
}
