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
            Image("video-placeholder")
                .renderingMode(.template)
                .tint(.black)
                .opacity(0.4)
                .imageScale(.large)
        }
        .transition(.movingParts.wipe(
            angle: .degrees(-45),
            blurRadius: 50
        ))
    }
}

#Preview {
    VideoInputPlaceholder()
}
