import Foundation

// MARK: - Language

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case uk = "uk"
    case ru = "ru"
    case en = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .uk: return "Українська"
        case .ru: return "Русский"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .uk: return "🇺🇦"
        case .ru: return "🇷🇺"
        case .en: return "🇬🇧"
        }
    }
}

// MARK: - AppSettings

struct AppSettings: Codable {
    var language: AppLanguage = .uk
    var selectedThemeId: String = AppTheme.ocean.id
    var soundEnabled: Bool = true
    var volume: Double = 1.0
    var hapticsEnabled: Bool = true
}
