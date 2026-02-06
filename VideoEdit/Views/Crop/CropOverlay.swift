import SwiftUI

struct CropOverlay: View {
    @EnvironmentObject var appState: IAppState
    @State private var dragOffset: CGSize = .zero
    @State private var activeHandle: CropHandle?

    var body: some View {
        GeometryReader { geometry in
            let rect = appState.cropRect.isEmpty ?
                CGRect(x: 50, y: 50, width: geometry.size.width - 100, height: geometry.size.height - 100) :
                appState.cropRect

            ZStack {
                // Dimmed overlay
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                Rectangle()
                                    .frame(width: rect.width, height: rect.height)
                                    .position(x: rect.midX, y: rect.midY)
                                    .blendMode(.destinationOut)
                            )
                    )

                // Crop rectangle
                Rectangle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)

                // Rule of thirds grid
                Path { path in
                    let thirdW = rect.width / 3
                    let thirdH = rect.height / 3

                    for i in 1...2 {
                        path.move(to: CGPoint(x: rect.minX + CGFloat(i) * thirdW, y: rect.minY))
                        path.addLine(to: CGPoint(x: rect.minX + CGFloat(i) * thirdW, y: rect.maxY))

                        path.move(to: CGPoint(x: rect.minX, y: rect.minY + CGFloat(i) * thirdH))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + CGFloat(i) * thirdH))
                    }
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 1)

                // Corner handles
                CropHandleView()
                    .position(x: rect.minX, y: rect.minY)
                    .gesture(handleDrag(handle: .topLeft, geometry: geometry))

                CropHandleView()
                    .position(x: rect.maxX, y: rect.minY)
                    .gesture(handleDrag(handle: .topRight, geometry: geometry))

                CropHandleView()
                    .position(x: rect.minX, y: rect.maxY)
                    .gesture(handleDrag(handle: .bottomLeft, geometry: geometry))

                CropHandleView()
                    .position(x: rect.maxX, y: rect.maxY)
                    .gesture(handleDrag(handle: .bottomRight, geometry: geometry))
            }
            .onAppear {
                if appState.cropRect.isEmpty {
                    appState.cropRect = CGRect(x: 50, y: 50, width: geometry.size.width - 100, height: geometry.size.height - 100)
                }
            }
        }
    }

    private func handleDrag(handle: CropHandle, geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                var rect = appState.cropRect

                switch handle {
                case .topLeft:
                    rect.origin.x += value.translation.width
                    rect.origin.y += value.translation.height
                    rect.size.width -= value.translation.width
                    rect.size.height -= value.translation.height
                case .topRight:
                    rect.origin.y += value.translation.height
                    rect.size.width += value.translation.width
                    rect.size.height -= value.translation.height
                case .bottomLeft:
                    rect.origin.x += value.translation.width
                    rect.size.width -= value.translation.width
                    rect.size.height += value.translation.height
                case .bottomRight:
                    rect.size.width += value.translation.width
                    rect.size.height += value.translation.height
                default:
                    break
                }

                // Ensure minimum size
                rect.size.width = max(100, rect.size.width)
                rect.size.height = max(100, rect.size.height)

                appState.cropRect = rect
            }
    }
}
