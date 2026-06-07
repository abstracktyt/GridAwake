@echo off
chcp 65001 >nul
title GridAwake — Builder

echo.
echo  ╔══════════════════════════════════╗
echo  ║   GridAwake PC Agent — Builder   ║
echo  ╚══════════════════════════════════╝
echo.

:: Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python не знайдено! Встановіть Python 3.10+ та додайте до PATH.
    pause & exit /b 1
)

echo [1/4] Встановлення залежностей...
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo [ERROR] Помилка встановлення залежностей.
    pause & exit /b 1
)

echo [2/4] Очищення старих збірок...
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
if exist __pycache__ rmdir /s /q __pycache__

echo [3/4] Збірка .exe (це займе 1-3 хвилини)...
pyinstaller --clean GridAwake.spec
if errorlevel 1 (
    echo [ERROR] Помилка PyInstaller. Перевірте GridAwake.spec
    pause & exit /b 1
)

echo [4/4] Готово!
echo.
echo  Файл: dist\GridAwake\GridAwake.exe
echo.
echo  Для автозапуску скопіюйте ярлик GridAwake.exe
echo  до папки: %%APPDATA%%\Microsoft\Windows\Start Menu\Programs\Startup
echo.
pause
