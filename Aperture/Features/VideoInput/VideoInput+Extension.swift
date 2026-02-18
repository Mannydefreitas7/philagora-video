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
                viewModel.showSettings = false
            }
        } label: {
            Image(systemSymbol: .xmark)
                .colorScheme(viewModel.isRunning ? .dark : .light)
                .imageScale(.small)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)

    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $viewModel.selectedDevice.isOn) {
                Image(systemSymbol: .video)
                    .symbolVariant(viewModel.selectedDevice.isOn ? .none : .slash)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: viewModel.selectedDevice.isOn)

            if viewModel.selectedDevice.isOn {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.showSettings.toggle()
                    }
                } label: {
                    Text(viewModel.selectedDevice.name)
                }
                .buttonStyle(.accessoryBar)

                if viewModel.showSettings {

                    Spacer()

                    Button {
                        //
                    } label: {
                        Image(systemSymbol: .gearshape)
                    }
                    .buttonBorderShape(.circle)
                }
            }
        }
        .frame(maxWidth: viewModel.showSettings ? .previewVideoWidth : nil)
    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        ZStack(alignment: .bottom) {

            CapturePlaceholder(
                isConnecting: $viewModel.isConnecting,
                hasConnectionTimeout: $viewModel.hasConnectionTimeout,
                currentDevice: viewModel.selectedDevice
            )

            DeviceConnectionLoading(viewModel.selectedDevice)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.isRunning {
                VideoPreview(viewModel: $viewModel)
                        .clipShape(.rect(cornerRadius: .large, style: .continuous))
            }

            HStack {

                Picker(viewModel.selectedDevice.name, selection: $viewModel.deviceId) {
                        ForEach(videoDevices, id: \.id) { device in
                            HStack(spacing: .medium) {
                                Image(systemSymbol: device.symbol)
                                Text(device.name)
                            }
                            .tag(device.id)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .controlSize(.extraLarge)
                    .glassEffect()

                    Spacer()

            }
            .padding(.small)

            VStack {
                ToolCloseButton()
            }
            .padding(.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(width: .previewVideoWidth, height: .popoverWidth)
    }
}
