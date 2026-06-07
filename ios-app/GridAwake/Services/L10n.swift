import Foundation

// MARK: - L10n

/// Centralised localisation helper — no .strings files needed,
/// all translations are embedded in the dictionary below.
enum L10n {
    static var language: AppLanguage = .uk

    static func t(_ key: String) -> String {
        strings[language]?[key] ?? strings[.en]?[key] ?? key
    }

    // MARK: - Strings table

    static let strings: [AppLanguage: [String: String]] = [

        // ───────────────────── UKRAINIAN ─────────────────────
        .uk: [
            "app_name":        "GridAwake",
            "my_computers":    "Мої комп'ютери",
            "settings":        "Налаштування",
            "help":            "Допомога",
            "themes":          "Теми",
            "language":        "Мова",

            "turn_on":         "Увімкнути",
            "turn_off":        "Вимкнути",
            "restart":         "Перезавантажити",
            "sleep":           "Сплячий режим",
            "hibernate":       "Гібернація",
            "lock":            "Заблокувати",
            "cancel_action":   "Скасувати дію",

            "sound_on":        "Звук увімкнено",
            "sound_off":       "Звук вимкнено",
            "volume":          "Гучність",

            "network_note":    "ПК та iPhone мають бути в одній мережі",
            "hold_hint":       "* Утримуйте кнопку для відкладеної дії",
            "wol_sent":        "Magic Packet відправлено ✓",
            "wol_fail":        "Помилка WoL — перевірте MAC адресу",

            "add_computer":    "Додати комп'ютер",
            "scan_qr":         "Сканувати QR",
            "manual_setup":    "Ручне налаштування",
            "computer_name":   "Назва комп'ютера",
            "ip_address":      "IP адреса",
            "port":            "Порт",
            "mac_address":     "MAC адреса",
            "password":        "Пароль (необов'язково)",
            "save":            "Зберегти",
            "done":            "Готово",
            "cancel_btn":      "Скасувати",
            "delete":          "Видалити",

            "no_computers":    "Немає комп'ютерів",
            "add_first":       "Додайте перший комп'ютер",

            "online":          "Онлайн",
            "offline":         "Офлайн",
            "connecting":      "Підключення…",

            "current_theme":   "Поточна тема",
            "choose_theme":    "Вибір теми",
            "choose_language": "Вибір мови",

            "theme_ocean":     "Океан",
            "theme_midnight":  "Опівніч",
            "theme_cyberpunk": "Cyberpunk",
            "theme_fire":      "Вогонь",
            "theme_forest":    "Ліс",
            "theme_sakura":    "Сакура",

            "confirm":         "Підтвердити",
            "confirm_off":     "Вимкнути комп'ютер?",
            "confirm_restart": "Перезавантажити комп'ютер?",
            "delayed_action":  "Відкладена дія",
            "delay_seconds":   "Затримка (секунди)",
        ],

        // ───────────────────── RUSSIAN ─────────────────────
        .ru: [
            "app_name":        "GridAwake",
            "my_computers":    "Мои компьютеры",
            "settings":        "Настройки",
            "help":            "Помощь",
            "themes":          "Темы",
            "language":        "Язык",

            "turn_on":         "Включить",
            "turn_off":        "Выключить",
            "restart":         "Перезагрузить",
            "sleep":           "Спящий режим",
            "hibernate":       "Гибернация",
            "lock":            "Заблокировать",
            "cancel_action":   "Отменить действие",

            "sound_on":        "Звук включён",
            "sound_off":       "Звук выключен",
            "volume":          "Громкость",

            "network_note":    "ПК и iPhone должны быть в одной сети",
            "hold_hint":       "* Удерживайте кнопку для отложенного действия",
            "wol_sent":        "Magic Packet отправлен ✓",
            "wol_fail":        "Ошибка WoL — проверьте MAC адрес",

            "add_computer":    "Добавить компьютер",
            "scan_qr":         "Сканировать QR",
            "manual_setup":    "Ручная настройка",
            "computer_name":   "Имя компьютера",
            "ip_address":      "IP адрес",
            "port":            "Порт",
            "mac_address":     "MAC адрес",
            "password":        "Пароль (необязательно)",
            "save":            "Сохранить",
            "done":            "Готово",
            "cancel_btn":      "Отмена",
            "delete":          "Удалить",

            "no_computers":    "Нет компьютеров",
            "add_first":       "Добавьте первый компьютер",

            "online":          "Онлайн",
            "offline":         "Офлайн",
            "connecting":      "Подключение…",

            "current_theme":   "Текущая тема",
            "choose_theme":    "Выбор темы",
            "choose_language": "Выбор языка",

            "theme_ocean":     "Океан",
            "theme_midnight":  "Полночь",
            "theme_cyberpunk": "Cyberpunk",
            "theme_fire":      "Огонь",
            "theme_forest":    "Лес",
            "theme_sakura":    "Сакура",

            "confirm":         "Подтвердить",
            "confirm_off":     "Выключить компьютер?",
            "confirm_restart": "Перезагрузить компьютер?",
            "delayed_action":  "Отложенное действие",
            "delay_seconds":   "Задержка (секунды)",
        ],

        // ───────────────────── ENGLISH ─────────────────────
        .en: [
            "app_name":        "GridAwake",
            "my_computers":    "My Computers",
            "settings":        "Settings",
            "help":            "Help",
            "themes":          "Themes",
            "language":        "Language",

            "turn_on":         "Wake Up",
            "turn_off":        "Shut Down",
            "restart":         "Restart",
            "sleep":           "Sleep",
            "hibernate":       "Hibernate",
            "lock":            "Lock Screen",
            "cancel_action":   "Cancel Action",

            "sound_on":        "Sound On",
            "sound_off":       "Sound Off",
            "volume":          "Volume",

            "network_note":    "PC and iPhone must be on the same network",
            "hold_hint":       "* Hold button for delayed action",
            "wol_sent":        "Magic Packet sent ✓",
            "wol_fail":        "WoL error — check MAC address",

            "add_computer":    "Add Computer",
            "scan_qr":         "Scan QR Code",
            "manual_setup":    "Manual Setup",
            "computer_name":   "Computer Name",
            "ip_address":      "IP Address",
            "port":            "Port",
            "mac_address":     "MAC Address",
            "password":        "Password (optional)",
            "save":            "Save",
            "done":            "Done",
            "cancel_btn":      "Cancel",
            "delete":          "Delete",

            "no_computers":    "No Computers",
            "add_first":       "Add your first computer",

            "online":          "Online",
            "offline":         "Offline",
            "connecting":      "Connecting…",

            "current_theme":   "Current theme",
            "choose_theme":    "Choose Theme",
            "choose_language": "Choose Language",

            "theme_ocean":     "Ocean",
            "theme_midnight":  "Midnight",
            "theme_cyberpunk": "Cyberpunk",
            "theme_fire":      "Fire",
            "theme_forest":    "Forest",
            "theme_sakura":    "Sakura",

            "confirm":         "Confirm",
            "confirm_off":     "Shut down this computer?",
            "confirm_restart": "Restart this computer?",
            "delayed_action":  "Delayed Action",
            "delay_seconds":   "Delay (seconds)",
        ],
    ]
}
