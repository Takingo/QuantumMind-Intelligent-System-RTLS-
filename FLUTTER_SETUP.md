# 🚀 Flutter Kurulum ve Çalıştırma Rehberi

## ❌ Mevcut Durum
Flutter sisteminizde kurulu değil.

## ✅ Çözüm: Flutter SDK Kurulumu

### 1️⃣ Flutter SDK İndirin

**Windows için:**
- İndirme linki: https://docs.flutter.dev/get-started/install/windows
- Veya direkt: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.5-stable.zip

### 2️⃣ SDK'yı Kurun

1. İndirdiğiniz ZIP dosyasını açın
2. `C:\` dizinine çıkartın (sonuç: `C:\flutter`)
3. **ÖNEMLİ:** Program Files içine koymayın!

### 3️⃣ PATH'e Ekleyin

**PowerShell (Admin olarak):**
```powershell
$env:Path += ";C:\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
```

**Manuel (GUI):**
1. Windows Search → "Environment Variables" veya "Ortam değişkenleri"
2. "Path" → Edit
3. New → `C:\flutter\bin` ekleyin
4. OK → OK

### 4️⃣ Flutter'ı Doğrulayın

Yeni bir terminal açın:
```bash
flutter doctor
```

Bu komut eksik bağımlılıkları gösterecek.

### 5️⃣ Chrome'u Aktif Edin (Web için)

```bash
flutter config --enable-web
```

---

## 🎯 Uygulamanızı Çalıştırın

### Adım 1: Dependencies Yükle
```bash
cd "c:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
flutter pub get
```

### Adım 2: Uygulamayı Başlat

**Web Browser'da (Önerilen - En Hızlı):**
```bash
flutter run -d chrome
```

**Windows Desktop App:**
```bash
flutter run -d windows
```

**Tüm cihazları listele:**
```bash
flutter devices
```

---

## 🌐 Alternatif: Online Flutter Editor

Flutter kurmadan denemek isterseniz:

### DartPad (Basit Demo için)
https://dartpad.dev

### Zapp.run (Tam Flutter Proje)
https://zapp.run

**NOT:** Ancak bu online editorler Supabase gibi backend servislere tam destek vermeyebilir.

---

## 📱 Mobil Cihazda Test (Android/iOS)

### Android için:
1. Android Studio kurun
2. Android SDK yükleyin
3. Emulator veya fiziksel cihaz bağlayın
4. `flutter run`

### iOS için (macOS gerekli):
1. Xcode kurun
2. iOS Simulator açın
3. `flutter run`

---

## 💡 Hızlı Başlangıç (Minimal Kurulum)

Sadece web için test etmek istiyorsanız:

```bash
# 1. Flutter SDK indir ve C:\flutter'a çıkart
# 2. PATH'e ekle
# 3. Terminalde:

flutter doctor
flutter config --enable-web
cd "c:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
flutter pub get
flutter run -d chrome
```

Bu kadar! 🎉

---

## ⚡ Express Kurulum (Chocolatey ile)

Chocolatey package manager kuruluysa:

```bash
choco install flutter
```

---

## 🆘 Sorun Giderme

### "Flutter not found" hatası:
- Terminal'i yeniden başlatın
- PATH'i kontrol edin: `echo %PATH%`
- Flutter klasör yolunu doğrulayın

### "No devices found" hatası:
- Chrome kurulu mu kontrol edin
- `flutter config --enable-web` çalıştırın
- `flutter devices` ile cihazları listeleyin

### Bağımlılık hataları:
```bash
flutter clean
flutter pub get
```

---

## 📞 Yardım

Flutter kurulumunda sorun yaşarsanız:
- Official Docs: https://docs.flutter.dev
- Discord: https://discord.gg/flutter
- GitHub: https://github.com/flutter/flutter/issues

---

## 🎊 Kurulum Tamamlandıktan Sonra

Uygulamanız şu adreste açılacak:
```
http://localhost:XXXX
```

Chrome/Edge browser'ınızda otomatik olarak açılacaktır.

**İyi eğlenceler! 🚀**
