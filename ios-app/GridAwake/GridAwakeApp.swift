import SwiftUI

@main
struct GridAwakeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
                .animation(.easeInOut(duration: 0.3), value: appState.settings.selectedThemeId)
        }
    }
}
