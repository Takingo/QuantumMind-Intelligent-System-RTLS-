@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║      QuantumMind RTLS - Run on Real Device (Android)     ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

echo [Step 1] Checking Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter not found! Run setup.bat first.
    pause
    exit /b 1
)

echo ✅ Flutter found
echo.

echo [Step 2] Checking connected devices...
flutter devices

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                   Device Instructions                     ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo ANDROID:
echo   1. Enable Developer Options (tap Build Number 7 times)
echo   2. Enable USB Debugging
echo   3. Connect phone via USB
echo   4. Allow USB debugging popup on phone
echo.
echo iOS (macOS only):
echo   1. Trust computer on iPhone
echo   2. Ensure Xcode is installed
echo.
echo Then run this script again!
echo.
pause

echo.
echo Choose an option:
echo.
echo   1. Run on Android device
echo   2. Run on Android emulator
echo   3. Build APK file (for sharing)
echo   4. Show all devices
echo   5. Exit
echo.
set /p choice="Enter choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo 🚀 Running on Android device...
    echo.
    flutter run -d android
) else if "%choice%"=="2" (
    echo.
    echo 🚀 Running on Android emulator...
    echo.
    echo Make sure you started an emulator first!
    flutter run
) else if "%choice%"=="3" (
    echo.
    echo 🔨 Building APK file...
    echo This may take 5-10 minutes...
    echo.
    flutter build apk --release
    echo.
    if %errorlevel% equ 0 (
        echo ✅ APK built successfully!
        echo.
        echo Location: build\app\outputs\flutter-apk\app-release.apk
        echo.
        echo You can:
        echo - Copy this APK to your phone
        echo - Share it via email/USB
        echo - Install it directly
        echo.
        explorer build\app\outputs\flutter-apk
    )
) else if "%choice%"=="4" (
    flutter devices
    pause
)

echo.
echo ℹ️  Hot reload: Press 'r' while app is running
echo ℹ️  Hot restart: Press 'R' while app is running
echo ℹ️  Quit: Press 'q'
echo.
pause
