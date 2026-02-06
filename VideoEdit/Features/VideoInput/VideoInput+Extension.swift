//
//  VideoInput+Extension.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-02-06.
//
import SwiftUI

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
                        if viewModel.microphone.showSettings {
                            viewModel.microphone.showSettings = false
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

            if viewModel.videoInputViewModel.hasVideo {
                VideoInputPreview(viewModel: $viewModel.videoInputViewModel)
                    .clipShape(.rect(cornerRadius: .medium, style: .circular))
            } else {
                Placeholder()
            }
        }
        .overlay(alignment: .topTrailing) {
            ToolCloseButton()
                .offset(x: .small)
        }
        .frame(minHeight: .zero)
        .frame(width: .popoverWidth)
        .padding(.medium)
        .task {
            await viewModel.videoInputViewModel.start()
        }
    }

    @ViewBuilder
    func Placeholder() -> some View {
        ContentUnavailableView(.notAvailableTitle, systemSymbol: .videoSlashCircle, description: .init(verbatim: .notAvailbleDescription))
    }
}
