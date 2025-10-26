@echo off
echo ========================================
echo  RTLS Map - Quick Test Script
echo ========================================
echo.
echo This script will:
echo 1. Clean Flutter build
echo 2. Get dependencies
echo 3. Run on your device
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak > nul

echo.
echo [1/3] Cleaning Flutter build...
flutter clean

echo.
echo [2/3] Getting dependencies...
flutter pub get

echo.
echo [3/3] Running on device...
echo.
echo ** Make sure your device is connected! **
echo.
flutter run -d android

echo.
echo ========================================
echo  Test Complete!
echo ========================================
pause
