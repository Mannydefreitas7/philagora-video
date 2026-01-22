import SwiftUI
import AVFoundation
import Combine

struct CameraOverlayView: View {
    @StateObject private var cameraManager = CameraPreviewViewModel()
    @Binding var isVisible: Bool
    @Binding var position: CameraPosition
    @Binding var size: CameraSize
    @Binding var shape: CameraShape

    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        if isVisible {
            GeometryReader { geometry in
                ZStack {
                    // Camera preview
                    CameraPreviewView(session: cameraManager.session)
                        .frame(width: size.dimensions.width, height: size.dimensions.height)
                        .clipShape(shape.shape)
                        .overlay(
                            shape.shape
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        .position(
                            calculatePosition(in: geometry.size)
                        )
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    isDragging = false
                                    // Snap to nearest corner
                                    updatePositionFromDrag(translation: value.translation, in: geometry.size)
                                    dragOffset = .zero
                                }
                        )
                        .animation(.spring(response: 0.3), value: isDragging)
                        .animation(.spring(response: 0.3), value: position)
                }
            }
        }
    }

    private func calculatePosition(in containerSize: CGSize) -> CGPoint {
        let padding: CGFloat = 20
        let halfWidth = size.dimensions.width / 2
        let halfHeight = size.dimensions.height / 2

        switch position {
        case .topLeft:
            return CGPoint(x: padding + halfWidth, y: padding + halfHeight)
        case .topRight:
            return CGPoint(x: containerSize.width - padding - halfWidth, y: padding + halfHeight)
        case .bottomLeft:
            return CGPoint(x: padding + halfWidth, y: containerSize.height - padding - halfHeight)
        case .bottomRight:
            return CGPoint(x: containerSize.width - padding - halfWidth, y: containerSize.height - padding - halfHeight)
        }
    }

    private func updatePositionFromDrag(translation: CGSize, in containerSize: CGSize) {
        let currentPos = calculatePosition(in: containerSize)
        let newX = currentPos.x + translation.width
        let newY = currentPos.y + translation.height

        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2

        let isLeft = newX < centerX
        let isTop = newY < centerY

        if isTop {
            position = isLeft ? .topLeft : .topRight
        } else {
            position = isLeft ? .bottomLeft : .bottomRight
        }
    }
}

#Preview {
    CameraOverlayView(
        isVisible: .constant(true),
        position: .constant(.bottomRight),
        size: .constant(.medium),
        shape: .constant(.circle)
    )
    .frame(width: 800, height: 600)
}
