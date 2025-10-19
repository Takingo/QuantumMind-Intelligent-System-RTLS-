# 🖥️ Terminal Guide - QuantumMind RTLS

## 🚀 Quick Start from Terminal

### Method 1: Automated Setup (Easiest) ⭐

Just double-click or run:
```bash
setup.bat
```

This will:
1. ✅ Check Flutter installation
2. ✅ Enable web support
3. ✅ Install all dependencies
4. ✅ Show available devices
5. ✅ Let you choose how to run the app

---

### Method 2: Manual Commands

#### Step 1: Install Dependencies
```bash
cd "c:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
flutter pub get
```

#### Step 2: Run the App

**Web Browser (Recommended):**
```bash
flutter run -d chrome
```
or just run:
```bash
run_web.bat
```

**Windows Desktop:**
```bash
flutter run -d windows
```
or just run:
```bash
run_windows.bat
```

**Android (if emulator running):**
```bash
flutter run -d android
```

**Show all available devices:**
```bash
flutter devices
```

---

## 🔧 Available Batch Scripts

| Script | Description | Command |
|--------|-------------|---------|
| **setup.bat** | Complete automated setup | Double-click or `setup.bat` |
| **run_web.bat** | Run in Chrome/Edge | Double-click or `run_web.bat` |
| **run_windows.bat** | Run as Windows desktop app | Double-click or `run_windows.bat` |
| **build_web.bat** | Build for production (web) | Double-click or `build_web.bat` |

---

## 📋 Common Terminal Commands

### Development Commands

```bash
# Check Flutter installation
flutter doctor

# Show Flutter version
flutter --version

# List available devices
flutter devices

# Clean build cache
flutter clean

# Update dependencies
flutter pub get

# Update Flutter SDK
flutter upgrade

# Run with hot reload (automatic)
flutter run

# Run in specific device
flutter run -d chrome
flutter run -d windows
flutter run -d edge

# Run in release mode (faster)
flutter run --release -d chrome
```

### Build Commands

```bash
# Build web app (production)
flutter build web --release

# Build Windows app
flutter build windows --release

# Build Android APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

### Debugging Commands

```bash
# Run with verbose logging
flutter run -v

# Run with debug info
flutter run --debug

# Check for errors
flutter analyze

# Format code
flutter format .
```

---

## 🎯 Complete Setup from Scratch

If Flutter is **NOT installed**, follow these steps:

### 1. Download Flutter SDK

**PowerShell:**
```powershell
# Download Flutter SDK (stable)
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter.zip"

# Extract to C:\flutter
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter.zip" -DestinationPath "C:\"
```

**Or download manually:**
https://docs.flutter.dev/get-started/install/windows

### 2. Add to PATH

**PowerShell (Run as Administrator):**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", [System.EnvironmentVariableTarget]::Machine)
```

**Or manually:**
1. Win + R → `sysdm.cpl` → Advanced → Environment Variables
2. Edit Path → New → Add: `C:\flutter\bin`

### 3. Restart Terminal and Verify

```bash
flutter doctor
```

### 4. Run Setup Script

```bash
cd "c:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
setup.bat
```

---

## 🌐 Accessing the App

After running `flutter run -d chrome`, the app will open at:

```
http://localhost:XXXXX
```

(Port number will be shown in terminal)

**Hot Reload:** Press `r` in terminal to reload
**Hot Restart:** Press `R` in terminal to restart
**Quit:** Press `q` in terminal

---

## ⚙️ Configuration

### Before first run, configure Supabase:

Edit: `lib\utils\constants.dart`

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**Get credentials from:**
https://app.supabase.com → Your Project → Settings → API

---

## 🐛 Troubleshooting

### "Flutter not found"
```bash
# Check PATH
echo %PATH%

# Verify flutter.bat exists
dir C:\flutter\bin\flutter.bat

# Restart terminal
```

### "No devices found"
```bash
# Enable web support
flutter config --enable-web

# Check Chrome installation
where chrome

# List all devices
flutter devices
```

### "Dependencies error"
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

### "Build failed"
```bash
# Update Flutter
flutter upgrade

# Doctor check
flutter doctor -v
```

---

## 💡 Pro Tips

### Run in background
```bash
start cmd /k "flutter run -d chrome"
```

### Watch for changes (hot reload enabled by default)
Just save your files, Flutter will auto-reload!

### Run multiple instances
```bash
# Terminal 1: Web
flutter run -d chrome

# Terminal 2: Windows (different terminal)
flutter run -d windows
```

### Check performance
```bash
flutter run --profile -d chrome
```

---

## 📱 Deploy to Production

### Web (Static Hosting)

```bash
# Build
flutter build web --release

# Output folder
cd build\web

# Deploy to:
# - GitHub Pages
# - Netlify (drag & drop build/web folder)
# - Vercel
# - Firebase Hosting
```

### Windows Desktop

```bash
# Build
flutter build windows --release

# Output
build\windows\runner\Release\

# Distribute the entire Release folder
```

---

## 🎊 All Done!

Now you can run your app with just:

```bash
setup.bat
```

or

```bash
run_web.bat
```

**Enjoy! 🚀✨**
