# 📱 GridAwake iOS — Збірка через GitHub Actions

> Цей спосіб дозволяє зібрати `.ipa` файл **безкоштовно** на Mac-серверах GitHub, 
> а потім встановити його на iPhone через **Windows** за допомогою Sideloadly.

---

## Що потрібно

| Інструмент | Ціна | Посилання |
|-----------|------|-----------|
| GitHub аккаунт | Безкоштовно | [github.com](https://github.com) |
| Git для Windows | Безкоштовно | [git-scm.com](https://git-scm.com/download/win) |
| Sideloadly (Windows) | Безкоштовно | [sideloadly.io](https://sideloadly.io) |
| iTunes для Windows | Безкоштовно | [apple.com/itunes](https://www.apple.com/itunes/) |
| Apple ID | Безкоштовно | [appleid.apple.com](https://appleid.apple.com) |

---

## Крок 1 — Встановити Git

1. Скачайте [Git for Windows](https://git-scm.com/download/win)
2. Встановіть з налаштуваннями за замовчуванням
3. Перевірте: відкрийте PowerShell → `git --version`

---

## Крок 2 — Створити репозиторій на GitHub

1. Зайдіть на [github.com](https://github.com) → **Sign up** (якщо нема аккаунту)
2. Натисніть **"New repository"** (зелена кнопка)
3. Назва: `GridAwake`
4. Видимість: **Public** ← важливо (безлімітні хвилини для публічних репо)
   - або Private (але тоді 2000 хвилин/місяць, ~200 хв для macOS)
5. Натисніть **"Create repository"**

---

## Крок 3 — Завантажити код на GitHub

Відкрийте PowerShell від імені адміністратора:

```powershell
cd d:\GridAwake

# Ініціалізуємо Git репозиторій
git init

# Додаємо .gitignore щоб не заливати зайве
@"
# Python
__pycache__/
*.pyc
*.pyo
.env
venv/
dist/
build/
*.egg-info/
.Python

# Xcode
ios-app/*.xcodeproj
ios-app/*.xcworkspace
ios-app/DerivedData/
ios-app/.build/

# macOS
.DS_Store
*.swp

# Windows
Thumbs.db
desktop.ini

# Test files
pc-agent/test_check.py
"@ | Set-Content .gitignore

# Додаємо всі файли
git add .

# Перший комміт
git commit -m "Initial commit: GridAwake v1.0"

# Підключаємо GitHub репозиторій
# ⚠️ Замініть YOUR_USERNAME на ваш нікнейм GitHub
git remote add origin https://github.com/YOUR_USERNAME/GridAwake.git

# Завантажуємо
git branch -M main
git push -u origin main
```

> Якщо запитає логін — введіть ваш GitHub username та **Personal Access Token**  
> (не пароль! Токен: GitHub → Settings → Developer settings → Personal access tokens → Generate new token → обрати "repo")

---

## Крок 4 — Запустити збірку

### Автоматично (при push)
Workflow запускається **автоматично** щоразу як ви пушите зміни в `ios-app/`.

### Вручну
1. Відкрийте ваш репозиторій на GitHub
2. Вкладка **Actions**
3. Зліва виберіть **"📱 GridAwake iOS — Build IPA"**
4. Натисніть **"Run workflow"** → **"Run workflow"**

![GitHub Actions](https://docs.github.com/assets/cb-15210/mw-1440/images/help/repository/actions-tab.webp)

---

## Крок 5 — Завантажити .ipa файл

1. Вкладка **Actions** на GitHub
2. Клікніть на завершену збірку (зелена галочка ✅)
3. Прокрутіть вниз до розділу **"Artifacts"**
4. Натисніть **"GridAwake-iOS-build-N"** → завантажиться `.zip`
5. Розпакуйте → отримаєте `GridAwake.ipa`

> Файл зберігається **30 днів**. Потім потрібно зібрати знову.

---

## Крок 6 — Встановити на iPhone через Sideloadly

### Встановити інструменти
1. Скачайте та встановіть **iTunes** для Windows:  
   [apple.com/itunes](https://www.apple.com/itunes/) (або Microsoft Store)
2. Скачайте **Sideloadly**:  
   [sideloadly.io/#download](https://sideloadly.io/#download)

### Встановити додаток

1. Підключіть iPhone до ПК кабелем USB
2. На iPhone: **"Довіряти цьому комп'ютеру"**
3. Відкрийте **Sideloadly**
4. Перетягніть `GridAwake.ipa` у вікно Sideloadly (або кнопка IPA)
5. У полі **Apple Account**: введіть ваш Apple ID (email)
6. Введіть пароль Apple ID
7. Натисніть **"Start"**
8. Sideloadly підпише IPA вашим Apple ID і встановить на iPhone

### Довіряти сертифікату на iPhone
1. iPhone → **Настройки → Основне → VPN і керування пристроєм**
2. Знайдіть ваш Apple ID → **"Довіряти"**

---

## ⚠️ Важливі обмеження Sideloadly (безкоштовно)

| Обмеження | Безкоштовно | Apple Developer ($99/рік) |
|-----------|-------------|--------------------------|
| Додатків одночасно | 3 | необмежено |
| Термін дії | 7 днів | 1 рік |
| Потрібен ПК для оновлення | Так | Ні |

> **Кожні 7 днів** потрібно перевстановлювати через Sideloadly.  
> Sideloadly може робити це **автоматично** (якщо увімкнений та підключений iPhone).

---

## 🔄 Оновлення додатку

При змінах в коді:

```powershell
cd d:\GridAwake

# Зберегти зміни
git add .
git commit -m "Update: опис змін"
git push
```

GitHub Actions автоматично збере новий `.ipa` → завантажте → перевстановіть через Sideloadly.

---

## 🛠️ Якщо збірка провалилась (❌)

1. Вкладка **Actions** → клікніть на збірку → клікніть на крок з помилкою
2. Прочитайте лог помилки

**Часті помилки:**

| Помилка | Рішення |
|---------|---------|
| `No such module 'Network'` | Вже виправлено в project.yml — перевірте що він завантажений |
| `Xcode version not found` | Workflow автоматично обирає доступний Xcode |
| `xcodegen: command not found` | Homebrew не встановлений на runner — рідкість, спробуйте ще раз |
| `Build failed: compile error` | Помилка в Swift коді — перевірте лог |

---

## 📁 Структура файлів для GitHub Actions

```
GridAwake/                          ← корінь репозиторію
├── .github/
│   └── workflows/
│       └── build-ios.yml           ← ← ← WORKFLOW (цей файл запускає збірку)
├── ios-app/
│   ├── project.yml                 ← ← ← XcodeGen конфіг (замість .xcodeproj)
│   └── GridAwake/                  ← Swift вихідні файли
│       ├── GridAwakeApp.swift
│       ├── AppState.swift
│       ├── Info.plist
│       ├── Models/
│       ├── Services/
│       └── Views/
├── pc-agent/                       ← Python агент для Windows
└── BUILD.md
```

---

## 💡 Поради

**Для публічного репо:** хвилини необмежені — збирайте скільки завгодно.

**Для приватного репо:** у вас є 2000 хвилин/місяць безкоштовно.  
macOS runner = 10× — тобто ~200 хвилин macOS на місяць (~10 збірок по 20 хв).

**Перевірити використання:** GitHub → Settings → Billing → Actions

**Прискорити збірку:** можна кешувати DerivedData (але для початку не обов'язково).
