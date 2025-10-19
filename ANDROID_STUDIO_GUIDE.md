# 🎯 Android Studio'da QuantumMind RTLS Projesi

## 📋 Ön Hazırlık

### Gereksinimler:
- ✅ Android Studio (Arctic Fox veya üzeri)
- ✅ Flutter SDK 3.0+
- ✅ Dart plugin
- ✅ Flutter plugin

---

## 🚀 Kurulum Adımları

### **Adım 1: Flutter SDK Kurulumu**

Eğer Flutter kurulu değilse:

1. **Flutter SDK indir:**
   - https://docs.flutter.dev/get-started/install/windows
   - Veya `install_flutter_auto.bat` scriptini çalıştır

2. **PATH'e ekle:**
   ```
   C:\flutter\bin
   ```

3. **Doğrula:**
   ```bash
   flutter doctor
   ```

---

### **Adım 2: Android Studio Flutter Eklentileri**

1. **Android Studio'yu aç**
2. **File → Settings** (Ctrl+Alt+S)
3. **Plugins** sekmesine git
4. **"Flutter"** ara ve kur
5. **Restart** Android Studio

---

### **Adım 3: Projeyi Aç**

#### **Yöntem A: Android Studio'dan**

1. **File → Open**
2. Şu klasörü seç:
   ```
   C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking
   ```
3. **OK** tıkla
4. Android Studio `pubspec.yaml` dosyasını algılayacak

#### **Yöntem B: Terminal'den**

```bash
cd "C:\Users\posei\QuantumMind Intelligent System & RTLS Live Tracking"
code .  # VS Code için
# veya
android-studio .  # Android Studio için
```

---

### **Adım 4: Platform Dosyalarını Oluştur**

Proje açıldıktan sonra terminal'de (Android Studio içinde):

```bash
# Android için
flutter create --platforms=android .

# iOS için (macOS'ta)
flutter create --platforms=ios .

# Web için
flutter create --platforms=web .

# Windows için
flutter create --platforms=windows .

# Veya hepsi birden
flutter create --platforms=android,ios,web,windows .
```

**Veya otomatik script:**
```bash
.\create_platforms.bat
```

---

### **Adım 5: Dependencies Yükle**

Android Studio alt tarafta **"Get dependencies"** bildirimi çıkacak:
- Bildirime tıkla
- Veya manuel: **Tools → Flutter → Flutter Pub Get**

Terminal'de:
```bash
flutter pub get
```

---

## 🎮 Çalıştırma

### **Android Studio'dan Çalıştırma:**

1. **Cihaz seç** (üst toolbar):
   - Android emulator
   - Fiziksel Android cihaz (USB ile bağlı)
   - Chrome (web için)
   - Windows (desktop için)

2. **Run butonu** (yeşil ▶️) veya **Shift+F10**

3. **Debug mode:** **Debug butonu** (🐛) veya **Shift+F9**

---

### **Terminal'den Çalıştırma:**

```bash
# Android
flutter run -d android

# Web
flutter run -d chrome

# Windows Desktop
flutter run -d windows

# Specific device
flutter devices  # Cihazları listele
flutter run -d <device-id>
```

---

## 📱 Platform-Specific Yapılandırma

### **Android (`android/app/build.gradle`):**

```gradle
android {
    compileSdkVersion 33  // Güncel version
    
    defaultConfig {
        applicationId "com.quantummind.rtls"
        minSdkVersion 21  // Minimum Android 5.0
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

### **Android Permissions (`android/app/src/main/AndroidManifest.xml`):**

```xml
<manifest>
    <!-- Internet izni (Supabase için) -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Bluetooth/UWB için (opsiyonel) -->
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    
    <application
        android:label="QuantumMind RTLS"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

### **iOS (`ios/Runner/Info.plist`):**

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>QuantumMind RTLS uses Bluetooth for UWB positioning</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>QuantumMind RTLS needs location for indoor positioning</string>
```

---

## 🔧 Android Studio Yapılandırması

### **Run Configuration:**

1. **Run → Edit Configurations**
2. **+ → Flutter**
3. Ayarlar:
   - **Name:** QuantumMind RTLS
   - **Dart entrypoint:** `lib/main.dart`
   - **Additional arguments:** (opsiyonel)
     - `--dart-define=ENVIRONMENT=development`

### **Hot Reload & Hot Restart:**

- **Hot Reload:** `Ctrl+S` (değişiklikleri anında uygular)
- **Hot Restart:** `Ctrl+Shift+\` (uygulamayı yeniden başlatır)
- **Terminal'de:** `r` (reload), `R` (restart)

---

## 📦 Build APK/AAB

### **Android Studio'dan:**

1. **Build → Flutter → Build APK**
2. **Build → Flutter → Build App Bundle** (Google Play için)

### **Terminal'den:**

```bash
# Release APK
flutter build apk --release

# Debug APK
flutter build apk --debug

# Split APK (daha küçük)
flutter build apk --split-per-abi --release

# App Bundle (Google Play)
flutter build appbundle --release
```

**Output:**
```
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

---

## 🌐 Web Build

```bash
flutter build web --release
```

**Deploy to:**
- GitHub Pages
- Firebase Hosting
- Netlify
- Vercel

**Output:** `build/web/`

---

## 💻 Windows Desktop Build

```bash
flutter build windows --release
```

**Output:** `build/windows/runner/Release/`

---

## 🐛 Debugging

### **Android Studio DevTools:**

1. **Run app in debug mode**
2. **View → Tool Windows → Flutter Inspector**
3. **View → Tool Windows → Flutter Performance**

### **Useful Commands:**

```bash
# Logs
flutter logs

# Clean build
flutter clean
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 🎨 Android Studio Eklentileri (Önerilen)

1. **Flutter** - Temel Flutter desteği
2. **Dart** - Dart dil desteği
3. **Flutter Intl** - Çoklu dil desteği
4. **Flutter Snippets** - Code snippets
5. **Rainbow Brackets** - Kod okunabilirliği
6. **GitToolBox** - Git entegrasyonu

---

## 📁 Proje Yapısı (Android Studio'da)

```
QuantumMind-RTLS/
├── android/              # Android platform dosyaları
│   ├── app/
│   │   ├── build.gradle  # Android konfigürasyonu
│   │   └── src/
│   └── gradle/
├── ios/                  # iOS platform dosyaları
├── web/                  # Web platform dosyaları
├── windows/              # Windows platform dosyaları
├── lib/                  # Flutter/Dart kaynak kodu
│   ├── main.dart        # Uygulama giriş noktası
│   ├── app.dart
│   ├── models/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   ├── theme/
│   └── utils/
├── assets/              # Görsel/font dosyaları
├── test/                # Test dosyaları
├── pubspec.yaml         # Bağımlılıklar
└── README.md
```

---

## 🔑 Önemli Kısayollar

| Kısayol | Açıklama |
|---------|----------|
| **Shift+F10** | Run |
| **Shift+F9** | Debug |
| **Ctrl+S** | Hot Reload |
| **Ctrl+Shift+\** | Hot Restart |
| **Ctrl+Alt+L** | Code format |
| **Ctrl+/** | Comment/Uncomment |
| **Alt+Enter** | Quick fix |
| **Ctrl+Space** | Code completion |

---

## ⚡ Hızlı Başlangıç Checklist

- [ ] Flutter SDK kurulu (`flutter doctor`)
- [ ] Android Studio Flutter plugin kurulu
- [ ] Proje Android Studio'da açık
- [ ] Platform dosyaları oluşturuldu (`flutter create --platforms=android,web,windows .`)
- [ ] Dependencies yüklendi (`flutter pub get`)
- [ ] Cihaz seçildi (emulator/phone/chrome)
- [ ] Supabase credentials ayarlandı (`lib/utils/constants.dart`)
- [ ] Run butonu tıklandı ▶️

---

## 🎯 Sonraki Adımlar

1. **Flutter kurulmadıysa:**
   ```bash
   .\install_flutter_auto.bat
   ```

2. **Platform dosyalarını oluştur:**
   ```bash
   .\create_platforms.bat
   ```

3. **Android Studio'da aç:**
   - File → Open → Proje klasörü seç

4. **Dependencies yükle:**
   - Alt taraftaki "Get dependencies" tıkla

5. **Çalıştır:**
   - Cihaz seç → Run (Shift+F10)

---

## 📞 Sorun Giderme

### "SDK location not found"
```bash
# Android Studio → File → Project Structure
# SDK Location kısmına Android SDK path'i girin
# Genellikle: C:\Users\<username>\AppData\Local\Android\Sdk
```

### "Gradle sync failed"
```bash
flutter clean
flutter pub get
# Sonra Android Studio → File → Invalidate Caches / Restart
```

### "No devices found"
```bash
# Android için
flutter devices
# USB debugging aktif mi kontrol et

# Web için
flutter config --enable-web
```

---

## 🎊 Başarılı! 

Artık projenizi Android Studio'da açıp tüm platformlarda çalıştırabilirsiniz!

**Kolay gelsin! 🚀**
