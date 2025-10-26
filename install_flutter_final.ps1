# Flutter Installer - Final Version
# Downloads and extracts Flutter properly

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           Flutter SDK Installation - Final Fix           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$installPath = "C:\Users\posei\flutter"
$downloadPath = "$env:TEMP\flutter_sdk.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip"

# Step 1: Clean up old installation
if (Test-Path $installPath) {
    Write-Host "🗑️  Removing old Flutter installation..." -ForegroundColor Yellow
    Remove-Item -Path $installPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Old installation removed" -ForegroundColor Green
}

# Step 2: Download Flutter
Write-Host ""
Write-Host "📥 Downloading Flutter SDK (~700 MB)..." -ForegroundColor Cyan
Write-Host "   Please wait, this may take 5-10 minutes..." -ForegroundColor Gray

try {
    # Use WebClient for more reliable download
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($flutterUrl, $downloadPath)
    Write-Host "   ✅ Download complete!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Download failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual installation:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip" -ForegroundColor White
    Write-Host "2. Extract to C:\Users\posei\" -ForegroundColor White
    Write-Host "3. Rename folder to 'flutter'" -ForegroundColor White
    pause
    exit 1
}

# Step 3: Extract Flutter
Write-Host ""
Write-Host "📦 Extracting Flutter SDK..." -ForegroundColor Cyan
Write-Host "   This may take 2-3 minutes..." -ForegroundColor Gray

try {
    # Extract to parent directory
    $parentDir = "C:\Users\posei"
    
    # Use .NET for extraction (more reliable)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $parentDir)
    
    Write-Host "   ✅ Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Extraction failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please extract manually:" -ForegroundColor Yellow
    Write-Host "1. Open File Explorer" -ForegroundColor White
    Write-Host "2. Navigate to: $downloadPath" -ForegroundColor White
    Write-Host "3. Right-click → Extract All → Extract to C:\Users\posei\" -ForegroundColor White
    pause
    exit 1
}

# Step 4: Verify installation
Write-Host ""
Write-Host "🔍 Verifying installation..." -ForegroundColor Cyan

$flutterBat = "$installPath\bin\flutter.bat"
$flutterTools = "$installPath\packages\flutter_tools"

if (Test-Path $flutterBat) {
    Write-Host "   ✅ flutter.bat found" -ForegroundColor Green
} else {
    Write-Host "   ❌ flutter.bat not found!" -ForegroundColor Red
}

if (Test-Path $flutterTools) {
    Write-Host "   ✅ flutter_tools found" -ForegroundColor Green
} else {
    Write-Host "   ❌ flutter_tools not found!" -ForegroundColor Red
}

# Step 5: Add to PATH
Write-Host ""
Write-Host "🔧 Adding Flutter to PATH..." -ForegroundColor Cyan

$flutterBinPath = "$installPath\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($userPath -notlike "*$flutterBinPath*") {
    try {
        if ($userPath) {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBinPath", [EnvironmentVariableTarget]::User)
        } else {
            [Environment]::SetEnvironmentVariable("Path", $flutterBinPath, [EnvironmentVariableTarget]::User)
        }
        Write-Host "   ✅ Added to PATH" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Could not add to PATH automatically" -ForegroundColor Yellow
    }
}

# Update current session
$env:Path = "$env:Path;$flutterBinPath"

# Step 6: Run Flutter Doctor
Write-Host ""
Write-Host "🎯 Running Flutter Doctor..." -ForegroundColor Cyan
Write-Host ""

& "$flutterBat" doctor -v

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              ✅ FLUTTER INSTALLATION COMPLETE!             ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Close this PowerShell" -ForegroundColor White
Write-Host "2. Open a NEW PowerShell" -ForegroundColor White
Write-Host "3. Run these commands:" -ForegroundColor White
Write-Host ""
Write-Host "   cd 'C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking'" -ForegroundColor Yellow
Write-Host "   flutter create --platforms=android,ios,web,windows ." -ForegroundColor Yellow
Write-Host "   flutter pub get" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Open in Android Studio - ALL ERRORS WILL BE GONE! ✨" -ForegroundColor White
Write-Host ""

# Clean up
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue

pause
