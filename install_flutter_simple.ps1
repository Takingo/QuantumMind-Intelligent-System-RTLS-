# QuantumMind RTLS - One-Click Flutter Installer
# Run this script as Administrator

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     QuantumMind RTLS - Flutter Auto Installer            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run:" -ForegroundColor Yellow
    Write-Host "  cd 'C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking'" -ForegroundColor White
    Write-Host "  .\install_flutter_simple.ps1" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Check if Flutter already exists
if (Test-Path "C:\flutter\bin\flutter.bat") {
    Write-Host "✅ Flutter is already installed at C:\flutter" -ForegroundColor Green
    Write-Host ""
    & "C:\flutter\bin\flutter.bat" --version
    Write-Host ""
    Write-Host "Skipping download..." -ForegroundColor Yellow
} else {
    Write-Host "📥 [1/4] Downloading Flutter SDK (3.16.5 stable)..." -ForegroundColor Cyan
    Write-Host "    This may take 5-10 minutes depending on your internet speed..." -ForegroundColor Gray
    
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"
    $downloadPath = "$env:USERPROFILE\Downloads\flutter_windows_3.16.5-stable.zip"
    
    try {
        Invoke-WebRequest -Uri $flutterUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "    ✅ Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ Download failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        pause
        exit 1
    }
    
    Write-Host ""
    Write-Host "📦 [2/4] Extracting Flutter SDK to C:\flutter..." -ForegroundColor Cyan
    
    try {
        Expand-Archive -Path $downloadPath -DestinationPath "C:\" -Force
        Write-Host "    ✅ Extraction complete!" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ Extraction failed: $_" -ForegroundColor Red
        pause
        exit 1
    }
}

Write-Host ""
Write-Host "🔧 [3/4] Adding Flutter to system PATH..." -ForegroundColor Cyan

$flutterPath = "C:\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

if ($currentPath -notlike "*$flutterPath*") {
    try {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$flutterPath", [EnvironmentVariableTarget]::Machine)
        $env:Path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
        Write-Host "    ✅ Flutter added to PATH!" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ Failed to add to PATH: $_" -ForegroundColor Red
        Write-Host "    Please add C:\flutter\bin to PATH manually" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ✅ Flutter already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 [4/4] Running Flutter Doctor..." -ForegroundColor Cyan
Write-Host ""

& "C:\flutter\bin\flutter.bat" doctor

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ INSTALLATION COMPLETE!                 ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. RESTART Android Studio (or this terminal)" -ForegroundColor White
Write-Host "  2. In Android Studio → File → Settings → Flutter" -ForegroundColor White
Write-Host "     Set Flutter SDK path to: C:\flutter" -ForegroundColor Yellow
Write-Host "  3. Open Terminal and run:" -ForegroundColor White
Write-Host "     flutter pub get" -ForegroundColor Yellow
Write-Host "  4. Connect your tablet via USB" -ForegroundColor White
Write-Host "  5. Click the green ▶️ Run button!" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: You MUST restart Android Studio for changes to take effect!" -ForegroundColor Red
Write-Host ""

pause
