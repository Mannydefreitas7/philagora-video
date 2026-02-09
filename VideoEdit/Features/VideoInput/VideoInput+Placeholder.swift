//
//  VideoInput+Placeholder.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-08.
//

import SwiftUI

struct VideoInputPlaceholder: View {
    var body: some View {
        ContentUnavailableView {
            Image(systemSymbol: .videoSlashCircle)
                .imageScale(.large)
        }
        .padding(.bottom, .extraLarge)
        .transition(.movingParts.wipe(
            angle: .degrees(-45),
            blurRadius: 50
        ))
    }
}
