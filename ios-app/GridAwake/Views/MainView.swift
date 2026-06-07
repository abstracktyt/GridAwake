import SwiftUI

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject var appState: AppState

    @State private var showMenu          = false
    @State private var showAddComputer   = false
    @State private var showThemePicker   = false
    @State private var showLangPicker    = false
    @State private var showComputerList  = false
    @State private var showSettingsPane  = false
    @State private var showDelaySheet    = false
    @State private var pendingAction: PowerAction? = nil

    @State private var volume: Double    = 1.0
    @State private var soundOn: Bool     = true

    // Status polling
    @State private var pollTask: Task<Void, Never>? = nil
    @State private var agentService: PCAgentService? = nil

    private var theme: AppTheme { appState.currentTheme }
    private var isDark: Bool    { theme.mode == .dark }

    var body: some View {
        ZStack(alignment: .top) {
            theme.bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 6)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        computerCard
                        settingsCard

                        if appState.computers.isEmpty {
                            emptyState
                        } else {
                            controlButtons
                            hintText
                            volumeRow
                            soundButton
                        }

                        footerNote
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }

            // Dimmed menu overlay
            if showMenu { menuOverlay }

            // Toast
            if let msg = appState.toastMessage {
                toastBanner(msg)
            }
        }
        .onAppear {
            syncFromState()
            startPolling()
        }
        .onDisappear { pollTask?.cancel() }
        .onChange(of: appState.selectedIndex) { _ in
            rebuildService()
            startPolling()
        }
        // Sheets
        .sheet(isPresented: $showAddComputer)  { addComputerSheet  }
        .sheet(isPresented: $showThemePicker)  { themePickerSheet  }
        .sheet(isPresented: $showLangPicker)   { langPickerSheet   }
        .sheet(isPresented: $showComputerList) { computerListSheet }
        .sheet(isPresented: $showDelaySheet)   { delaySheet        }
    }

    // MARK: ─── Top Bar ──────────────────────────────────────────────────────

    var topBar: some View {
        HStack {
            Spacer()
            Button { withAnimation(.spring(response: 0.3)) { showMenu.toggle() } } label: {
                ZStack {
                    Circle()
                        .fill(isDark ? Color.white.opacity(0.1) : Color.white)
                        .frame(width: 42, height: 42)
                        .shadow(color: .black.opacity(0.08), radius: 6)
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDark ? .white : .primary)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: ─── Menu Overlay ─────────────────────────────────────────────────

    var menuOverlay: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { showMenu = false } }
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                menuRow(icon: "desktopcomputer", key: "my_computers") {
                    showMenu = false; showComputerList = true
                }
                Divider().background(Color.gray.opacity(0.2))
                menuRow(icon: "paintpalette.fill", key: "themes") {
                    showMenu = false; showThemePicker = true
                }
                Divider().background(Color.gray.opacity(0.2))
                menuRow(icon: "globe", key: "language") {
                    showMenu = false; showLangPicker = true
                }
                Divider().background(Color.gray.opacity(0.2))
                menuRow(icon: "questionmark.circle.fill", key: "help") {
                    showMenu = false
                    if let url = URL(string: "https://dsc.gg/gridawake") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color(hex: "1e1e35") : Color.white)
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            )
            .frame(width: 230)
            .padding(.top, 54)
            .padding(.trailing, 16)
            .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
            .zIndex(200)
        }
        .zIndex(100)
    }

    func menuRow(icon: String, key: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundColor(theme.accentColor)
                    .frame(width: 26)
                Text(L10n.t(key))
                    .font(.system(size: 16))
                    .foregroundColor(isDark ? .white : .primary)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: ─── Computer Card ────────────────────────────────────────────────

    var computerCard: some View {
        Button { showComputerList = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 17))
                    .foregroundColor(isDark ? .white.opacity(0.7) : .secondary)
                Text(appState.selectedComputer?.name ?? L10n.t("no_computers"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDark ? .white : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 15)
            .background(card)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 10)
    }

    // MARK: ─── Settings Card ────────────────────────────────────────────────

    var settingsCard: some View {
        VStack(spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.25)) { showSettingsPane.toggle() } } label: {
                HStack(spacing: 12) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(theme.accentColor)
                    Text(L10n.t("settings"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDark ? .white : .primary)
                        .lineLimit(1)
                        .layoutPriority(1)
                    Spacer()
                    onlineIndicator
                    Image(systemName: showSettingsPane ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 6)
                }
                .padding(.horizontal, 16).padding(.vertical, 15)
            }
            .buttonStyle(PlainButtonStyle())

            if showSettingsPane, let c = appState.selectedComputer {
                Divider().background(Color.gray.opacity(0.15)).padding(.horizontal, 12)
                VStack(alignment: .leading, spacing: 10) {
                    infoRow(label: "IP",  value: "\(c.ip):\(c.port)")
                    infoRow(label: "MAC", value: c.normalisedMAC)
                    Button {
                        showSettingsPane = false
                        showAddComputer  = true
                    } label: {
                        Label(L10n.t("add_computer"), systemImage: "plus.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.accentColor)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(card)
    }

    func infoRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label + ":")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .leading)
            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(isDark ? .white.opacity(0.85) : .primary)
        }
    }

    var onlineIndicator: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(appState.isOnline ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: appState.isOnline ? .green.opacity(0.6) : .red.opacity(0.4), radius: 4)
            Text(L10n.t(appState.isOnline ? "online" : "offline"))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(appState.isOnline ? .green : .red)
                .lineLimit(1)
        }
    }

    // MARK: ─── Control Buttons ──────────────────────────────────────────────

    var controlButtons: some View {
        VStack(spacing: 12) {
            PowerButton(icon: "power",               label: L10n.t("turn_on"),  theme: theme) { wakeUp()         }
            PowerButton(icon: "power",               label: L10n.t("turn_off"), theme: theme,
                        longPress: { triggerDelayed(.shutdown) }) { perform(.shutdown) }
            PowerButton(icon: "arrow.clockwise",     label: L10n.t("restart"),  theme: theme,
                        longPress: { triggerDelayed(.restart)  }) { perform(.restart)  }
            PowerButton(icon: "moon.zzz.fill",       label: L10n.t("sleep"),    theme: theme) { perform(.sleep)   }
        }
    }

    var hintText: some View {
        Text(L10n.t("hold_hint"))
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }

    // MARK: ─── Volume ───────────────────────────────────────────────────────

    var volumeRow: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary).font(.system(size: 13))
                Slider(value: $volume)
                    .accentColor(theme.accentColor)
                    .onChange(of: volume) { v in
                        Task { try? await agentService?.setVolume(Int(v * 100)) }
                    }
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary).font(.system(size: 13))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(card)

            Text("\(Int(volume * 100))%")
                .font(.system(size: 12)).foregroundColor(.secondary)
        }
    }

    // MARK: ─── Sound Toggle ─────────────────────────────────────────────────

    var soundButton: some View {
        Button {
            soundOn.toggle()
            Task { try? await agentService?.setVolume(soundOn ? Int(volume * 100) : 0) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 17, weight: .semibold))
                Text(L10n.t(soundOn ? "sound_on" : "sound_off"))
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .background(
                soundOn
                    ? theme.gradient
                    : LinearGradient(colors: [.gray.opacity(0.6), .gray], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(18)
            .shadow(color: theme.accentColor.opacity(soundOn ? 0.35 : 0), radius: 10, y: 4)
        }
    }

    // MARK: ─── Footer ───────────────────────────────────────────────────────

    var footerNote: some View {
        VStack(spacing: 4) {
            Text(L10n.t("network_note"))
            Text(L10n.t("developer"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .font(.system(size: 12))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.top, 6)
    }

    // MARK: ─── Empty State ──────────────────────────────────────────────────

    var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "desktopcomputer.trianglebadge.exclamationmark")
                .font(.system(size: 54))
                .foregroundStyle(theme.accentColor.opacity(0.45))
            Text(L10n.t("no_computers"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isDark ? .white : .primary)
            Text(L10n.t("add_first"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Button { showAddComputer = true } label: {
                Label(L10n.t("add_computer"), systemImage: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28).padding(.vertical, 13)
                    .background(theme.gradient)
                    .cornerRadius(14)
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .background(card)
        .padding(.top, 16)
    }

    // MARK: ─── Toast ────────────────────────────────────────────────────────

    func toastBanner(_ msg: String) -> some View {
        VStack {
            Spacer()
            Text(msg)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(
                    Capsule().fill(Color.black.opacity(0.8))
                        .shadow(radius: 10)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 30)
        }
        .animation(.spring(response: 0.4), value: appState.toastMessage)
        .allowsHitTesting(false)
        .zIndex(999)
    }

    // MARK: ─── Delay Sheet ──────────────────────────────────────────────────

    var delaySheet: some View {
        DelayPickerView(theme: theme) { seconds in
            showDelaySheet = false
            if let action = pendingAction {
                performWithDelay(action, delay: seconds)
            }
        }
    }

    // MARK: ─── Sheets (child views) ─────────────────────────────────────────

    var addComputerSheet: some View {
        AddComputerView { c in
            appState.addComputer(c)
            showAddComputer = false
            rebuildService()
        }
        .environmentObject(appState)
    }

    var themePickerSheet: some View {
        ThemePickerView()
            .environmentObject(appState)
    }

    var langPickerSheet: some View {
        LanguagePickerView()
            .environmentObject(appState)
    }

    var computerListSheet: some View {
        ComputerListView()
            .environmentObject(appState)
    }

    // MARK: ─── Helpers ──────────────────────────────────────────────────────

    var card: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(isDark ? theme.cardColor : Color.white)
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.06), radius: 8, y: 2)
    }

    func syncFromState() {
        L10n.language = appState.settings.language
        volume  = appState.settings.volume
        soundOn = appState.settings.soundEnabled
        rebuildService()
    }

    func rebuildService() {
        guard let c = appState.selectedComputer else { agentService = nil; return }
        agentService = PCAgentService(computer: c)
    }

    func startPolling() {
        pollTask?.cancel()
        guard agentService != nil else { return }
        pollTask = Task {
            while !Task.isCancelled {
                let online = await agentService?.ping() ?? false
                await MainActor.run { appState.isOnline = online }
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 s
            }
        }
    }

    // MARK: ─── Actions ──────────────────────────────────────────────────────

    func wakeUp() {
        guard let c = appState.selectedComputer else { return }
        haptic(.medium)
        WakeOnLANService.wake(mac: c.normalisedMAC) { result in
            switch result {
            case .success: appState.showToast(L10n.t("wol_sent"))
            case .failure: appState.showToast(L10n.t("wol_fail"))
            }
        }
    }

    func perform(_ action: PowerAction) {
        haptic(.medium)
        Task {
            do {
                switch action {
                case .shutdown: try await agentService?.shutdown()
                case .restart:  try await agentService?.restart()
                case .sleep:    try await agentService?.sleep()
                case .hibernate:try await agentService?.hibernate()
                }
                await MainActor.run { appState.isOnline = false }
            } catch {
                await MainActor.run { appState.showToast(error.localizedDescription) }
            }
        }
    }

    func triggerDelayed(_ action: PowerAction) {
        pendingAction   = action
        showDelaySheet  = true
        haptic(.heavy)
    }

    func performWithDelay(_ action: PowerAction, delay: Int) {
        haptic(.medium)
        Task {
            do {
                switch action {
                case .shutdown: try await agentService?.shutdown(delay: delay)
                case .restart:  try await agentService?.restart(delay: delay)
                default:        break
                }
                await MainActor.run {
                    appState.showToast("\(delay)s")
                }
            } catch {
                await MainActor.run { appState.showToast(error.localizedDescription) }
            }
        }
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard appState.settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Power Actions Enum

enum PowerAction { case shutdown, restart, sleep, hibernate }
