import SwiftUI
import SwiftUIIntrospect
import AVFoundation
import Combine

// MARK: - Color Extensions

extension Color {
    
    static let pausedOrange = Color(red: 0.95, green: 0.6, blue: 0.1)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let maskColor: Self = .recordingRed.opacity(0.1)
    static let guideColor: Self = .white.opacity(0.5)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension ToggleStyle where Self == RecordToggleStyle {
    static var recordButton: RecordToggleStyle { get { .init() } }
    static var secondary: SecondaryToggleStyle { .init() }
}

// MARK: - Image Extensions

extension Image {
    public static let appIcon: Self = .init(
        nsImage: NSApplication.shared.applicationIconImage ?? NSApp.applicationIconImage
    )
    
}

extension Shape {
    
    func record(isOn: Bool) -> some Shape {
        return RecordShape(isRecording: isOn)
    }
    
}


// MARK: - View Extensions

extension View {
    
    // Hides the window control buttons
    func hideWindowControls(close: Bool = true, minimize: Bool = true, zoom: Bool = true) -> some View {
        modifier(WindowControlsModifier(hideClose: close, hideMinimize: minimize, hideZoom: zoom))
    }
    
    // Hides the window control buttons
    func centerWindow() -> some View {
        modifier(WindowCenteredModifier())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
    
    func heartBeatAnimation() -> some View {
        modifier(HeartBeatModifier())
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                
                mask()
                    .blendMode(.destinationOut)
            }
        )
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View, ElseContent: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content,
        @ViewBuilder else elseTransform: (Self) -> ElseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
    
    
    
    /// Changes the cursor appearance when hovering attached View
    /// - Parameters:
    ///   - active: onHover() value
    ///   - isDragging: indicate that dragging is happening. If true this will not change the cursor.
    ///   - cursor: the cursor to display on hover
    func isHovering(_ active: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
        if isDragging { return }
        if active {
            cursor.push()
        } else {
            NSCursor.pop()
        }
    }

    func isHovering() -> some View {
        modifier(HoverableModifier())
    }

    func hoverable(_ shape: any Shape = .rect) -> some View {
        modifier(HoverEffect(in: shape))
    }

    func pressPushEffect() -> some View {
        modifier(PushDownEffect())
    }
    
    func toolEffectUnion(id: ToolGroup, namespace: Namespace.ID) -> some View {
        self.glassEffectUnion(id: id, namespace: namespace)
    }

    func windowAspectRatio(_ ratio: CGSize) -> some View {
        self.background(WindowAspectRatio(ratio: ratio))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

extension DisclosureGroupStyle where Self == CollapsibleDisclosureGroupStyle {
    static func collapsible(_ position: DisclosureIndicatorPosition = .leading) -> CollapsibleDisclosureGroupStyle {
        return .init(position: position)
    }
}

extension ButtonStyle where Self == WelcomeButtonStyle {
    static var welcome: WelcomeButtonStyle { get { .init() }}
}

extension ButtonStyle {
    static var glassToolBar: GlassToolBarButtonStyle { get { .init() }}
    static func glassToolBar(_ glass: AnyGlassStyle) -> GlassToolBarButtonStyle {
        return GlassToolBarButtonStyle(glass: glass)
    }
    static func pushDown(glass: AnyGlassStyle?) -> PushDownButtonStyle {
        return PushDownButtonStyle(glass: glass)
    }
    static var pushDown: PushDownButtonStyle { get { .init() }}
}

extension PrimitiveButtonStyle where Self == GlassToolBarButtonStyle {
    static var glassToolBar: GlassToolBarButtonStyle { get { .init() }}
    static func glassToolBar(_ glass: AnyGlassStyle) -> GlassToolBarButtonStyle {
        return GlassToolBarButtonStyle(glass: glass)
    }
}

extension PrimitiveButtonStyle where Self == PushDownButtonStyle {
    
    static func pushDown(glass: AnyGlassStyle?) -> PushDownButtonStyle {
        return PushDownButtonStyle(glass: glass)
    }
    static var pushDown: PushDownButtonStyle { get { .init() }}
}

extension ButtonStyle where Self == ShineEffectButtonStyle {
    static func shineEffect(isEnabled: Binding<Bool>) -> ShineEffectButtonStyle {
        return ShineEffectButtonStyle(isEnabled: isEnabled)
    }
}

extension Namespace {
    
    struct RecorderTopBar: Hashable {
        static let cameraDisplay = "CameraDisplay"
        static let setting = "Settings"
        static  let recordControl = "RecordControl"
        static  let devideControl = "DevideControl"
        static let mediaControl = "MediaControl"
    }
    
}

extension TimeInterval {
    
    static var options = Option.allCases
    
    enum Option: String, CaseIterable, Identifiable {
        case threeSeconds = "3"
        case fiveSeconds = "5"
        case tenSeconds = "10"
        
        var id: String { rawValue }
    }
    
}

// MARK: - Audio Input Wave Environment

/// A single, normalized mic level value (0.0...1.0)
private struct AudioInputWaveKey: EnvironmentKey {
    static let defaultValue: Double = 0
}

/// A rolling history of normalized mic levels (0.0...1.0)
private struct AudioInputWaveHistoryKey: EnvironmentKey {
    static let defaultValue: [Double] = []
}

// MARK: - AVCaptureSession Microphone Monitor

/// Captures microphone audio via AVCaptureSession and exposes normalized levels suitable for UI.
///
/// Notes:
/// - Requires mic permission (NSMicrophoneUsageDescription in Info.plist)
/// - Uses RMS amplitude from PCM samples.
final class CaptureMicrophoneLevelMonitor: NSObject, ObservableObject {
    
    /// Instantaneous normalized level (0.0...1.0)
    @Published var level: Double = 0
    
    /// Rolling normalized level history (0.0...1.0)
    @Published var history: [Double] = []
    
    var session: AVCaptureSession
    private let output = AVCaptureAudioDataOutput()
    private let outputQueue = DispatchQueue(label: .dispatchQueueKey(.captureAudioOutput))

    private var historyCapacity: Int
    private var smoothing: Double
    
    /// - Parameters:
    ///   - historyCapacity: Number of samples to keep for waveform rendering.
    ///   - smoothing: 0.0 = no smoothing, closer to 1.0 = heavier smoothing.
    init(session: AVCaptureSession, historyCapacity: Int = 48, smoothing: Double = 0.75) {
        self.historyCapacity = max(8, historyCapacity)
        self.smoothing = min(max(smoothing, 0), 0.98)
        self.session = session
        super.init()
    }

    private var isConfigured = false
    
    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        session.beginConfiguration()
        session.sessionPreset = .high

        let _output = session.outputs.first {
            let connection = $0.connection(with: .audio)
            guard let connection else { return false }
            return connection.isActive
        } as? AVCaptureAudioDataOutput

        guard let _output else {
            assertionFailure("Couldn't find audio output")
            return
        }

        // Output
        _output.setSampleBufferDelegate(self, queue: outputQueue)
        if session.canAddOutput(_output) {
            session.addOutput(
                _output)
        }
        
        session.commitConfiguration()
    }
    
    private func push(_ newLevel: Double) {
        // Smooth to avoid jittery UI.
        let smoothed = (level * smoothing) + (newLevel * (1 - smoothing))
        
        // Maintain rolling history.
        var nextHistory = history
        nextHistory.append(smoothed)
        if nextHistory.count > historyCapacity {
            nextHistory.removeFirst(nextHistory.count - historyCapacity)
        }
        
        DispatchQueue.main.async {
            self.level = smoothed
            self.history = nextHistory
        }
    }
    
    /// Compute RMS from a CMSampleBuffer containing PCM audio.
    private func rms(from sampleBuffer: CMSampleBuffer) -> Double {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return 0 }
        
        var lengthAtOffset: Int = 0
        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        
        let status = CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: &lengthAtOffset,
            totalLengthOut: &totalLength,
            dataPointerOut: &dataPointer
        )
        
        guard status == kCMBlockBufferNoErr,
              let dataPointer,
              totalLength > 0 else { return 0 }
        
        // Most AVCapture audio comes as 16-bit signed PCM.
        let sampleCount = totalLength / MemoryLayout<Int16>.size
        guard sampleCount > 0 else { return 0 }
        
        let int16Ptr = dataPointer.withMemoryRebound(to: Int16.self, capacity: sampleCount) { $0 }
        
        var sumSquares: Double = 0
        for i in 0..<sampleCount {
            let s = Double(int16Ptr[i]) / Double(Int16.max)
            sumSquares += s * s
        }
        
        return sqrt(sumSquares / Double(sampleCount))
    }
    
    /// Maps RMS amplitude to a UI-friendly 0.0...1.0 range with some gain.
    private func normalize(_ rms: Double) -> Double {
        // RMS is usually quite small; apply gain and clamp.
        // Tune `gain` for your app's responsiveness.
        let gain = 18.0
        let v = min(max(rms * gain, 0), 1)
        return v
    }
}

extension CaptureMicrophoneLevelMonitor: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let rmsValue = rms(from: sampleBuffer)
        let normalized = normalize(rmsValue)
        push(normalized)
    }
}
// MARK: - Full Waveform Component

/// A simple, animated bar waveform driven by `audioInputWaveHistory`.
struct AudioWaveformBars: View {
    
    @Environment(\.audioInputWaveHistory) private var history
    @Environment(\.audioInputWave) private var audioInputWave
    var barWidth: CGFloat = 6
    var barSpacing: CGFloat = 4
    var minBarHeight: CGFloat = 2
    var maxBarHeight: CGFloat = 80
    var cornerRadius: CGFloat = 3
    
    var body: some View {
        HStack(alignment: .center, spacing: barSpacing) {

            ForEach(0...8, id: \.self) { idx in
                let v = history[idx]
                let h = min(max(minBarHeight, CGFloat(v) * maxBarHeight), maxBarHeight)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: barWidth, height: h)
                    .animation(.easeOut(duration: 0.10), value: h)
            }
        }
    }
}

/// Convenience example matching your desired API.
/// Note: @Environment vars cannot be initialized with a default value.
struct AudioWaveForm: View {
    
    @Environment(\.audioInputWave) private var audioInputWave
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 12, height: max(2, CGFloat(audioInputWave) * 100))
                .animation(.easeOut(duration: 0.10), value: audioInputWave)
        }
    }
}
