import SwiftUI

// MARK: - PowerButton

/// A full-width gradient button with tap + optional long-press actions.
struct PowerButton: View {
    let icon: String
    let label: String
    let theme: AppTheme
    var longPress: (() -> Void)? = nil
    let action: () -> Void

    @State private var pressing = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: theme.gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(18)
            .shadow(color: theme.accentColor.opacity(0.30), radius: 10, y: 4)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .scaleEffect(pressing ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressing)
        .gesture(
            LongPressGesture(minimumDuration: 0.7)
                .onChanged { _ in pressing = true }
                .onEnded { _ in
                    pressing = false
                    longPress?()
                }
                .simultaneously(with:
                    TapGesture().onEnded {
                        pressing = false
                        action()
                    }
                )
        )
        // Fallback for tap when no long-press needed
        .onTapGesture { action() }
        .onLongPressGesture(minimumDuration: 0,
                            pressing: { p in withAnimation { pressing = p } },
                            perform: {})
    }
}
