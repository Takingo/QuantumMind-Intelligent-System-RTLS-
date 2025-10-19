# 🌌 QuantumMind Intelligent System & RTLS Live Tracking

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.16.5-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/License-Proprietary-red)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)

**Cross-platform Flutter application integrating UWB-based intelligent automation with Real-Time Location System (RTLS) live tracking**

[Features](#-features) • [Installation](#-quick-start) • [Documentation](#-documentation) • [Screenshots](#-screenshots)

</div>

---

## 🌐 Overview

QuantumMind RTLS is an enterprise-grade **real-time location tracking system** built with Flutter, designed for industrial environments requiring precise indoor positioning using **UWB (Ultra-Wideband) technology**. The system integrates with ESP32-DW3000 hardware modules for sub-meter accuracy positioning and automated door access control.

### Key Capabilities

- 📍 **Sub-meter accuracy** indoor positioning using UWB technology
- 🚪 **Automated access control** based on proximity detection
- 📊 **Real-time analytics** and system monitoring
- 🌡️ **Environmental monitoring** (temperature, humidity, air quality)
- 🔐 **Role-based access control** with Supabase authentication
- 🎨 **Quantum-futuristic UI** with neon effects and particle animations

---

## ✨ Features

### 🔐 Authentication & Security
- Supabase Auth integration (email/password)
- Role-based access control (Admin, User, Viewer)
- AES-256 encrypted device tokens
- JWT-based session management
- Row Level Security (RLS) in database

### 📊 Real-time Dashboard
- Live system statistics and KPIs
- Interactive charts and analytics
- System health monitoring
- Event log viewer
- Multi-language support (EN, DE, TR)

### 🗺️ RTLS Live Tracking
- 2D factory floor visualization
- Real-time tag position updates
- Tag movement trails and history
- Anchor placement and signal strength overlay
- Zoom/pan controls
- Trilateration-based positioning

### 🚪 Door Control System
- UWB proximity-triggered door control
- Configurable distance thresholds
- Manual door control (Open/Close/Lock)
- Access log tracking
- Scheduled automation support

### 🌡️ Environmental Monitoring
- Real-time sensor data (temperature, humidity, air quality)
- Historical data charts
- Alert notifications for threshold violations
- Multi-sensor support

### 💾 Backup & Recovery
- Cloud backup to Supabase Storage
- Local device mirror (FRAM/SD)
- Export/Import configuration (JSON)
- Automatic restore on device replacement

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** >= 3.0.0 ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** >= 3.0.0
- **Git** ([Download](https://git-scm.com/downloads))
- **Supabase Account** ([Sign up](https://supabase.com))
- **ESP32-DW3000** hardware (optional for full functionality)

### Installation

#### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-.git
cd QuantumMind-Intelligent-System-RTLS-
```

#### 2️⃣ Install Dependencies

```bash
flutter pub get
```

#### 3️⃣ Configure Supabase

Edit `lib/utils/constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**Get credentials from:** Supabase Dashboard → Settings → API

#### 4️⃣ Set Up Database

Run the SQL commands from `SETUP_GUIDE.md` in your Supabase SQL Editor to create:
- Users table
- UWB Tags table
- Doors table
- RTLS Nodes table
- Sensor Data table
- Logs table

#### 5️⃣ Run the Application

**Web (Chrome/Edge):**
```bash
flutter run -d chrome
```

**Android Device:**
```bash
flutter run -d android
```

**Windows Desktop:**
```bash
flutter run -d windows
```

**Or use the automated scripts:**
```bash
# Windows
setup.bat          # Complete setup
run_web.bat        # Run in browser
run_device.bat     # Run on Android device
build_apk.bat      # Build APK for distribution
```

---

## 🏗️ Architecture

### Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | Flutter 3.16.5 |
| **State Management** | Provider + GetX |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime, Storage) |
| **Real-time Communication** | MQTT, WebSocket |
| **Hardware** | ESP32-DW3000 (UWB) + Relay Board |
| **Charts** | fl_chart, syncfusion_flutter_charts |
| **Security** | AES-256, JWT, Row Level Security |

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # App routing and initialization
├── theme/
│   └── theme_config.dart     # Quantum-futuristic theme
├── models/                   # Data models
│   ├── user_model.dart
│   ├── tag_model.dart
│   ├── door_model.dart
│   ├── rtls_node_model.dart
│   ├── sensor_model.dart
│   └── log_model.dart
├── services/                 # Backend integration
│   ├── supabase_service.dart
│   ├── auth_service.dart
│   ├── mqtt_service.dart
│   └── http_service.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── door_control_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable components
│   ├── quantum_background.dart
│   ├── header_bar.dart
│   └── dashboard_card.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── helpers.dart
    └── animations.dart
```

---

## 📱 Build & Deploy

### Android APK

```bash
# Release APK
flutter build apk --release

# Split APK (smaller size)
flutter build apk --split-per-abi --release

# App Bundle (for Google Play)
flutter build appbundle --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### Web Deployment

```bash
flutter build web --release
```

**Deploy to:**
- GitHub Pages
- Netlify
- Vercel
- Firebase Hosting

### Desktop

```bash
# Windows
flutter build windows --release

# macOS (requires macOS)
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🎨 Design System

### Color Palette

- **Primary**: Quantum Blue `#007AFF`
- **Accent**: Energy Green `#00FFC6`
- **Background**: Dark Gradient `#0B0C10 → #1B2735`
- **Success**: `#10B981`
- **Warning**: `#F59E0B`
- **Error**: `#EF4444`

### Typography

- **Headings**: Poppins (Bold, SemiBold)
- **Body**: Inter (Regular, Medium)

### Visual Effects

- ✨ Neon glow effects
- 🌊 Particle animations
- ⚡ Energy line backgrounds
- 💎 Gradient cards
- 🎭 Dark/Light theme switching

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Complete setup instructions with database schema |
| [FLUTTER_SETUP.md](FLUTTER_SETUP.md) | Flutter SDK installation guide |
| [DEVICE_TESTING.md](DEVICE_TESTING.md) | Testing on real devices |
| [TERMINAL_GUIDE.md](TERMINAL_GUIDE.md) | Terminal commands reference |
| [QUICK_START.md](QUICK_START.md) | Quick start for tablet testing |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Project overview and roadmap |

---

## 🔒 Security

- ✅ **AES-256 Encryption** for device tokens and sensitive data
- ✅ **Row Level Security (RLS)** in Supabase database
- ✅ **JWT Authentication** with secure session management
- ✅ **HTTPS/TLS** for all API communications
- ✅ **Role-based Access Control** (Admin, User, Viewer)
- ✅ **Secure WebSocket** connections for real-time data

---

## 🛠️ Hardware Integration

### ESP32-DW3000 UWB Module

**Specifications:**
- Ultra-Wideband (UWB) transceiver
- Sub-meter positioning accuracy
- IEEE 802.15.4-2011 UWB compliant
- 3.1 - 10.6 GHz frequency range

**Communication:**
- Primary: Supabase REST & Realtime
- Secondary: MQTT / HTTP for direct control

**Endpoints:**
- `/door/open` - Trigger door opening
- `/door/close` - Close door
- `/door/status` - Get door status
- `/config` - Device configuration

---

## 📊 Screenshots

> *Screenshots will be added here*

**Login Screen** | **Dashboard** | **RTLS Map**
:--:|:--:|:--:
*Quantum-themed auth* | *Real-time stats* | *Live tracking*

**Door Control** | **Sensors** | **Settings**
:--:|:--:|:--:
*Access management* | *Environmental data* | *Configuration*

---

## 🗺️ Roadmap

### ✅ Phase 1 - Core Features (Completed)
- [x] Flutter project setup
- [x] Supabase integration
- [x] Authentication system
- [x] Dashboard UI
- [x] Data models
- [x] MQTT service
- [x] Quantum theme

### 🚧 Phase 2 - Advanced Features (In Progress)
- [ ] RTLS live map implementation
- [ ] Charts and analytics
- [ ] Advanced door control
- [ ] Tag management UI
- [ ] Sensor monitoring dashboard

### 📅 Phase 3 - Enterprise Features (Planned)
- [ ] Multi-tenant support
- [ ] Advanced reporting
- [ ] Mobile notifications
- [ ] Geofencing
- [ ] Integration APIs
- [ ] Audit logging

---

## 🤝 Contributing

This is a proprietary project. For collaboration inquiries, please contact the development team.

---

## 📄 License

Copyright © 2025 **QuantumMind Innovation**. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

---

## 👥 Team

**QuantumMind Innovation**
- 🌐 Website: *quantummind.io*
- 📧 Email: support@quantummind.io
- 💼 GitHub: [@Takingo](https://github.com/Takingo)

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Supabase for the powerful backend platform
- ESP32 Community for hardware support
- Open-source contributors

---

<div align="center">

**Built with ❤️ using Flutter**

⭐ Star this repo if you find it useful!

[Report Bug](https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-/issues) • [Request Feature](https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-/issues)

</div>
