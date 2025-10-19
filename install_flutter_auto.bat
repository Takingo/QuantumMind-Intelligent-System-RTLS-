@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║     QuantumMind RTLS - Automatic Flutter Installer       ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo This script will:
echo  1. Download Flutter SDK (~700 MB)
echo  2. Extract to C:\flutter
echo  3. Add to system PATH
echo  4. Configure for Android development
echo  5. Detect your tablet
echo  6. Run the app on your device
echo.
echo ⏱️  Estimated time: 10-15 minutes (depending on internet speed)
echo.
set /p continue="Continue? (Y/N): "
if /i not "%continue%"=="Y" exit /b

echo.
echo [1/7] Checking if Flutter already exists...
if exist "C:\flutter\bin\flutter.bat" (
    echo ✅ Flutter already installed at C:\flutter
    goto :skip_download
)

echo.
echo [2/7] Downloading Flutter SDK...
echo Please wait, downloading ~700 MB...
echo.

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip' -OutFile '%TEMP%\flutter_sdk.zip'}"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Download failed!
    echo.
    echo Please download manually from:
    echo https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo ✅ Download complete!

echo.
echo [3/7] Extracting Flutter SDK to C:\flutter...
echo This may take a few minutes...
powershell -Command "Expand-Archive -Path '%TEMP%\flutter_sdk.zip' -DestinationPath 'C:\' -Force"

if %errorlevel% neq 0 (
    echo ❌ Extraction failed!
    pause
    exit /b 1
)

echo ✅ Extraction complete!

echo.
echo [4/7] Cleaning up temporary files...
del "%TEMP%\flutter_sdk.zip"

:skip_download

echo.
echo [5/7] Adding Flutter to system PATH...
powershell -Command "& {$currentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($currentPath -notlike '*C:\flutter\bin*') { [Environment]::SetEnvironmentVariable('Path', $currentPath + ';C:\flutter\bin', 'Machine'); Write-Host 'Added to PATH' } else { Write-Host 'Already in PATH' }}"

echo ✅ PATH configured!

echo.
echo [6/7] Running Flutter doctor...
echo This will check for any issues...
echo.
C:\flutter\bin\flutter.bat doctor

echo.
echo [7/7] Enabling web support...
C:\flutter\bin\flutter.bat config --enable-web

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║              ✅ Flutter Installation Complete!            ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 📱 Now let's check for your tablet...
echo.

C:\flutter\bin\flutter.bat devices

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                    Ready to Run!                          ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Your tablet should appear above.
echo.
echo Next steps:
echo  1. Close this window
echo  2. Open a NEW terminal (important for PATH update)
echo  3. Run: cd "c:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
echo  4. Run: run_device.bat
echo.
echo OR just double-click run_device.bat from the project folder!
echo.
pause
