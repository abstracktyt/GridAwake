import SwiftUI

// MARK: - Theme Mode

enum ThemeMode: String, Codable {
    case light, dark
}

// MARK: - AppTheme

struct AppTheme: Identifiable, Hashable {
    let id: String
    let nameKey: String          // L10n key
    let emoji: String
    let mode: ThemeMode
    let gradientColors: [Color]  // button gradient
    let accentColor: Color
    let bgColor: Color
    let cardColor: Color
    let textColor: Color

    // Convenience
    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
    }

    // MARK: Presets

    static let ocean = AppTheme(
        id: "ocean", nameKey: "theme_ocean", emoji: "🌊", mode: .light,
        gradientColors: [Color(hex: "0077FF"), Color(hex: "00C6FF")],
        accentColor: Color(hex: "0077FF"),
        bgColor: Color(hex: "F4F6FA"),
        cardColor: .white,
        textColor: Color(hex: "111827")
    )

    static let midnight = AppTheme(
        id: "midnight", nameKey: "theme_midnight", emoji: "🫐", mode: .dark,
        gradientColors: [Color(hex: "4444AA"), Color(hex: "7777DD")],
        accentColor: Color(hex: "8899FF"),
        bgColor: Color(hex: "0D0D1A"),
        cardColor: Color(hex: "1A1A2E"),
        textColor: .white
    )

    static let cyberpunk = AppTheme(
        id: "cyberpunk", nameKey: "theme_cyberpunk", emoji: "🤖", mode: .dark,
        gradientColors: [Color(hex: "FF0080"), Color(hex: "CC00FF")],
        accentColor: Color(hex: "FF0080"),
        bgColor: Color(hex: "0A0A0F"),
        cardColor: Color(hex: "151525"),
        textColor: .white
    )

    static let fire = AppTheme(
        id: "fire", nameKey: "theme_fire", emoji: "🔥", mode: .light,
        gradientColors: [Color(hex: "FF4500"), Color(hex: "FF8C00")],
        accentColor: Color(hex: "FF6600"),
        bgColor: Color(hex: "FFF5F0"),
        cardColor: .white,
        textColor: Color(hex: "1A0A00")
    )

    static let forest = AppTheme(
        id: "forest", nameKey: "theme_forest", emoji: "🌲", mode: .light,
        gradientColors: [Color(hex: "1B5E20"), Color(hex: "4CAF50")],
        accentColor: Color(hex: "2E7D32"),
        bgColor: Color(hex: "F1F8F1"),
        cardColor: .white,
        textColor: Color(hex: "0A1F0A")
    )

    static let sakura = AppTheme(
        id: "sakura", nameKey: "theme_sakura", emoji: "🌸", mode: .light,
        gradientColors: [Color(hex: "FF69B4"), Color(hex: "FF85C0")],
        accentColor: Color(hex: "FF69B4"),
        bgColor: Color(hex: "FFF0F5"),
        cardColor: .white,
        textColor: Color(hex: "1A001A")
    )

    static let all: [AppTheme] = [ocean, midnight, cyberpunk, fire, forest, sakura]
}

// MARK: - Color from hex

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
