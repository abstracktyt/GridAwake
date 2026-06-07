import SwiftUI
import Combine

// MARK: - AppState

class AppState: ObservableObject {
    @Published var computers: [Computer] = []
    @Published var selectedIndex: Int = 0
    @Published var settings: AppSettings = AppSettings()
    @Published var isOnline: Bool = false
    @Published var toastMessage: String? = nil

    private var toastTimer: Timer?
    private let computersKey = "ga_computers_v2"
    private let settingsKey  = "ga_settings_v2"

    init() { load() }

    // MARK: Computed

    var selectedComputer: Computer? {
        guard !computers.isEmpty, selectedIndex < computers.count else { return nil }
        return computers[selectedIndex]
    }

    var colorScheme: ColorScheme? {
        switch currentTheme.mode {
        case .dark:  return .dark
        case .light: return .light
        }
    }

    var currentTheme: AppTheme {
        AppTheme.all.first { $0.id == settings.selectedThemeId } ?? AppTheme.ocean
    }

    // MARK: Computer CRUD

    func addComputer(_ c: Computer) {
        computers.append(c)
        selectedIndex = computers.count - 1
        save()
    }

    func removeComputer(at index: Int) {
        computers.remove(at: index)
        selectedIndex = max(0, min(selectedIndex, computers.count - 1))
        save()
    }

    func updateComputer(at index: Int, with c: Computer) {
        guard index < computers.count else { return }
        computers[index] = c
        save()
    }

    // MARK: Settings

    func updateSettings(_ s: AppSettings) {
        settings = s
        L10n.language = s.language
        save()
    }

    // MARK: Toast

    func showToast(_ message: String) {
        toastMessage = message
        toastTimer?.invalidate()
        toastTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            withAnimation { self?.toastMessage = nil }
        }
    }

    // MARK: Persistence

    private func save() {
        if let d = try? JSONEncoder().encode(computers) { UserDefaults.standard.set(d, forKey: computersKey) }
        if let d = try? JSONEncoder().encode(settings)  { UserDefaults.standard.set(d, forKey: settingsKey)  }
    }

    private func load() {
        if let d = UserDefaults.standard.data(forKey: computersKey),
           let v = try? JSONDecoder().decode([Computer].self, from: d) { computers = v }
        if let d = UserDefaults.standard.data(forKey: settingsKey),
           let v = try? JSONDecoder().decode(AppSettings.self, from: d) {
            settings = v
            L10n.language = v.language
        }
    }
}
