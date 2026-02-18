//
//  Capture+Placeholder.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-09.
//

import SwiftUI

struct CapturePlaceholder: View {

    @Binding var isConnecting: Bool
    @Binding var hasConnectionTimeout: Bool
    var currentDevice: AVDevice?

    var body: some View {

        VStack {
            if isConnecting && hasConnectionTimeout {
                    // If there is a connection timeout,
                    // display, the manual refresh button
                Text("Could not connect. Try again.")
                Button("Refresh") {
                        //
                }

            } else if isConnecting {
                    // If the device is connecting,
                    // display connection loader.
                DeviceConnectionLoading(currentDevice)

            } else {
                    // If the state is empty, with no session running
                    // and no timeout errors, then display placeholder
                PlaceholderView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
