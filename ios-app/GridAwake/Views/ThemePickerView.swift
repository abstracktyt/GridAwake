import SwiftUI

// MARK: - ThemePickerView

struct ThemePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var theme: AppTheme { appState.currentTheme }
    private var isDark: Bool    { theme.mode == .dark }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color(hex: "0D0D1A") : Color(.systemGroupedBackground))
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Section header
                    Text(L10n.t("current_theme"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(AppTheme.all) { t in
                                themeRow(t)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(L10n.t("choose_theme"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    func themeRow(_ t: AppTheme) -> some View {
        let isSelected = appState.settings.selectedThemeId == t.id

        return Button {
            withAnimation(.spring(response: 0.35)) {
                var s = appState.settings
                s.selectedThemeId = t.id
                appState.updateSettings(s)
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            HStack(spacing: 16) {
                Text(t.emoji)
                    .font(.system(size: 34))

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.t(t.nameKey))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDark ? .white : .primary)

                    // Gradient preview bar
                    LinearGradient(
                        colors: t.gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 10)
                    .cornerRadius(5)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(t.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color(hex: "1a1a2e") : Color.white)
                    .shadow(color: .black.opacity(isSelected ? 0.12 : 0.05), radius: 6, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? t.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
