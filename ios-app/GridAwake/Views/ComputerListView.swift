import SwiftUI

// MARK: - ComputerListView

struct ComputerListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showAddComputer = false
    @State private var editingIndex: Int? = nil

    private var theme: AppTheme { appState.currentTheme }
    private var isDark: Bool    { theme.mode == .dark }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color(hex: "0D0D1A") : Color(.systemGroupedBackground))
                    .ignoresSafeArea()

                Group {
                    if appState.computers.isEmpty {
                        emptyView
                    } else {
                        listView
                    }
                }
            }
            .navigationTitle(L10n.t("my_computers"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.t("done")) { dismiss() }.fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddComputer = true } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
            .sheet(isPresented: $showAddComputer) {
                AddComputerView { c in
                    appState.addComputer(c)
                    showAddComputer = false
                }
                .environmentObject(appState)
            }
        }
    }

    var listView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(appState.computers.enumerated()), id: \.element.id) { idx, c in
                    computerRow(c, index: idx)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }

    func computerRow(_ c: Computer, index: Int) -> some View {
        let isSelected = index == appState.selectedIndex

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isSelected ? theme.accentColor : Color.gray.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(c.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDark ? .white : .primary)
                Text("\(c.ip):\(c.port)")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(theme.accentColor)
            }

            Button {
                appState.removeComputer(at: index)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? Color(hex: "1a1a2e") : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? theme.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
        .onTapGesture {
            appState.selectedIndex = index
            dismiss()
        }
    }

    var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "desktopcomputer.trianglebadge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(theme.accentColor.opacity(0.4))
            Text(L10n.t("no_computers"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : .primary)
            Button { showAddComputer = true } label: {
                Label(L10n.t("add_computer"), systemImage: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28).padding(.vertical, 14)
                    .background(theme.gradient)
                    .cornerRadius(14)
            }
        }
    }
}
