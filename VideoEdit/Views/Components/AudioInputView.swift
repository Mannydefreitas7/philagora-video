//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols

struct AudioInputView: View {

    var controlGroup: Namespace.ID
    @Binding var device: DeviceInfo

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
            } else {
                ToolbarButton(device.isOn)
            }
        }
        .frame(
            height: device.showSettings ? nil : .minHeight,
            alignment: .center
        )
        .glassEffect(
            .regular,
            in: device.shape
        )
        .toolEffectUnion(
            id: device.isOn ? .audio : .options,
            namespace: controlGroup
        )
    }
}

extension AudioInputView {

    @ViewBuilder
    func ToolBarOptions() -> some View {
        VolumeHUD(for: $device) {
            Button("Close", systemImage: "xmark", role: .close) {
                withAnimation(.bouncy) {
                    device.showSettings.toggle()
                }
            }
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
        }
        .padding(.large)
    }

    @ViewBuilder
    func ToolbarButton(_ displayLabel: Bool) -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $device.isOn) {
                Image(systemSymbol: device.isOn ? .microphoneFill : .microphoneSlash)
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: device.isOn)


            if displayLabel {
                Button {
                    withAnimation(.bouncy) {
                        device.showSettings.toggle()
                    }
                } label: {
                    Text(device.name)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.accessoryBar)
            }
        }
        .padding(.horizontal, .small)
    }
}
