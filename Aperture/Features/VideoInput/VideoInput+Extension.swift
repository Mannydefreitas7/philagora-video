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
                viewModel.videoInputViewModel.showSettings = false
            }
        } label: {
            Image(systemSymbol: .xmark)
                .colorScheme(viewModel.videoInputViewModel.isRunning ? .dark : .light)
                .imageScale(.small)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)

    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $viewModel.camera.isOn) {
                Image(systemSymbol: .video)
                    .symbolVariant(viewModel.camera.isOn ? .none : .slash)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: viewModel.camera.isOn)

            if viewModel.camera.isOn {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.videoInputViewModel.showSettings.toggle()
                    }
                } label: {
                    Text(viewModel.camera.name)
                }
                .buttonStyle(.accessoryBar)

                if viewModel.videoInputViewModel.showSettings {

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
        .frame(maxWidth: viewModel.videoInputViewModel.showSettings ? .previewVideoWidth : nil)
    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        ZStack(alignment: .bottom) {

            CapturePlaceholder(
                isConnecting: $viewModel.videoInputViewModel.isConnecting,
                hasConnectionTimeout: $viewModel.videoInputViewModel.hasConnectionTimeout,
                currentDevice: viewModel.videoInputViewModel.currentDevice
            )

            DeviceConnectionLoading(viewModel.videoInputViewModel.currentDevice)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.videoInputViewModel.isRunning {
                VideoPreview(viewModel: $viewModel.videoInputViewModel)
                        .clipShape(.rect(cornerRadius: .large, style: .continuous))
            }

            HStack {

                Picker(viewModel.videoInputViewModel.deviceName, selection: $viewModel.videoInputViewModel.selectedID) {
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
            .onChange(of: viewModel.videoInputViewModel.selectedID) { oldValue, newValue in
                Task {
                    if oldValue != newValue {
                        await viewModel.videoInputViewModel.onChangeDevice(id: newValue)
                    }
                }
            }

            VStack {
                ToolCloseButton()
            }
            .padding(.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .frame(width: .previewVideoWidth, height: .popoverWidth)
    }
}
