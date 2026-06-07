import SwiftUI

// MARK: - LanguagePickerView

struct LanguagePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var theme: AppTheme { appState.currentTheme }
    private var isDark: Bool    { theme.mode == .dark }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color(hex: "0D0D1A") : Color(.systemGroupedBackground))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Language rows
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(AppLanguage.allCases) { lang in
                                langRow(lang)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(L10n.t("choose_language"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    func langRow(_ lang: AppLanguage) -> some View {
        let isSelected = appState.settings.language == lang

        return Button {
            var s = appState.settings
            s.language = lang
            appState.updateSettings(s)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            HStack(spacing: 18) {
                Text(lang.flag)
                    .font(.system(size: 34))

                Text(lang.displayName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isDark ? .white : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.accentColor)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color(hex: "1a1a2e") : Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
