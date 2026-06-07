@echo off
title GridAwake — Builder

echo.
echo  ======================================
echo     GridAwake PC Agent — Builder
echo  ======================================
echo.

:: Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found! Install Python 3.10+ and add it to PATH.
    pause & exit /b 1
)

echo [1/4] Installing dependencies...
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies.
    pause & exit /b 1
)

echo [2/4] Cleaning old builds...
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
if exist __pycache__ rmdir /s /q __pycache__

echo [3/4] Building .exe (this may take 1-3 minutes)...
pyinstaller --clean GridAwake.spec
if errorlevel 1 (
    echo [ERROR] PyInstaller build failed. Check GridAwake.spec
    pause & exit /b 1
)

echo [4/4] Done!
echo.
echo  Executable created at: dist\GridAwake\GridAwake.exe
echo.
echo  To run on Windows startup:
echo  1. Create a shortcut to GridAwake.exe
echo  2. Press Win+R, type "shell:startup" and press Enter
echo  3. Copy the shortcut into the opened folder
echo.
pause
