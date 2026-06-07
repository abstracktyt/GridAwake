import SwiftUI

// MARK: - AddComputerView

struct AddComputerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var onAdd: (Computer) -> Void

    @State private var name:    String = ""
    @State private var ip:      String = ""
    @State private var port:    String = "7070"
    @State private var mac:     String = ""
    @State private var secret:  String = ""
    @State private var errorMsg: String? = nil

    private var theme: AppTheme { appState.currentTheme }
    private var isDark: Bool    { theme.mode == .dark }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color(hex: "0D0D1A") : Color(.systemGroupedBackground))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        manualForm
                            .padding(.top, 12)
                    }
                }
            }
            .navigationTitle(L10n.t("add_computer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.t("cancel_btn")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.t("save")) { save() }
                        .fontWeight(.semibold)
                        .foregroundColor(theme.accentColor)
                }
            }
        }
    }

    // MARK: - Manual form

    var manualForm: some View {
        VStack(spacing: 16) {
            if let err = errorMsg {
                Text(err)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            }

            fieldCard(label: L10n.t("computer_name"), text: $name,
                      icon: "desktopcomputer", keyboard: .default)
            fieldCard(label: L10n.t("ip_address"), text: $ip,
                      icon: "network", keyboard: .decimalPad,
                      hint: "192.168.1.100")
            fieldCard(label: L10n.t("port"), text: $port,
                      icon: "number", keyboard: .numberPad,
                      hint: "7070")
            fieldCard(label: L10n.t("mac_address"), text: $mac,
                      icon: "personalhotspot", keyboard: .asciiCapable,
                      hint: "AA:BB:CC:DD:EE:FF")
            fieldCard(label: L10n.t("password"), text: $secret,
                      icon: "lock", keyboard: .default, isSecure: true)

            // Info card
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(theme.accentColor)
                Text(L10n.t("network_note"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.accentColor.opacity(0.08))
            )
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 30)
    }

    func fieldCard(label: String, text: Binding<String>, icon: String,
                   keyboard: UIKeyboardType, hint: String = "", isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            Group {
                if isSecure {
                    SecureField(hint.isEmpty ? label : hint, text: text)
                } else {
                    TextField(hint.isEmpty ? label : hint, text: text)
                        .keyboardType(keyboard)
                }
            }
            .font(.system(size: 16))
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDark ? Color(hex: "1c1e2e") : Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Logic

    func save() {
        errorMsg = nil
        guard !name.isEmpty else { errorMsg = "Введіть назву"; return }
        guard !ip.isEmpty   else { errorMsg = "Введіть IP";    return }
        guard let p = Int(port), (1...65535).contains(p) else { errorMsg = "Невірний порт"; return }

        let computer = Computer(name: name, ip: ip, port: p,
                                mac: mac, secret: secret)
        onAdd(computer)
    }
}
