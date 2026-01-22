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

struct VECameraCaptureView: View {

    @ObservedObject var captureViewModel: CaptureViewModel

    @StateObject private var viewModel: ViewModel = .init()
    @AppStorage(.storageKey(.aspectPreset)) private var aspectPreset: AspectPreset = .youtube
    @AppStorage(.storageKey(.showAspectMask)) private var showAspectMask: Bool = true
    @AppStorage(.storageKey(.showSafeGuides)) private var showSafeGuides: Bool = true
    @AppStorage(.storageKey(.showPlatformGuides)) private var showPlatformSafe: Bool = true
    @AppStorage(.storageKey(.isMirrored)) private var isMirrored: Bool = false

    @State private var spacing: CGFloat = 8
    @State private var isTimerEnabled: Bool = false
    @State private var timerSelection: TimeInterval.Option = .threeSeconds

    @Namespace private var namespace
    @Namespace private var namespace2

    private let ratioSize = CGSize(width: 16, height: 9)

    var body: some View {

        NavigationStack  {
            ZStack(alignment: .bottom) {
                // MARK: Video preview
                VideoOutputView(captureSession: $captureViewModel.session, isMirror: $isMirrored)
                    .ignoresSafeArea(.all)

                // MARK: Crop mask for selected ratio
                AspectMaskOverlay(
                    aspectPreset: aspectPreset,
                    showGuides: showSafeGuides,
                    showMask: showAspectMask,
                    showPlatformSafe: showPlatformSafe
                )
                .environmentObject(viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)

                // MARK: Bottom bar content
                BottomBar()
            }
            .environmentObject(viewModel)
            .environmentObject(captureViewModel)
        }
        // Keep the window resizable but constrained to 16:9.
        .background(WindowAspectRatioLock(ratio: ratioSize))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



extension VECameraCaptureView {

    @ViewBuilder
    func BottomBar() -> some View {
        PlayerControlsView(viewModel: captureViewModel.controlsBarViewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, .small)
            .inspector(isPresented: $viewModel.isSettingsPresented) {
                EditorSettingsView()
                    .background(Color(.underPageBackgroundColor))
                    .inspectorColumnWidth(.columnWidth(spacing: .threeOfTwelve))
            }
    }

    @ViewBuilder
    func timeLabel() -> some View {
        Text(viewModel.recordingTimeString)
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(viewModel.isRecording ? .red : .secondary)
    }

    @ToolbarContentBuilder
    func topTrailingControls() -> some ToolbarContent {

        ToolbarItem {
            GlassEffectContainer {
                HStack {

                    Toggle(isOn: $isTimerEnabled) {
                        Label("Timer", systemImage: "timer")
                            .font(.title2)

                    }
                    .labelStyle(.iconOnly)
                    .toggleStyle(.automatic)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)


                    if isTimerEnabled {
                        Picker("Timer", selection: $timerSelection) {
                            ForEach(TimeInterval.options) { option in
                                Text("\(option.rawValue)s").tag(option)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .buttonStyle(.glass)
                    }
                }

                .glassEffect(.regular)
                .glassEffectUnion(id: isTimerEnabled ? 2 : 1, namespace: namespace2)
                .animation(.bouncy.delay(isTimerEnabled ? 0.2 : 0), value: isTimerEnabled)
                .glassEffectTransition(.materialize)
            }
        }

        ToolbarItemGroup {
            GlassEffectContainer {
                HStack {
                    Toggle(
                        Constants.showGuidesTitle,
                        systemImage: "viewfinder",
                        isOn: $showSafeGuides
                    )
                    .help(Constants.showGuidesHelp)
                    .toggleStyle(.button)
                    .glassEffectID("toolbar.glass.guide", in: namespace)

                    Toggle(
                        Constants.showMaskTitle,
                        systemImage: "circle.rectangle.filled.pattern.diagonalline",
                        isOn: $showAspectMask
                    )
                    .help(Constants.showMaskHelp)
                    .toggleStyle(.button)
                    .glassEffectID("toolbar.glass.mask", in: namespace)
                    .animation(
                        .spring(
                            response: 0.35,
                            dampingFraction: 0.85
                        ),
                        value: showAspectMask
                    )

                    if showAspectMask {

                        Picker(Constants.ratioMenuTitle, systemImage: "aspectratio", selection: $aspectPreset) {
                            ForEach(AspectPreset.allCases) { preset in
                                Label(preset.rawValue.capitalized, systemImage: preset.icon)
                                    .tag(preset)
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .pickerStyle(.automatic)
                        .buttonStyle(.glass)
                        .glassEffectID("toolbar.glass.focus", in: namespace)
                    }
                }
            }
            .glassEffectTransition(.materialize)
        }

        ToolbarSpacer(.flexible)

        ToolbarItem {
            Toggle(
                Constants.mirrorTitle,
                systemImage: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right",
                isOn: $isMirrored
            )
            .help(Constants.mirrorHelp)
            .toggleStyle(.button)
        }
    }

    // Glass group namespace ids
    enum nameSpaceNames {
        case recordControls
        case mediaControls
    }

}


extension VECameraCaptureView {

    struct DesignToken {
        static let defaultCornerRadius: CGFloat = 32
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
                    return CGSize(width: 3, height: 4)
            }
        }

        var icon: String {
            switch self {
                case .youtube:
                    return "rectangle.ratio.16.to.9"
                case .tiktok:
                    return "rectangle.ratio.9.to.16"
                case .instagram:
                    return "rectangle.ratio.3.to.4"
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

        @EnvironmentObject var editorViewModel: ViewModel

        var aspectPreset: AspectPreset = .youtube
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
                // Centered target rect inside the padded container.
                let originX = (container.width - target.width) / 2
                let originY = topPadding + (paddedContainer.height - target.height) / 2

                ZStack {
                    if showMask {
                        // Dim everything outside the target rect.
                        AnimatableEvenOddMask(
                            outerSize: container,
                            innerRect: CGRect(x: originX, y: originY, width: target.width, height: target.height),
                            cornerRadius: cornerRadius
                        )
                        .fill(
                            .thickMaterial,
                            style: FillStyle(eoFill: true)
                        )


                        if showPlatformSafe, let avoid = aspectPreset.platformAvoidance {
                            // Top avoid area
                            if avoid.top > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(topLeading: cornerRadius, topTrailing: cornerRadius)
                                )
                                .fill(DesignToken.maskColor)
                                .frame(width: target.width, height: target.height * avoid.top)
                                .position(x: originX + target.width / 2, y: originY + (target.height * avoid.top) / 2)
                            }

                            // Bottom avoid area
                            if avoid.bottom > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(bottomLeading: cornerRadius, bottomTrailing: cornerRadius)
                                )
                                .fill(DesignToken.maskColor)
                                .frame(width: target.width, height: target.height * avoid.bottom)
                                .position(x: originX + target.width / 2, y: originY + target.height - (target.height * avoid.bottom) / 2)
                            }

                            // Left avoid area
                            if avoid.left > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(topLeading: cornerRadius, bottomLeading: cornerRadius)
                                )
                                .fill(DesignToken.maskColor)
                                .frame(width: target.width * avoid.left, height: target.height)
                                .position(x: originX + (target.width * avoid.left) / 2, y: originY + target.height / 2)
                            }

                            // Right avoid area
                            if avoid.right > 0 {
                                UnevenRoundedRectangle(
                                    cornerRadii: .init(bottomTrailing: cornerRadius, topTrailing: cornerRadius)
                                )
                                .fill(DesignToken.maskColor)
                                .frame(width: target.width * avoid.right, height: target.height)
                                .position(x: originX + target.width - (target.width * avoid.right) / 2, y: originY + target.height / 2)
                            }
                        }

                        // Border for the target rect.
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.ultraThickMaterial.quinary, lineWidth: borderLineWidth * 2)
                            .frame(width: target.width, height: target.height)
                            .position(x: originX + target.width / 2, y: originY + target.height / 2)
                    }

                    if showGuides {
                        // Inner safe guides.
                        let insetX = target.width * 0.05
                        let insetY = target.height * 0.05

                        RoundedRectangle(cornerRadius: cornerRadius / 1.5, style: .continuous)
                            .stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                            .frame(width: target.width - (insetX * 2), height: target.height - (insetY * 2))
                            .position(x: originX + target.width / 2, y: originY + target.height / 2)

                        // Crosshair guides.
                        Path { p in
                            p.move(to: CGPoint(x: originX + target.width / 2, y: originY))
                            p.addLine(to: CGPoint(x: originX + target.width / 2, y: originY + target.height))
                            p.move(to: CGPoint(x: originX, y: originY + target.height / 2))
                            p.addLine(to: CGPoint(x: originX + target.width, y: originY + target.height / 2))
                        }
                        .stroke(.thickMaterial, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                    }
                }
            }
            // Animate when the selected preset changes.
            .animation(.interactiveSpring, value: aspectPreset)
        }

        /// An even-odd shape (outer rect with an inner rounded-rect cutout) whose inner rect animates.
        struct AnimatableEvenOddMask: Shape {
            var outerSize: CGSize
            var innerRect: CGRect
            var cornerRadius: CGFloat

            // Animate using center + size (CGRect itself isn't animatable).
            var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
                get {
                    .init(
                        .init(innerRect.midX, innerRect.midY),
                        .init(innerRect.width, innerRect.height)
                    )
                }
                set {
                    let midX = newValue.first.first
                    let midY = newValue.first.second
                    let width = max(0, newValue.second.first)
                    let height = max(0, newValue.second.second)
                    innerRect = CGRect(x: midX - width / 2, y: midY - height / 2, width: width, height: height)
                }
            }

            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.addRect(CGRect(origin: .zero, size: outerSize))
                path.addRoundedRect(in: innerRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius), style: .continuous)
                return path
            }
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
        private var cancellables: Set<AnyCancellable> = []

        @Published var session: AVCaptureSession = .init()
        @Published var mode: Mode = .camera

        @Published var videoDevices: [AVCaptureDevice] = []
        @Published var selectedVideoDeviceID: String = ""
        @Published var selectedResolution: ResolutionPreset = .p1080
        @Published var includeAudio: Bool = true
        @Published var isSettingsPresented: Bool = false

        @Published var isRunning: Bool = false
        @Published var isRecording: Bool = false

        @Published var lastSavedURL: URL?
        @Published var lastThumbnail: NSImage?
        @Published var alert: UIAlerter?
        @Published var colunmVisibility: NavigationSplitViewVisibility = .doubleColumn

        @Published var playerControlViewModel: PlayerControlsView.ViewModel = .init()
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
                // Load the available devices
                videoDevices = await manager.availableCameras()
            }

            if !session.isRunning {
                session.startRunning()
            }

//            playerControlViewModel
//                .isSettingsPresented
//                .map { $0 }
//                .assign(to: \.isSettingsPresented, on: self)
//                .store(in: &cancellables)
        }

        func addInputs() async {
            _ = await manager.addAudioInput(session)
            _ = await manager.addVideoInput(session)
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
        previewLayer.isDeferredStartEnabled = true
        previewLayer.contentsGravity = .resizeAspectFill
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.automaticallyAdjustsVideoMirroring = true
        layer = previewLayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct VideoOutputView: NSViewRepresentable {
    typealias NSViewType = PlayerView
    var captureSession: AVCaptureSession
    @Binding var isMirror: Bool

    func makeNSView(context: Context) -> PlayerView {
        let player = PlayerView(captureSession: captureSession)
        guard let previewLayer = player.previewLayer, let connection = previewLayer.connection, connection.isVideoMirroringSupported else {
            return player
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

    func availableCameras() -> [AVCaptureDevice] {
        return AVCaptureDevice
                .DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera, .external],
                    mediaType: .video,
                    position: .unspecified
                )
                .devices
    }



    func start(_ session: AVCaptureSession, with selectedCamera: CameraInfo?) throws -> AVCaptureDeviceInput {
        guard !session.isRunning else {
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Remove existing inputs
        for input in session.inputs {
            session.removeInput(input)
        }

        // Add video input
        guard let camera = selectedCamera, let input = try? AVCaptureDeviceInput(device: camera.device), session.canAddInput(input) else {
            session.commitConfiguration()
            throw NSError(domain: String(describing: self), code: AVError.sessionNotRunning.rawValue)
        }

        return input
    }

    func stop(_ session: AVCaptureSession) async -> Void {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    func addAudioInput(_ session: AVCaptureSession) -> AVCaptureSession {
        guard let device = AVCaptureDevice.default(for: .audio) else { return session }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return session }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        return session
    }

    func addVideoInput(_ session: AVCaptureSession, with selected: AVCaptureDevice? = nil) -> AVCaptureSession {
        guard let defaultDevice = AVCaptureDevice.default(for: .video) else {  return session }
        let device: AVCaptureDevice = selected ?? defaultDevice
        guard let input = try? AVCaptureDeviceInput(device: device) else {  return session }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        return session
    }
}


#Preview {
    @Previewable @StateObject var captureVM: CaptureViewModel = .init()
    VECameraCaptureView(captureViewModel: captureVM)
}
