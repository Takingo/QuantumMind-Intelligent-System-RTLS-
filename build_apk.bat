@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║        QuantumMind RTLS - Build APK for Android          ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo This will create an APK file you can install on any Android phone.
echo.
echo Choose build type:
echo.
echo   1. Release APK (smaller, optimized) - Recommended
echo   2. Debug APK (larger, with debug info)
echo   3. Split APKs (smallest, separate files per CPU)
echo   4. Exit
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo 🔨 Building RELEASE APK...
    echo This will take 5-10 minutes on first build...
    echo.
    flutter build apk --release
    
    if %errorlevel% equ 0 (
        echo.
        echo ╔═══════════════════════════════════════════════════════════╗
        echo ║                  ✅ BUILD SUCCESSFUL!                     ║
        echo ╚═══════════════════════════════════════════════════════════╝
        echo.
        echo 📱 APK Location:
        echo    build\app\outputs\flutter-apk\app-release.apk
        echo.
        echo 📊 File size: ~20-30 MB
        echo.
        echo Next steps:
        echo  1. Copy APK to your phone (USB/Email/Drive)
        echo  2. Open APK file on phone
        echo  3. Allow installation from unknown sources
        echo  4. Install and enjoy!
        echo.
        echo Opening folder...
        explorer build\app\outputs\flutter-apk
    ) else (
        echo.
        echo ❌ Build failed! Check errors above.
    )
    
) else if "%choice%"=="2" (
    echo.
    echo 🔨 Building DEBUG APK...
    echo.
    flutter build apk --debug
    
    if %errorlevel% equ 0 (
        echo.
        echo ✅ Debug APK built!
        echo    build\app\outputs\flutter-apk\app-debug.apk
        echo.
        explorer build\app\outputs\flutter-apk
    )
    
) else if "%choice%"=="3" (
    echo.
    echo 🔨 Building SPLIT APKs...
    echo Creating separate APKs for different CPUs...
    echo.
    flutter build apk --split-per-abi --release
    
    if %errorlevel% equ 0 (
        echo.
        echo ✅ Split APKs built!
        echo.
        echo Files created:
        echo  - app-armeabi-v7a-release.apk (older phones)
        echo  - app-arm64-v8a-release.apk (modern phones) ⭐ RECOMMENDED
        echo  - app-x86_64-release.apk (emulators)
        echo.
        echo 💡 Tip: Use arm64-v8a for most modern phones!
        echo    It's smaller (~15 MB) and optimized.
        echo.
        explorer build\app\outputs\flutter-apk
    )
)

echo.
pause
