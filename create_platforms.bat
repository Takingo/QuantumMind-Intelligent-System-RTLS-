@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║     Creating Platform Files for All Platforms            ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

echo [1/5] Checking Flutter installation...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter not found!
    echo Please install Flutter first or run install_flutter_auto.bat
    pause
    exit /b 1
)
echo ✅ Flutter found

echo.
echo [2/5] Creating Android platform files...
flutter create --platforms=android .
if %errorlevel% equ 0 (
    echo ✅ Android platform created
) else (
    echo ⚠️  Android platform already exists or error occurred
)

echo.
echo [3/5] Creating iOS platform files...
flutter create --platforms=ios .
if %errorlevel% equ 0 (
    echo ✅ iOS platform created
) else (
    echo ⚠️  iOS platform already exists or error occurred
)

echo.
echo [4/5] Creating Web platform files...
flutter create --platforms=web .
if %errorlevel% equ 0 (
    echo ✅ Web platform created
) else (
    echo ⚠️  Web platform already exists or error occurred
)

echo.
echo [5/5] Creating Windows platform files...
flutter create --platforms=windows .
if %errorlevel% equ 0 (
    echo ✅ Windows platform created
) else (
    echo ⚠️  Windows platform already exists or error occurred
)

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║              ✅ Platform Setup Complete!                 ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Created platform folders:
echo  📱 android/     - Android app files
echo  🍎 ios/         - iOS app files (requires macOS to build)
echo  🌐 web/         - Web app files
echo  💻 windows/     - Windows desktop files
echo.
echo Next steps:
echo  1. Install dependencies: flutter pub get
echo  2. Run on device: flutter run -d android
echo  3. Or use Android Studio: Open project and click Run
echo.
pause
