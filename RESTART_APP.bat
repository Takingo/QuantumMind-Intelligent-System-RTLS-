@echo off
echo ========================================
echo QUANTUMMIND RTLS - CLEAN RESTART
echo ========================================
echo.

echo [1/4] Stopping current app...
adb shell am force-stop com.example.quantummind_rtls
timeout /t 2 >nul

echo [2/4] Cleaning Flutter build...
call flutter clean
echo.

echo [3/4] Getting dependencies...
call flutter pub get
echo.

echo [4/4] Running app on device...
call flutter run -d android

echo.
echo Done!
pause
