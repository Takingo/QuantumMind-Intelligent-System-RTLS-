# 🚀 Quick Flutter Installation Guide

## 📥 **Option 1: Automatic Installation (Recommended)**

### **Step 1: Download Flutter**
Open PowerShell as Administrator and run:

```powershell
# Download Flutter SDK (stable channel)
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter_windows_3.16.5-stable.zip"

# Extract to C:\flutter
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter_windows_3.16.5-stable.zip" -DestinationPath "C:\" -Force

# Add to PATH permanently
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", [EnvironmentVariableTarget]::Machine)

Write-Host "✅ Flutter installed to C:\flutter" -ForegroundColor Green
Write-Host "⚠️  Please RESTART your terminal/IDE for PATH changes to take effect!" -ForegroundColor Yellow
```

### **Step 2: Restart Your Computer** 
(or at least restart Android Studio and all terminals)

### **Step 3: Verify Installation**
Open a **NEW** terminal and run:
```bash
flutter --version
flutter doctor
```

---

## 📥 **Option 2: Manual Installation (If Option 1 Fails)**

1. **Download Flutter SDK:**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Click "Download Flutter SDK"
   - Or direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip

2. **Extract the ZIP:**
   - Extract to `C:\flutter` (create this folder if it doesn't exist)
   - You should have `C:\flutter\bin\flutter.bat`

3. **Add to PATH:**
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find `Path`, click "Edit"
   - Click "New" and add: `C:\flutter\bin`
   - Click OK on all dialogs

4. **Restart Everything:**
   - Close all terminals and Android Studio
   - Restart your computer (recommended)

5. **Verify:**
   ```bash
   flutter --version
   flutter doctor
   ```

---

## 🔧 **After Flutter is Installed**

### **Setup Project Dependencies:**

```bash
cd "C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
flutter pub get
```

### **Create Platform Files:**

```bash
flutter create --platforms=android,ios,web,windows .
```

### **Run on Your Device:**

```bash
# Make sure tablet is connected via USB with debugging enabled
flutter devices
flutter run -d android
```

---

## ⚡ **Quick One-Liner (Copy-Paste into PowerShell Admin)**

```powershell
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter.zip"; Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter.zip" -DestinationPath "C:\" -Force; [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", [EnvironmentVariableTarget]::Machine); Write-Host "✅ Flutter installed! Restart your terminal." -ForegroundColor Green
```

---

## 🎯 **What This Will Fix**

All these errors will disappear after Flutter installation:
- ❌ `Target of URI doesn't exist: 'package:flutter/material.dart'`
- ❌ `Undefined name 'WidgetsFlutterBinding'`
- ❌ `Undefined name 'SystemChrome'`
- ❌ `The function 'runApp' isn't defined`

✅ **After installation + restart, Android Studio will detect Flutter SDK automatically!**

---

## 📝 **Troubleshooting**

### **"flutter command not found" after installation:**
- Make sure you **restarted** your terminal/IDE
- Or **restart your computer** completely
- Verify PATH was added: Run `echo $env:Path` in PowerShell and look for `C:\flutter\bin`

### **Android Studio still shows errors:**
- File → Settings → Languages & Frameworks → Flutter
- Set Flutter SDK path to: `C:\flutter`
- Click "Apply" then restart Android Studio

---

## 🎉 **Next Steps After Installation**

1. Restart your computer (or at least all terminals/IDEs)
2. Open Android Studio
3. File → Settings → Flutter SDK → Set to `C:\flutter`
4. Open Terminal in Android Studio
5. Run: `flutter pub get`
6. Connect your tablet via USB
7. Click the green ▶️ Run button!

---

**Need help?** Let me know which step fails and I'll assist! 🚀
