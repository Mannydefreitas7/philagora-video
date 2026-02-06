import SwiftUI
import WelcomeWindow
import Onboarding
import UserNotifications
import AppKit

struct VEWelcomeWindow: Scene {
    @EnvironmentObject var appState: IAppState
    @FocusState var focusedField: FocusTarget?
    @Environment(\.openWindow) var openWindow

    var createAction: AnyView {
        AnyView(createProjectButton())
    }

    var openAction: AnyView {
        AnyView(openProjectButton())
    }

    var body: some Scene {

        WelcomeWindow(iconImage: .appIcon) {
            WelcomeSubtitleView()
                .showOnboardingIfNeeded { markComplete in
                    WelcomeScreen.production
                        .with(continueAction: markComplete)
                }
        } actions: { dismissWindow in

            VIWelcomeButton(
                iconName: "record.circle",
                title: "Record",
                action: {
                    dismissWindow()
                    openWindow(id: .window(.recording))
                }
            )

            VIWelcomeButton(
                iconName: "square.and.arrow.down",
                title: "Import...",
                action: {
                    NSDocumentController.shared.openDocumentWithDialog(
                        configuration: .init(canChooseDirectories: false),
                        onDialogPresented: { dismissWindow() },
                        onCancel: { openWindow(id: .window(.welcome)) }
                    )
                }
            )

            VIWelcomeButton(
                iconName: "folder",
                title: "Open Project...",
                action: {
                    NSDocumentController.shared.openDocumentWithDialog(
                        configuration: .init(canChooseDirectories: true),
                        onDialogPresented: { dismissWindow() },
                        onCancel: { openWindow(id: .window(.welcome)) }
                    )
                }
            )
        } 


    }
}

extension WelcomeScreen {
    static let production = WelcomeScreen.apple(
        accentColor: .blue,
        appDisplayName: "My Amazing App",
        appIcon: Image("AppIcon"),
        features: [
            FeatureInfo(
                image: Image(systemName: "star.fill"),
                title: "Amazing Features",
                content: "Discover powerful tools that make your life easier."
            ),
            FeatureInfo(
                image: Image(systemName: "shield.fill"),
                title: "Privacy First",
                content: "Your data stays private and secure on your device."
            ),
            FeatureInfo(
                image: Image(systemName: "bolt.fill"),
                title: "Lightning Fast",
                content: "Optimized performance for the best user experience."
            )
        ],
        privacyPolicyURL: URL(string: "https://example.com/privacy"),
        titleSectionAlignment: .center
    )
}


extension VEWelcomeWindow {

    @ViewBuilder
    func createProjectButton() -> some View {
        NewFileButton {
            //
        }

    }

    @ViewBuilder
    func openProjectButton() -> some View {
        OpenFileOrFolderButton {
            //
        }
    }
}

