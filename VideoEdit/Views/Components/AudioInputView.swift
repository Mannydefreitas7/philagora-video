//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols
import AppState

struct AudioInputView: View {

    var controlGroup: Namespace.ID
    @Binding var device: AVDevice
    @Environment(\.isRecording) var isRecording
    @EnvironmentObject var viewModel: RecordingToolbar.ViewModel

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
                    .frame(minHeight: nil, alignment: .center)
            } else {
                ToolbarButton()
                    .frame(minHeight: .minHeight, alignment: .center)
            }
        }
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
            Button(.closeButton, systemSymbol: .xmark, role: .close) {
                withAnimation(.bouncy) {
                    device.showSettings.toggle()
                }
            }
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
            .fontWeight(.bold)
        }
        .padding(.large)
    }

    @ViewBuilder
    func ToolbarButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $device.isOn) {
                Image(systemSymbol: device.isOn ? .microphoneFill : .microphoneSlashFill)
                    .contentTransition(.symbolEffect(.replace.wholeSymbol))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: device.isOn)
            .onChange(of: device.isOn) {
                Task {
                    //await captureState.muteDevice(device)
                }
            }

            if device.isOn {
                Button {
                    withAnimation(.bouncy) {
                        device.showSettings.toggle()
                    }
                } label: {
                    Text(device.name)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.accessoryBar)

                if isRecording == .audio || (isRecording == .audio && isRecording == .video) {
                    AudioWaveMonitor(style: .indicator, isActive: $device.isOn)
                }
            }
        }
        .padding(.horizontal, .small)
    }
}
