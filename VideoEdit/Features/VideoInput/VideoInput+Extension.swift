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
        }
        .buttonStyle(.accessoryBarAction)
        .buttonBorderShape(.circle)
    }

    @ViewBuilder
    func ToolButton() -> some View {
        HStack(spacing: .small / 2) {
            Toggle(isOn: $viewModel.selectedDevice.isOn) {
                Image(systemSymbol: viewModel.selectedDevice.isOn ? .videoFill : .videoSlashFill)
                    .contentTransition(.symbolEffect(.replace))
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: viewModel.selectedDevice.isOn)

            if viewModel.selectedDevice.isOn {
                Button {
                    withAnimation(.bouncy) {
                        viewModel.showSettings = true
                    }
                } label: {
                    Text(viewModel.deviceName)
                }
                .buttonStyle(.accessoryBar)
            }
        }

    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
        ZStack(alignment: .bottom) {

            Placeholder()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if viewModel.session.isRunning {
                VideoPreview(session: viewModel.session, isMirrored: $isMirrored)
            }
            GlassEffectContainer(spacing: 20.0) {
                HStack {
                        //
                    Image(.imac)
                        .resizable()
                        .scaledToFit()
                        .frame(width: .recordWidth)
                        //
                    VStack(alignment: .leading) {
                        Text("Device")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(viewModel.deviceName.capitalized)
                            .font(.headline)
                            .bold()
                    }
                        //
                    Spacer()
                        //
                    ToolCloseButton()
                }
                .padding(.medium)
                .glassEffect(.clear, in: .rect(cornerRadius: .large, style: .circular))

            }
            .padding(.medium)
            .padding(.leading, .small)
        }
        .frame(width: .popoverWidth * 1.2, height: .popoverWidth)

    }

    @ViewBuilder
    func Placeholder() -> some View {
        ContentUnavailableView {
            Image(systemSymbol: .videoSlashCircle)
                .imageScale(.large)
        }
        .padding(.top, .extraLarge)
    }
}
