@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║        QuantumMind RTLS - Automated Setup Script         ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Check if Flutter is installed
echo [1/5] Checking Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is NOT installed!
    echo.
    echo Please install Flutter first:
    echo 1. Download: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to PATH
    echo 4. Restart terminal and run this script again
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Flutter is installed
    flutter --version
)

echo.
echo [2/5] Enabling web support...
flutter config --enable-web

echo.
echo [3/5] Installing dependencies...
echo This may take a few minutes...
flutter pub get

if %errorlevel% neq 0 (
    echo.
    echo ❌ Failed to install dependencies!
    echo Try running: flutter pub get
    pause
    exit /b 1
)

echo.
echo ✅ Dependencies installed successfully!

echo.
echo [4/5] Checking for available devices...
flutter devices

echo.
echo [5/5] Setup complete! 🎉
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                    Ready to Run!                          ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Choose how to run your app:
echo.
echo   1. Web Browser (Chrome/Edge) - Recommended for quick start
echo   2. Windows Desktop App
echo   3. Show all devices
echo   4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo 🚀 Starting app in web browser...
    echo.
    start cmd /k "flutter run -d chrome"
) else if "%choice%"=="2" (
    echo.
    echo 🚀 Starting Windows desktop app...
    echo.
    start cmd /k "flutter run -d windows"
) else if "%choice%"=="3" (
    echo.
    flutter devices
    echo.
    pause
) else (
    echo.
    echo Goodbye! 👋
)

echo.
echo ℹ️  Note: Before logging in, configure Supabase in:
echo    lib\utils\constants.dart
echo.
pause
