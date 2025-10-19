# 🚀 QuantumMind RTLS - Quick Start Guide

## ⚡ Hızlı Başlangıç (Quick Start)

### 1️⃣ Bağımlılıkları Yükle (Install Dependencies)

```bash
flutter pub get
```

### 2️⃣ Supabase Yapılandırması (Supabase Configuration)

`lib/utils/constants.dart` dosyasını açın ve Supabase bilgilerinizi girin:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3️⃣ Uygulamayı Çalıştır (Run the App)

```bash
# Web için
flutter run -d chrome

# Android için
flutter run -d android

# Windows için
flutter run -d windows
```

---

## 📊 Supabase Veritabanı Şeması (Database Schema)

Supabase'de aşağıdaki tabloları oluşturun:

### 1. `users` Tablosu

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'User',
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true
);
```

### 2. `uwb_tags` Tablosu

```sql
CREATE TABLE uwb_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid TEXT UNIQUE NOT NULL,
  secret_key TEXT NOT NULL,
  user_id UUID REFERENCES users(id),
  user_name TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE,
  last_x DOUBLE PRECISION,
  last_y DOUBLE PRECISION,
  department TEXT,
  description TEXT
);
```

### 3. `doors` Tablosu

```sql
CREATE TABLE doors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  threshold DOUBLE PRECISION DEFAULT 1.5,
  relay_pin INTEGER NOT NULL,
  status TEXT DEFAULT 'closed',
  is_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_triggered_at TIMESTAMP WITH TIME ZONE,
  last_triggered_by TEXT,
  location TEXT,
  open_duration INTEGER DEFAULT 3000
);
```

### 4. `rtls_nodes` Tablosu

```sql
CREATE TABLE rtls_nodes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  coord_x DOUBLE PRECISION NOT NULL,
  coord_y DOUBLE PRECISION NOT NULL,
  coord_z DOUBLE PRECISION,
  signal_quality DOUBLE PRECISION DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_sync_at TIMESTAMP WITH TIME ZONE,
  ip_address TEXT,
  mac_address TEXT,
  firmware_version TEXT
);
```

### 5. `sensor_data` Tablosu

```sql
CREATE TABLE sensor_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  node_id UUID REFERENCES rtls_nodes(id),
  node_name TEXT,
  temp DOUBLE PRECISION,
  humidity DOUBLE PRECISION,
  air_quality DOUBLE PRECISION,
  pressure DOUBLE PRECISION,
  light_level DOUBLE PRECISION,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 6. `logs` Tablosu

```sql
CREATE TABLE logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event TEXT NOT NULL,
  tag_id UUID,
  tag_uid TEXT,
  user_id UUID,
  user_name TEXT,
  door_id UUID,
  door_name TEXT,
  distance DOUBLE PRECISION,
  location TEXT,
  details TEXT,
  severity TEXT DEFAULT 'info',
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔐 Row Level Security (RLS) Politikaları

Her tablo için RLS'yi aktif edin:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE uwb_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE doors ENABLE ROW LEVEL SECURITY;
ALTER TABLE rtls_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sensor_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;
```

Örnek politika (admin tüm erişim):

```sql
CREATE POLICY "Admin full access" ON users
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'Admin');

CREATE POLICY "Users can read their own data" ON users
  FOR SELECT
  USING (auth.uid() = id);
```

---

## 🎨 Özellikler (Features)

✅ **Tamamlandı:**
- ✔ Supabase Authentication entegrasyonu
- ✔ Quantum-futuristic UI tema sistemi
- ✔ Login ekranı
- ✔ Dashboard temel yapısı
- ✔ Data modelleri (User, Tag, Door, RTLS Node, Sensor, Log)
- ✔ Servis katmanı (Supabase, MQTT, HTTP)
- ✔ Temel widget'lar

🚧 **Devam Ediyor:**
- ⏳ RTLS canlı harita
- ⏳ Door control detaylı ekran
- ⏳ Chart entegrasyonları
- ⏳ User/Tag management ekranları
- ⏳ Sensor monitoring
- ⏳ Settings & Backup

---

## 🎯 Sonraki Adımlar (Next Steps)

1. **Fonts ekle:** `assets/fonts/` klasörüne Inter ve Poppins fontlarını yükleyin
2. **Logo ekle:** `assets/logo/` klasörüne QuantumMind logonuzu ekleyin
3. **Supabase yapılandır:** Yukarıdaki SQL komutlarını çalıştırın
4. **Test kullanıcısı oluştur:** Supabase Dashboard'dan bir kullanıcı ekleyin
5. **Uygulamayı test edin:** `flutter run` ile başlatın

---

## 📞 Destek (Support)

Sorularınız için: support@quantummind.io

---

## 📄 Lisans

Copyright © 2025 QuantumMind Innovation. All rights reserved.
