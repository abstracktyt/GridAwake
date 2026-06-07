import SwiftUI

// MARK: - DelayPickerView
// Appears as a sheet when user long-presses Shutdown or Restart.

struct DelayPickerView: View {
    let theme: AppTheme
    let onConfirm: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    private let presets = [30, 60, 120, 300, 600, 1800, 3600]
    @State private var customSeconds: String = "60"
    @State private var useCustom = false

    private var isDark: Bool { theme.mode == .dark }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color(hex: "0D0D1A") : Color(.systemGroupedBackground))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        Text(L10n.t("delayed_action"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        // Preset chips
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 10) {
                            ForEach(presets, id: \.self) { s in
                                Button { confirm(s) } label: {
                                    Text(formatDelay(s))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(theme.gradient)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // Custom input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.t("delay_seconds"))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)

                            HStack {
                                TextField("60", text: $customSeconds)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isDark ? Color(hex: "1c1e2e") : Color.white)
                                    )

                                Button {
                                    if let s = Int(customSeconds), s > 0 { confirm(s) }
                                } label: {
                                    Text(L10n.t("confirm"))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20).padding(.vertical, 12)
                                        .background(theme.gradient)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(L10n.t("delayed_action"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.t("cancel_btn")) { dismiss() }
                }
            }
        }
    }

    func confirm(_ seconds: Int) {
        onConfirm(seconds)
    }

    func formatDelay(_ s: Int) -> String {
        if s < 60  { return "\(s)s" }
        if s < 3600 { return "\(s/60)m" }
        return "\(s/3600)h"
    }
}
