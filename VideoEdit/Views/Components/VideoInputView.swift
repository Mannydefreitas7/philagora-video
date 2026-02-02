//
//  AudioInputView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-10.
//

import SwiftUI
import SFSafeSymbols
import AVFoundation
import AVKit

struct VideoInputView: View {

    var controlGroup: Namespace.ID
    @Binding var device: AVDeviceInfo

    @EnvironmentObject var viewModel: CaptureView.State

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
                    .frame(height: .popoverWidth)
            } else {
                ToolButton()
                    .frame(height: .minHeight)
            }
        }
        .padding(.horizontal, .small)
        .glassEffect(.regular, in: device.shape)
        .toolEffectUnion(
            id: device.isOn ? .video : .options,
            namespace: controlGroup
        )
    }
}

extension VideoInputView {

    var imageWidth: CGFloat { .thumbnail / 2.5 }

    @ViewBuilder
    func ToolCloseButton() -> some View {
        Button {
            withAnimation(.bouncy) {
                device.showSettings.toggle()
            }
        } label: {
            Image(systemSymbol: .xmark)
        }
        .buttonStyle(.accessoryBarAction)
        .buttonBorderShape(.circle)
    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $device.isOn) {
                Image(systemSymbol: device.isOn ? .videoFill : .videoSlashFill)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: device.isOn)

            if device.isOn {
                Button {
                    withAnimation(.bouncy) {
                        device.showSettings.toggle()
                        if viewModel.controlsBarViewModel.microphone.showSettings {
                            viewModel.controlsBarViewModel.microphone.showSettings = false
                        }
                    }
                } label: {
                    Text(device.device?.localizedName)
                }
                .buttonStyle(.accessoryBar)
            }
        }

    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        VStack(alignment: .leading) {
                HStack {

                    Image(.imac)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth)

                    VStack(alignment: .leading) {
                        Text("Device")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(device.name.capitalized)
                            .font(.headline)
                            .bold()
                    }
                }

            VideoOutputView(
                source: viewModel.engine.previewSource,
                captureSession: viewModel.engine.captureSession
            )
                    .clipShape(.rect(cornerRadius: .medium, style: .circular))
            }
            .frame(width: .popoverWidth)
            .overlay(alignment: .topTrailing) {
                ToolCloseButton()
                    .offset(x: .small)
            }
            .padding(.medium)
            .frame(minHeight: .zero)
    }
}
