import SwiftUI
import AVFoundation
import Combine
import AppState

struct CameraOverlayView: View {

    @ObservedDependency(\.captureStore) var captureStore: CaptureView.Store

    /// View model
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        if viewModel.isVisible {
            GeometryReader { geometry in
                ZStack {
                    // Camera preview
                    CameraPreviewView(session: captureStore.currentSession)
                        .frame(width: viewModel.size.dimensions.width, height: viewModel.size.dimensions.height)
                        .clipShape(viewModel.shape.shape)
                        .overlay(
                            viewModel.shape.shape
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                        .position(
                            calculatePosition(in: geometry.size)
                        )
                        .offset(viewModel.dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.isDragging = true
                                    viewModel.dragOffset = value.translation
                                }
                                .onEnded { value in
                                    viewModel.isDragging = false
                                    // Snap to nearest corner
                                    updatePositionFromDrag(translation: value.translation, in: geometry.size)
                                    viewModel.dragOffset = .zero
                                }
                        )
                        .animation(.spring(response: 0.3), value: viewModel.isDragging)
                        .animation(.spring(response: 0.3), value: viewModel.position)
                }
            }
        }
    }

    private func calculatePosition(in containerSize: CGSize) -> CGPoint {
        let padding: CGFloat = 20
        let halfWidth = viewModel.size.dimensions.width / 2
        let halfHeight = viewModel.size.dimensions.height / 2

        switch viewModel.position {
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
            viewModel.position = isLeft ? .topLeft : .topRight
        } else {
            viewModel.position = isLeft ? .bottomLeft : .bottomRight
        }
    }
}

#Preview {
    @Previewable @StateObject var viewModel: CameraOverlayView.ViewModel = .init()
    CameraOverlayView(viewModel: viewModel)
    .frame(width: 800, height: 600)
}
