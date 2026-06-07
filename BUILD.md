# GridAwake — Инструкция по сборке

> **Wake-on-LAN система**: включение ПК через iPhone, выключение/перезагрузка/сон через PC-агент.

---

## 📐 Архитектура

```
iPhone App (SwiftUI)
    │
    ├── WakeOnLAN (UDP broadcast → порт 9)     ← Включение ПК
    │       MAC-адрес нужен для этого
    │
    └── HTTP REST → PC Agent (Flask :7070)      ← Выключение, перезагрузка, сон, громкость
            │
            └── Выполняет системные команды Windows
```

**Требование:** iPhone и ПК должны быть в **одной Wi-Fi сети** (WoL через мобильный интернет требует настройки роутера — переброс портов).

---

## 🖥️ PC Agent (Windows)

### Требования
- Windows 10 / 11
- Python 3.10 или новее

### Шаг 1 — Установка Python

Скачайте с python.org/downloads.
При установке **обязательно отметьте**: `Add Python to PATH`.

### Шаг 2 — Запуск агента (разработка)

```powershell
cd d:\GridAwake\pc-agent
pip install -r requirements.txt
python main.py
```

После запуска:
- В системном трее появится иконка ⚡ GridAwake
- Кликните правой кнопкой → Налаштування для настройки
- Там же будет QR-код для подключения iPhone

### Шаг 3 — Сборка .exe

```powershell
cd d:\GridAwake\pc-agent
.\build.bat
```

Готовый файл: `dist\GridAwake\GridAwake.exe`

### Шаг 4 — Автозапуск с Windows

1. Правый клик на `GridAwake.exe` → Создать ярлык
2. Нажмите `Win+R`, введите: `shell:startup`
3. Скопируйте ярлык в открывшуюся папку

### Шаг 5 — Настройка брандмауэра

```powershell
# Запустить от администратора:
netsh advfirewall firewall add rule name="GridAwake" dir=in action=allow protocol=TCP localport=7070
```

---

## 📱 iPhone App (iOS)

### Требования
- Mac с macOS Ventura 13+
- Xcode 15 или новее (Mac App Store)
- iPhone с iOS 16+
- Бесплатный Apple ID

### Шаг 1 — Создать Xcode проект

1. Xcode → **Create New Project** → **iOS** → **App**
2. Настройки:
   - Product Name: `GridAwake`
   - Organization Identifier: `com.yourname`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployments: iOS 16.0
3. Сохраните проект

### Шаг 2 — Добавить исходные файлы

Перетащите все `.swift` файлы из `ios-app/GridAwake/` в Xcode:

```
GridAwakeApp.swift
AppState.swift
Models/Computer.swift
Models/AppTheme.swift
Models/AppSettings.swift
Services/L10n.swift
Services/WakeOnLANService.swift
Services/PCAgentService.swift
Views/MainView.swift
Views/PowerButton.swift
Views/ThemePickerView.swift
Views/LanguagePickerView.swift
Views/ComputerListView.swift
Views/AddComputerView.swift
Views/QRScannerView.swift
Views/DelayPickerView.swift
```

В Xcode: **File → Add Files to "GridAwake"** → выбрать все файлы.

### Шаг 3 — Настроить Info.plist

Добавьте в `Info.plist`:

| Key | Value |
|-----|-------|
| NSCameraUsageDescription | GridAwake uses camera to scan QR codes |
| NSLocalNetworkUsageDescription | GridAwake needs local network for WoL and PC agent |
| NSAllowsLocalNetworking | YES (в блоке NSAppTransportSecurity) |

Используйте файл `ios-app/GridAwake/Info.plist` из проекта — он уже содержит все нужные ключи.

### Шаг 4 — Запуск на iPhone

1. Подключите iPhone к Mac кабелем
2. В Xcode выберите устройство в верхней панели
3. **Signing & Capabilities** → выберите Team (ваш Apple ID)
4. Нажмите ▶ (Run)
5. На iPhone: Настройки → Основные → VPN и управление устройством → **Доверять**

---

## ⚙️ Wake-on-LAN — Настройка BIOS

1. Войдите в BIOS (Del / F2 / F12 при старте ПК)
2. Найдите: **Power Management** или **Advanced**
3. Включите: **Wake on LAN**, **Power On By PCI-E**, **Resume by LAN**
4. Сохраните и выйдите (F10)

В Windows:
1. Диспетчер устройств → Сетевые адаптеры → ваша карта
2. Свойства → **Управление электропитанием**
3. Отметить: "Разрешить этому устройству выводить компьютер из ждущего режима"

---

## 🔌 API Reference (PC Agent)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/ping` | Проверка соединения |
| GET | `/api/status` | Статус, громкость, MAC |
| GET | `/api/qr` | QR код (base64 PNG) |
| POST | `/api/shutdown` | Выключение `{"delay": 0}` |
| POST | `/api/restart` | Перезагрузка `{"delay": 0}` |
| POST | `/api/sleep` | Режим сна |
| POST | `/api/hibernate` | Гибернация |
| POST | `/api/lock` | Блокировка экрана |
| POST | `/api/cancel` | Отменить действие |
| POST | `/api/volume` | Громкость `{"level": 75}` |

Аутентификация (если задан пароль):
```
X-GridAwake-Secret: ваш_пароль
```

---

## 🛠️ Устранение неполадок

### ПК не включается (WoL)
- Проверить BIOS настройки
- ПК должен быть выключен (не гибернация)
- Проверить MAC-адрес

### iPhone не видит ПК (offline)
- Оба устройства в одной Wi-Fi сети?
- Брандмауэр разрешает порт 7070?
- Агент запущен?
- Тест в браузере iPhone: `http://IP_ПК:7070/api/ping`

### Ошибка Signing в Xcode
- Xcode → Preferences → Accounts → добавить Apple ID
- В проекте → Signing & Capabilities → выбрать Team

---

## 📁 Структура проекта

```
GridAwake/
├── pc-agent/               # Windows агент (Python + Flask)
│   ├── main.py             # Точка входа
│   ├── server.py           # REST API
│   ├── system_ops.py       # Системные команды
│   ├── tray_app.py         # Трей + настройки
│   ├── qr_utils.py         # QR код
│   ├── config.py           # Конфигурация
│   ├── requirements.txt
│   ├── build.bat           # Сборка .exe
│   └── GridAwake.spec      # PyInstaller
│
└── ios-app/GridAwake/      # Swift/SwiftUI
    ├── GridAwakeApp.swift
    ├── AppState.swift
    ├── Info.plist
    ├── Models/
    ├── Services/
    └── Views/
```
