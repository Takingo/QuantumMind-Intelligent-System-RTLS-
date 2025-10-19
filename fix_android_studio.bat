@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║        Fix Android Studio Errors - Clean Cache           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo This will clean all Flutter/Dart caches and rebuild.
echo.
pause

echo [1/5] Cleaning Flutter build cache...
flutter clean
if %errorlevel% neq 0 (
    echo ⚠️  Flutter clean failed (Flutter might not be installed yet)
    echo    This is OK if you haven't installed Flutter
) else (
    echo ✅ Flutter cache cleaned
)

echo.
echo [2/5] Removing .dart_tool folder...
if exist ".dart_tool" (
    rmdir /s /q .dart_tool
    echo ✅ .dart_tool removed
) else (
    echo ℹ️  .dart_tool folder not found
)

echo.
echo [3/5] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ⚠️  Flutter pub get failed
) else (
    echo ✅ Dependencies fetched
)

echo.
echo [4/5] Verifying theme file...
findstr /C:"CardThemeData" lib\theme\theme_config.dart >nul
if %errorlevel% equ 0 (
    echo ✅ theme_config.dart is correct (using CardThemeData)
) else (
    echo ❌ theme_config.dart might have issues
)

echo.
echo [5/5] Instructions for Android Studio...
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                Android Studio Next Steps                  ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 1. Open Android Studio
echo 2. File → Invalidate Caches / Restart
echo 3. Click "Invalidate and Restart"
echo 4. Wait for Android Studio to reindex
echo 5. Try building again
echo.
echo If errors persist:
echo - Close Android Studio completely
echo - Run this script again
echo - Reopen Android Studio
echo.
pause
