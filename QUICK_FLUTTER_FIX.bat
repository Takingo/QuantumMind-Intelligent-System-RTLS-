@echo off
echo ========================================
echo FLUTTER QUICK FIX - Son Cozum
echo ========================================
echo.

REM Eski Flutter'i sil
echo [1/4] Removing old Flutter...
if exist "C:\Users\posei\flutter" (
    rmdir /s /q "C:\Users\posei\flutter"
    echo Old Flutter removed
)

REM Yeni Flutter'i extract et
echo.
echo [2/4] Extracting Flutter 3.35.2...
powershell -Command "Expand-Archive -Path '%USERPROFILE%\Downloads\flutter_windows_3.35.2-stable.zip' -DestinationPath 'C:\Users\posei\' -Force"

REM Flutter'i C:\ dizinine tasi
echo.
echo [3/4] Moving Flutter to C:\...
if exist "C:\Users\posei\flutter" (
    move "C:\Users\posei\flutter" "C:\"
)

REM PATH'e ekle
echo.
echo [4/4] Adding to PATH...
setx PATH "%PATH%;C:\flutter\bin"

REM Test et
echo.
echo ========================================
echo Testing Flutter...
echo ========================================
C:\flutter\bin\flutter --version

echo.
echo ========================================
echo DONE! Now run:
echo   cd "C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
echo   flutter pub get
echo ========================================
pause
