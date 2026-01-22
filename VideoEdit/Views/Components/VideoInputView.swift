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
    @Binding var device: DeviceInfo
    @EnvironmentObject var appState: AppState
    @AppStorage(.storageKey(.isMirrored)) private var isMirrored: Bool = false

    var body: some View {
        Group {
            if device.showSettings {
                ToolBarOptions()
            } else {
                ToolButton()
            }
        }
        .padding(.horizontal, .small)
        .frame(height: device.showSettings ? .popoverWidth :  .minHeight)
        .glassEffect(.regular, in: device.shape)
        .toolEffectUnion(
            id: device.isOn ? .video : .options,
            namespace: controlGroup
        )
        .onDisappear {
            appState.previewViewModel.onDisappear()
        }
        .task {
            await appState.previewViewModel.onAppear()
        }
    }
}

extension VideoInputView {

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
                Image(systemSymbol: .webCamera)
                    .font(.title2)
                    .frame(width: .recordWidth)
            }
            .toggleStyle(.secondary)
            .animation(.bouncy, value: device.isOn)

            if device.isOn {
                Button {
                    withAnimation(.bouncy) {
                        device.showSettings.toggle()
                    }
                } label: {
                    Text(device.name)
                }
                .buttonStyle(.accessoryBar)
            }
        }

    }

    @ViewBuilder
    func ToolBarOptions() -> some View {
            VStack {
                Text(device.name)
                VideoOutputView(captureSession: appState.previewViewModel.session, isMirror: $isMirrored)
                    .clipShape(.rect(cornerRadius: .medium, style: .circular))
            }
            .frame(width: .popoverWidth)
            .overlay(alignment: .topTrailing) {
                ToolCloseButton()
                    .offset(x: .medium, y: -(.small))
            }
            .padding(.large)
    }

    enum UIString: String {
        case label = "S3 Camera HD"
        case icon = "web.camera"
    }
}

class PreviewView: NSView, PreviewTarget {

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Use `AVCaptureVideoPreviewLayer` as the view's backing layer.
    class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    nonisolated func setSession(_ session: AVCaptureSession) {
        // Connects the session with the preview layer, which allows the layer
        // to provide a live view of the captured content.
        Task { @MainActor in
            previewLayer.session = session
        }
    }
}

struct CameraPreview: NSViewRepresentable {

    private let source: PreviewSource

    init(source: PreviewSource) {
        self.source = source
    }

    func makeNSView(context: Context) -> PreviewView {
        let preview = PreviewView()
        // Connect the preview layer to the capture session.
        source.connect(to: preview)
        return preview
    }

    func updateNSView(_ previewView: PreviewView, context: Context) {
        // No implementation needed.
    }
}

