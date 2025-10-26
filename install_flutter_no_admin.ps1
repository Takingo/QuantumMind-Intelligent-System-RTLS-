# QuantumMind RTLS - Flutter Installer (No Admin Required)
# This version installs Flutter without modifying system PATH

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     QuantumMind RTLS - Flutter Installer (User Mode)    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Install to user directory instead of C:\flutter
$installPath = "$env:USERPROFILE\flutter"
$downloadPath = "$env:USERPROFILE\Downloads\flutter_windows_3.16.5-stable.zip"

Write-Host "Installation Details:" -ForegroundColor Yellow
Write-Host "  Install Location: $installPath" -ForegroundColor White
Write-Host "  Download Size: ~700 MB" -ForegroundColor White
Write-Host "  Estimated Time: 5-10 minutes" -ForegroundColor White
Write-Host ""

# Step 1: Check if Flutter already exists
if (Test-Path "$installPath\bin\flutter.bat") {
    Write-Host "✅ Flutter is already installed at $installPath" -ForegroundColor Green
    Write-Host ""
    & "$installPath\bin\flutter.bat" --version
    Write-Host ""
    Write-Host "Skipping download..." -ForegroundColor Yellow
} else {
    Write-Host "📥 [1/3] Downloading Flutter SDK..." -ForegroundColor Cyan
    
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"
    
    try {
        # Show progress
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $flutterUrl -OutFile $downloadPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        Write-Host "    ✅ Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ Download failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download manually from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        pause
        exit 1
    }
    
    Write-Host ""
    Write-Host "📦 [2/3] Extracting Flutter SDK..." -ForegroundColor Cyan
    
    try {
        # Create parent directory if it doesn't exist
        $parentDir = Split-Path -Parent $installPath
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        
        Expand-Archive -Path $downloadPath -DestinationPath $parentDir -Force
        Write-Host "    ✅ Extraction complete!" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ Extraction failed: $_" -ForegroundColor Red
        pause
        exit 1
    }
}

Write-Host ""
Write-Host "🔧 [3/3] Configuring Flutter..." -ForegroundColor Cyan

# Add to USER Path (doesn't require admin)
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
$flutterBinPath = "$installPath\bin"

if ($userPath -notlike "*$flutterBinPath*") {
    try {
        if ($userPath) {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBinPath", [EnvironmentVariableTarget]::User)
        } else {
            [Environment]::SetEnvironmentVariable("Path", $flutterBinPath, [EnvironmentVariableTarget]::User)
        }
        $env:Path = "$env:Path;$flutterBinPath"
        Write-Host "    ✅ Flutter added to USER PATH!" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠️  Could not add to PATH automatically" -ForegroundColor Yellow
        Write-Host "    You'll need to use full path: $flutterBinPath\flutter.bat" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ✅ Flutter already in PATH" -ForegroundColor Green
}

# Update current session PATH
$env:Path = "$env:Path;$flutterBinPath"

Write-Host ""
Write-Host "🎯 Running Flutter Doctor..." -ForegroundColor Cyan
Write-Host ""

& "$installPath\bin\flutter.bat" doctor

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ INSTALLATION COMPLETE!                 ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Flutter installed to: $installPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Close this PowerShell window" -ForegroundColor White
Write-Host "  2. Open a NEW PowerShell window (normal, not admin)" -ForegroundColor White
Write-Host "  3. Test Flutter:" -ForegroundColor White
Write-Host "     flutter --version" -ForegroundColor Yellow
Write-Host "  4. Navigate to project:" -ForegroundColor White
Write-Host "     cd 'C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking'" -ForegroundColor Yellow
Write-Host "  5. Generate platform files:" -ForegroundColor White
Write-Host "     flutter create --platforms=android,ios,web,windows ." -ForegroundColor Yellow
Write-Host "  6. Install dependencies:" -ForegroundColor White
Write-Host "     flutter pub get" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANT: Close and reopen PowerShell/Android Studio for PATH changes!" -ForegroundColor Red
Write-Host ""

pause
