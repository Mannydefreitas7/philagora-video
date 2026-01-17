//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI

struct VideoInputView: View {

    var action: () -> Void = { }

    @State private var isPresented: Bool = false
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Label(UIString.label.rawValue, systemImage: UIString.icon.rawValue)
                .font(.title2)
        }
        
        .buttonStyle(.glassToolBar)
        .popover(isPresented: $isPresented) {
            Text("Content")
                .padding()
        }
    }
}

extension VideoInputView {
    enum UIString: String {
        case label = "S3 Camera HD"
        case icon = "web.camera"
    }
}

#Preview {
    VideoInputView()
}
