import SwiftUI
import AVFoundation
import Combine

struct CameraOverlayView: View {

    /// View model
    @ObservedObject var viewModel: CaptureView.State

    var body: some View {
        if viewModel.cameraOverlayViewModel.isVisible {
            GeometryReader { geometry in
                ZStack {
                    // Camera preview
                    CameraPreviewView(session: viewModel.engine.captureSession)
                        .frame(width: viewModel.cameraOverlayViewModel.size.dimensions.width, height: viewModel.cameraOverlayViewModel.size.dimensions.height)
                        .clipShape(viewModel.cameraOverlayViewModel.shape.shape)
                        .overlay(
                            viewModel.cameraOverlayViewModel.shape.shape
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        .position(
                            calculatePosition(in: geometry.size)
                        )
                        .offset(viewModel.cameraOverlayViewModel.dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.cameraOverlayViewModel.isDragging = true
                                    viewModel.cameraOverlayViewModel.dragOffset = value.translation
                                }
                                .onEnded { value in
                                    viewModel.cameraOverlayViewModel.isDragging = false
                                    // Snap to nearest corner
                                    updatePositionFromDrag(translation: value.translation, in: geometry.size)
                                    viewModel.cameraOverlayViewModel.dragOffset = .zero
                                }
                        )
                        .animation(.spring(response: 0.3), value: viewModel.cameraOverlayViewModel.isDragging)
                        .animation(.spring(response: 0.3), value: viewModel.cameraOverlayViewModel.position)
                }
            }
        }
    }

    private func calculatePosition(in containerSize: CGSize) -> CGPoint {
        let padding: CGFloat = 20
        let halfWidth = viewModel.cameraOverlayViewModel.size.dimensions.width / 2
        let halfHeight = viewModel.cameraOverlayViewModel.size.dimensions.height / 2

        switch viewModel.cameraOverlayViewModel.position {
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
            viewModel.cameraOverlayViewModel.position = isLeft ? .topLeft : .topRight
        } else {
            viewModel.cameraOverlayViewModel.position = isLeft ? .bottomLeft : .bottomRight
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel: CaptureView.State = .init()
    CameraOverlayView(viewModel: viewModel)
    .frame(width: 800, height: 600)
}
