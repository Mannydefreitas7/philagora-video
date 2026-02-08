//
//  AudioInput+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-07.
//
import SwiftUI

extension AudioInputView {

    @ViewBuilder
    func ToolBarOptions() -> some View {
        VolumeHUD(for: $viewModel.selectedDevice) {
            Button(.closeButton, systemSymbol: .xmark, role: .close) {
                withAnimation(.bouncy) {
                    viewModel.showSettings = false
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
            Toggle(isOn: $viewModel.selectedDevice.isOn) {
                Image(systemSymbol: viewModel.selectedDevice.isOn ? .microphoneFill : .microphoneSlashFill)
                    .contentTransition(.symbolEffect(.replace.wholeSymbol))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: viewModel.selectedDevice.isOn)
            .onChange(of: viewModel.selectedDevice.isOn) {
                Task {
                        //await captureState.muteDevice(device)
                }
            }

            if viewModel.selectedDevice.isOn {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.showSettings = true
                    }
                } label: {
                    Text(viewModel.selectedDevice.name)
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.accessoryBar)

                if isRecording == .audio || (isRecording == .audio && isRecording == .video) {
                    AudioWaveMonitor(style: .indicator, isActive: $viewModel.selectedDevice.isOn)
                }
            }
        }
        .padding(.horizontal, .small)
    }
}
