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
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "gridawake" else { return }
        
        // Parse parameters from query string
        // Format: gridawake://connect?name=...&ip=...&port=...&mac=...&secret=...
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.host == "connect" || components.path == "/connect" else { return }
              
        let queryItems = components.queryItems ?? []
        let name = queryItems.first(where: { $0.name == "name" })?.value ?? "PC"
        let ip = queryItems.first(where: { $0.name == "ip" })?.value ?? ""
        let portString = queryItems.first(where: { $0.name == "port" })?.value ?? "7070"
        let mac = queryItems.first(where: { $0.name == "mac" })?.value ?? ""
        let secret = queryItems.first(where: { $0.name == "secret" })?.value ?? ""
        
        guard !ip.isEmpty else { return }
        let port = Int(portString) ?? 7070
        
        let computer = Computer(name: name, ip: ip, port: port, mac: mac, secret: secret)
        
        // Add to appState (this automatically persists and selects it)
        appState.addComputer(computer)
        
        // Show success message in the correct language
        let prefix: String
        switch appState.settings.language {
        case .uk: prefix = "Комп'ютер додано"
        case .ru: prefix = "Компьютер добавлен"
        case .en: prefix = "Computer added"
        }
        appState.showToast("\(prefix): \(name)")
    }
}
