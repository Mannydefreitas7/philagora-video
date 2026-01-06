//
//  VICameraCaptureView.swift
//  VideoEdit
//
//  Created by Emmanuel on 2026-01-04.
//

import SwiftUI
import AVFoundation
import AppKit
import Combine


struct VICameraCaptureView: View {

    @StateObject private var viewModel: ViewModel = .init()
    @AppStorage(Constants.aspectPresetStorageKey)
    private var aspectPreset: AspectPreset = .youtube
    @AppStorage(Constants.showAspectMaskStorageKey) private var showAspectMask: Bool = true
    @AppStorage(Constants.showSafeGuidesStorageKey) private var showSafeGuides: Bool = true
    @AppStorage(Constants.showPlatformSafeStorageKey) private var showPlatformSafe: Bool = true
    @AppStorage(Constants.mirrorToggleID) private var isMirrored: Bool = true

    @Namespace private var namespace

    var body: some View {

        ZStack(alignment: .bottom) {
            VideoOutputView(captureSession: $viewModel.session, isMirror: $isMirrored)
                .ignoresSafeArea(.all)

            AspectMaskOverlay(
                showGuides: showSafeGuides,
                showMask: showAspectMask,
                showPlatformSafe: showPlatformSafe
            )
            .animation(.easeInOut, value: aspectPreset)

            .allowsHitTesting(false)

                     bottomContent()
                    .frame(maxWidth: .windowWidth * 0.3)


        }
        // Keep the window resizable but constrained to 16:9.
        .background(WindowAspectRatioLock(ratio: CGSize(width: 16, height: 9)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            topTrailingControls()
        }


    }
}



extension VICameraCaptureView {

    @ViewBuilder
    func recordButton() -> some View {



            Button(role: .cancel) {
                //
            } label: {
                LabeledContent {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")

                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.recordingRed)
                } label: {
                    Text("Record")
                }


            }
            .keyboardShortcut("r", modifiers: [])
            .glassEffectID("togglebutton", in: namespace)
            .buttonStyle(.glass)


    }

    @ViewBuilder
    func timeLabel() -> some View {
        Text(viewModel.recordingTimeString)
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(viewModel.isRecording ? .red : .secondary)
    }

    var finderURL: some View {
        //        if let url = viewModel.lastSavedURL {
        HStack(spacing: 12) {
            if let thumb = viewModel.lastThumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
            }

            Text(
                //    url.path
                ""
            )
            .font(.callout)
            .lineLimit(1)
            .truncationMode(.middle)
            .foregroundStyle(.secondary)

            Spacer()

            Button("Show in Finder") {
                // viewModel.revealLastSavedInFinder()
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))

    }

    @ToolbarContentBuilder
    func topTrailingControls() -> some ToolbarContent {

        ToolbarItem(id: Constants.aspectRatioPickerID) {

            GlassEffectContainer(spacing: 12) {
                HStack {
                    Toggle(
                        Constants.showMaskTitle,
                        systemImage: "circle.rectangle.filled.pattern.diagonalline",
                        isOn: $showAspectMask
                    )
                    .help(Constants.showMaskHelp)
                    .toggleStyle(.button)
                    .buttonStyle(.glass)
                    // When the mask is ON, the glass "focus" sits on this button.
                    // When OFF, the glass "focus" animates over to the aspect-ratio menu.
                    .glassEffectID(showAspectMask ? "toolbar.glass.focus" : "toolbar.glass.secondary", in: namespace)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAspectMask)

                    Picker(Constants.ratioMenuTitle, systemImage: "aspectratio", selection: $aspectPreset) {
                        ForEach(AspectPreset.allCases) { preset in
                                Text(preset.rawValue)
                                    .tag(preset)
                        }
                    }
                    .pickerStyle(.inline)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAspectMask)
                }
            }
        }

        ToolbarItem {
            Toggle(
                Constants.mirrorTitle,
                systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right",
                isOn: $isMirrored
            )
            .help(Constants.mirrorHelp)
            .toggleStyle(.button)
            .buttonStyle(.glass)
        }


        ToolbarItem {
            Toggle(
                Constants.showGuidesTitle,
                systemImage: "viewfinder",
                isOn: $showSafeGuides
            )
            .help(Constants.showGuidesHelp)
            .toggleStyle(.button)
            .buttonStyle(.glass)
        }

        ToolbarItem {
            Toggle(
                Constants.showMaskTitle,
                systemImage: "circle.rectangle.filled.pattern.diagonalline",
                isOn: $showAspectMask
            )
            .help(Constants.showMaskHelp)
            .toggleStyle(.button)
            .buttonStyle(.glass)
            // When the mask is ON, the glass "focus" sits on this button.
            // When OFF, the glass "focus" animates over to the aspect-ratio menu.
            .glassEffectID(showAspectMask ? "toolbar.glass.focus" : "toolbar.glass.secondary", in: namespace)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showAspectMask)
        }
    }

    @ViewBuilder
    func bottomContent() -> some View {
        GlassEffectContainer {
            HStack(spacing: 12) {
                recordButton()
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 18)

            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, DesignToken.bottomPadding / 2)
    }
}


extension VICameraCaptureView {

    struct DesignToken {
        static let defaultCornerRadius: CGFloat = 12
        static let defaultBorderWidth: CGFloat = 1
        static let defaultBorderColor: NSColor = .secondaryLabelColor
        static let topPadding: CGFloat = 54
        static let bottomPadding: CGFloat = 64
        static let dimmingAlpha: CGFloat = 0.5

        static let maskColor: Color = .recordingRed.opacity(0.1)
        static let guideColor: Color = .white.opacity(0.5)
    }

    enum Mode: String, Hashable {
        case screenshare
        case camera
    }

    struct WindowAspectRatioLock: NSViewRepresentable {
        let ratio: CGSize

        final class Coordinator {
            weak var window: NSWindow?
        }

        func makeCoordinator() -> Coordinator { Coordinator() }

        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: .zero)
            DispatchQueue.main.async {
                guard let window = view.window else { return }
                context.coordinator.window = window
                window.contentAspectRatio = ratio
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {
            DispatchQueue.main.async {
                guard let window = nsView.window else { return }
                context.coordinator.window = window
                if window.contentAspectRatio != ratio {
                    window.contentAspectRatio = ratio
                }
            }
        }
    }


    enum AspectPreset: String, CaseIterable, Identifiable {
        /// Locks the hosting NSWindow to a fixed content aspect ratio while still allowing resize.

        case youtube
        case tiktok
        case instagram

        var id: String { rawValue }

        var ratio: CGSize {
            switch self {
                case .youtube:
                    // Standard YouTube landscape
                    return CGSize(width: 16, height: 9)
                case .tiktok:
                    // Vertical video
                    return CGSize(width: 9, height: 16)
                case .instagram:
                    // Feed-safe default (4:5)
                    return CGSize(width: 4, height: 5)
            }
        }

        /// Platform UI overlays to avoid (fractions of the target rect size).
        /// Values are approximate guides (not exact platform specs).
        var platformAvoidance: PlatformAvoidance? {
            switch self {
                case .tiktok:
                    // TikTok commonly has UI at the top and a heavier stack at the bottom.
                    return PlatformAvoidance(top: 0.12, bottom: 0.20, left: 0.0, right: 0.0)
                case .instagram:
                    // Instagram feed/reels overlays tend to be lighter than TikTok.
                    return PlatformAvoidance(top: 0.10, bottom: 0.14, left: 0.0, right: 0.0)
                default:
                    return nil
            }
        }

        struct PlatformAvoidance: Equatable {
            var top: CGFloat
            var bottom: CGFloat
            var left: CGFloat
            var right: CGFloat
        }
    }

    /// Visual overlay showing the selected aspect ratio as a centered mask.
    /// The window remains freely resizable; this is purely a guide.
    struct AspectMaskOverlay: View {
        @AppStorage(Constants.aspectPresetStorageKey)
        private var aspectPreset: AspectPreset = .youtube
        var showGuides: Bool = false
        var showMask: Bool = false
        var showPlatformSafe: Bool = true
        var topPadding: CGFloat = DesignToken.topPadding   // Approx expanded macOS title bar height
        var bottomPadding: CGFloat = DesignToken.bottomPadding
        var dimOpacity: CGFloat = DesignToken.dimmingAlpha
        var borderLineWidth: CGFloat = DesignToken.defaultBorderWidth
        var cornerRadius: CGFloat = DesignToken.defaultCornerRadius

        var body: some View {
            GeometryReader { geo in
                let container = geo.size
                let paddedContainer = CGSize(
                    width: container.width,
                    height: max(0, container.height - topPadding - bottomPadding)
                )

                let target = fittedSize(container: paddedContainer, ratio: aspectPreset.ratio)

                let rect = CGRect(
                    x: (container.width - target.width) / 2,
                    y: topPadding + (paddedContainer.height - target.height) / 2,
                    width: target.width,
                    height: target.height
                )



                if showMask {
                    // Dim everything outside the target rect.
                    Path { path in

                            path.addRect(CGRect(origin: .zero, size: container))
                            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))


                    }
                    .fill(.ultraThinMaterial, style: FillStyle(eoFill: true))



                    if showPlatformSafe, let avoid = aspectPreset.platformAvoidance {
                        // Shade platform UI areas inside the target rect to indicate regions to avoid.
                        if avoid.top > 0 {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)
                            )
                            .path(
                                in: CGRect(
                                    x: rect.minX,
                                    y: rect.minY,
                                    width: rect.width,
                                    height: rect.height * avoid.top
                                ),

                            )

                            .fill(DesignToken.maskColor)

                        }
                        if avoid.bottom > 0 {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(bottomLeading: cornerRadius, bottomTrailing: cornerRadius)
                            )
                            .path(
                                in: CGRect(
                                    x: rect.minX,
                                    y: rect.maxY - (rect.height * avoid.bottom),
                                    width: rect.width,
                                    height: rect.height * avoid.bottom
                                )
                            )
                            .fill(DesignToken.maskColor)
                            .cornerRadius(cornerRadius, corners: [.bottom])
                        }
                        if avoid.left > 0 {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(topLeading: cornerRadius, bottomLeading: cornerRadius)
                            )
                            .path(
                                in: CGRect(
                                    x: rect.minX,
                                    y: rect.minY,
                                    width: rect.width * avoid.left,
                                    height: rect.height
                                )
                            )
                            .fill(DesignToken.maskColor)
                            .cornerRadius(cornerRadius, corners: [.left])
                        }
                        if avoid.right > 0 {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(bottomTrailing: cornerRadius, topTrailing: cornerRadius)
                            )
                            .path(
                                in: CGRect(
                                    x: rect.maxX - (rect.width * avoid.right),
                                    y: rect.minY,
                                    width: rect.width * avoid.right,
                                    height: rect.height
                                )
                            )
                            .fill(DesignToken.maskColor)
                            .cornerRadius(cornerRadius, corners: [.right])
                        }
                    }

                    // Border for the target rect.
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .path(in: rect)
                        .stroke(.regularMaterial, lineWidth: borderLineWidth * 2)
                        .clipped()


                }


                if showGuides {
                    // Inner safe guides (e.g., title/action safe).
                    let rect90 = rect.insetBy(dx: rect.width * 0.05, dy: rect.height * 0.05)

                    RoundedRectangle(cornerRadius: max(0, cornerRadius - 2))
                        .path(in: rect90)
                        .stroke(DesignToken.guideColor, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))

                    // Crosshair guides (subtle).
                    Path { p in
                        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
                        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
                        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                    }
                    .stroke(DesignToken.guideColor, lineWidth: 1)
                }
            }
            .animation(.easeInOut, value: aspectPreset.ratio)
        }

        private func fittedSize(container: CGSize, ratio: CGSize) -> CGSize {
            guard ratio.width > 0, ratio.height > 0 else { return container }
            let containerAspect = container.width / max(container.height, 1)
            let targetAspect = ratio.width / ratio.height

                // Fit the target rect fully inside the container.
                if containerAspect >= targetAspect {
                    // Container is wider than target → limit by height.
                    let height = container.height
                    let width = height * targetAspect
                    return CGSize(width: width, height: height)
                } else {
                    // Container is taller than target → limit by width.
                    let width = container.width
                    let height = width / targetAspect
                    return CGSize(width: width, height: height)
                }


        }
    }

    class PlayerView: NSView {
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var dbags = [AnyCancellable]()


        init(captureSession: AVCaptureSession) {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            super.init(frame: .zero)
            setupLayer()
        }

        func setupLayer() {
            guard let previewLayer else { return }
            previewLayer.frame = self.frame
            previewLayer.contentsGravity = .resizeAspectFill
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
            layer = previewLayer
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    struct VideoOutputView: NSViewRepresentable {
        typealias NSViewType = PlayerView
        @Binding var captureSession: AVCaptureSession
        @Binding var isMirror: Bool

        func makeNSView(context: Context) -> PlayerView {
            let player = PlayerView(captureSession: captureSession)
            guard let previewLayer = player.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
                return player
            }
            DispatchQueue.main.async {
                connection.isVideoMirrored = isMirror
            }

            return player
        }

        func updateNSView(_ nsView: PlayerView, context: Context) {
            guard let previewLayer = nsView.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
                return
            }

            DispatchQueue.main.async {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = isMirror
            }
        }
    }


    actor Manager {

        func addAudioInput(_ session: AVCaptureSession) {
            guard let device = AVCaptureDevice.default(for: .audio) else { return }
            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }

        func addVideoInput(_ session: AVCaptureSession) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput(device: device) else { return }
            if session.canAddInput(input) {
                session.addInput(input)
            }
        }

    }

    enum ResolutionPreset: String, CaseIterable, Identifiable {
        case p720 = "720p"
        case p1080 = "1080p"
        case p4k = "4K"
        case high = "High"

        var id: String { rawValue }

        var sessionPreset: AVCaptureSession.Preset {
            switch self {
                case .p720:  return .hd1280x720
                case .p1080: return .hd1920x1080
                case .p4k:   return .hd4K3840x2160
                case .high:  return .high
            }
        }
    }

    struct UIAlerter: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    @MainActor
    class ViewModel: ObservableObject {
        private var manager: Manager = .init()
        @Published var session: AVCaptureSession = .init()
        @Published var mode: Mode = .camera

        @Published var videoDevices: [AVCaptureDevice] = []
        @Published var selectedVideoDeviceID: String = ""
        @Published var selectedResolution: ResolutionPreset = .p1080
        @Published var includeAudio: Bool = true

        @Published var isRunning: Bool = false
        @Published var isRecording: Bool = false

        @Published var lastSavedURL: URL?
        @Published var lastThumbnail: NSImage?
        @Published var alert: UIAlerter?

        @Published private(set) var recordingDuration: TimeInterval = 0
        var recordingTimeString: String {
            let total = Int(recordingDuration.rounded(.down))
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            return h > 0 ? String(format: "%d:%02d:%02d", h, m, s) : String(format: "%02d:%02d", m, s)
        }

        // One serial queue for session ops + sample callbacks => no races.
        private let captureQueue = DispatchQueue(label: "camera.capture.queue")

        private var isConfigured = false

        private var videoInput: AVCaptureDeviceInput?
        private var audioInput: AVCaptureDeviceInput?

        private let videoOutput = AVCaptureVideoDataOutput()
        private let audioOutput = AVCaptureAudioDataOutput()

        init() {
            Task {
                await addInputs()
            }

            if !session.isRunning {
                session.startRunning()
            }
        }

        func addInputs() async {
            await manager.addAudioInput(session)
            await manager.addVideoInput(session)
        }
    }

}

#Preview {
    VICameraCaptureView()
}
