# RTLS Map İyileştirmeler - TODO

## 🎯 Kullanıcı İstekleri:

### 1. **Her Element Düzenlenebilir Olmalı** ✅/❌
**Durum Kontrol**:
- [x] Zone → Çift tıkla → Name, Width, Height, Color ✅
- [x] Door → Çift tıkla → Name ✅
- [x] Anchor → Çift tıkla → ID, Name ✅
- [x] Tags (W/V/E/A) → Çift tıkla → ID, Name ✅
- [❌] Wall → Şu anda sadece Info gösteriliyor
  - **SORUN**: Wall düzenlenemiyor!
  - **ÇÖZÜM**: _EditWallDialog ekle

**Wall Edit Özellikleri**:
```dart
- Start Point (x1, y1)
- End Point (x2, y2)
- Thickness (kalınlık)
- Color (renk)
```

---

### 2. **Mesafe/Ölçü Sistemi** ❌
**İSTENEN**: Map'te gerçek ölçüler
- Duvar uzunluğu (m veya cm)
- Oda genişliği
- Zone boyutları (gerçek metre)
- Anchor arası mesafeler

**Şu Anda**: Sadece pixel değerleri var

**ÇÖZÜM**: Map Config Dialog

#### Map Config Dialog İçeriği:
```dart
- Scale (Ölçek): 1px = X meter
- Unit (Birim): Meter / Centimeter / Feet
- Grid Size: 50px = X meter
- Show Measurements: ON/OFF
- Show Distances: ON/OFF
```

#### Ölçü Gösterimi:
```dart
Zone:
  Width: 120px → 3.0m (scale ile)
  Height: 100px → 2.5m

Wall:
  Length: 150px → 3.75m
  
Door:
  Width: 60px → 1.5m (standart kapı)
```

---

### 3. **Yatay (Landscape) Mod Düzeltme** ❌
**SORUN**: Landscape'de ekran tam oturmuyor

**ÇÖZÜM**: 
```dart
body: OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.landscape) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ...
      );
    } else {
      return Column(...);
    }
  },
)
```

**veya daha basit**:
```dart
body: SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height,
    ),
    child: Column(...)
  ),
)
```

---

## 📝 İMPLEMENTASYON PLANI

### **Faz 1: Map Config Dialog** (Öncelik: YÜKSEK)

#### 1.1 State Variables Ekle:
```dart
double _mapScale = 0.025; // 1px = 0.025m (2.5cm)
String _unit = 'meter'; // meter, cm, feet
bool _showMeasurements = true;
bool _showDistances = true;
```

#### 1.2 _showMapConfig() Metodu:
```dart
void _showMapConfig() {
  showDialog(
    context: context,
    builder: (context) => _MapConfigDialog(
      scale: _mapScale,
      unit: _unit,
      showMeasurements: _showMeasurements,
      showDistances: _showDistances,
      onSave: (scale, unit, showMeas, showDist) {
        setState(() {
          _mapScale = scale;
          _unit = unit;
          _showMeasurements = showMeas;
          _showDistances = showDist;
        });
      },
    ),
  );
}
```

#### 1.3 AppBar'a Buton Ekle:
```dart
IconButton(
  icon: const Icon(Icons.straighten),
  tooltip: 'Map Config (Measurements)',
  onPressed: _showMapConfig,
),
```

#### 1.4 Ölçü Gösterimi:
```dart
// Zone'da
Text('${zone.name}\n${_toRealSize(zone.width)} x ${_toRealSize(zone.height)}')

// Helper method
String _toRealSize(double pixels) {
  double realSize = pixels * _mapScale;
  if (_unit == 'meter') {
    return '${realSize.toStringAsFixed(2)}m';
  } else if (_unit == 'cm') {
    return '${(realSize * 100).toStringAsFixed(0)}cm';
  } else {
    return '${(realSize * 3.28084).toStringAsFixed(2)}ft';
  }
}
```

---

### **Faz 2: Wall Edit Dialog** (Öncelik: YÜKSEK)

#### 2.1 _editWall() Metodu:
```dart
void _editWall(MapWall wall) {
  if (!mounted) return;
  showDialog(
    context: context,
    builder: (context) => _EditWallDialog(
      wall: wall,
      onEdit: () {
        if (mounted) setState(() {});
      },
    ),
  );
}
```

#### 2.2 _EditWallDialog Widget:
```dart
class _EditWallDialog extends StatefulWidget {
  final MapWall wall;
  final VoidCallback onEdit;
  ...
  
  // Editable:
  // - Thickness (kalınlık)
  // - Color (renk)
  // - Length (info olarak)
}
```

#### 2.3 Wall Widget'ı Güncelle:
```dart
onDoubleTap: _isEditMode ? () => _editWall(wall) : null,
```

---

### **Faz 3: Landscape Scroll Fix** (Öncelik: ORTA)

#### 3.1 Orientation Check:
```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return SingleChildScrollView(
      physics: isLandscape ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: isLandscape ? null : constraints.maxHeight,
        child: Column(
          children: [...]
        ),
      ),
    );
  },
)
```

#### 3.2 Map Height Adjustment:
```dart
SizedBox(
  height: MediaQuery.of(context).orientation == Orientation.landscape
    ? MediaQuery.of(context).size.height * 0.6
    : MediaQuery.of(context).size.height - 250,
  child: Row(
    children: [map content]
  ),
)
```

---

### **Faz 4: Ölçü Gösterimleri** (Öncelik: ORTA)

#### 4.1 Zone'da Ölçü:
```dart
child: Stack(
  children: [
    Center(child: Text(zone.name)),
    if (_showMeasurements)
      Positioned(
        bottom: 4,
        right: 4,
        child: Container(
          padding: EdgeInsets.all(2),
          color: Colors.black54,
          child: Text(
            '${_toRealSize(zone.width)} x ${_toRealSize(zone.height)}',
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ),
  ],
)
```

#### 4.2 Wall'da Uzunluk:
```dart
if (_showMeasurements)
  Positioned(
    left: (wall.x1 + wall.x2) / 2,
    top: (wall.y1 + wall.y2) / 2,
    child: Container(
      padding: EdgeInsets.all(2),
      color: Colors.black87,
      child: Text(
        _toRealSize(_calculateWallLength(wall)),
        style: TextStyle(fontSize: 10, color: Colors.yellow),
      ),
    ),
  )
```

#### 4.3 Distance Helper:
```dart
double _calculateWallLength(MapWall wall) {
  double dx = wall.x2 - wall.x1;
  double dy = wall.y2 - wall.y1;
  return sqrt(dx * dx + dy * dy);
}
```

---

## 🎯 Öncelik Sırası:

### **ŞİMDİ** (Kritik):
1. ✅ Map Config Dialog ekle
2. ✅ Wall Edit Dialog ekle  
3. ✅ Landscape scroll düzelt

### **SONRA** (Önemli):
4. ✅ Zone'larda ölçü gösterimi
5. ✅ Wall'larda uzunluk gösterimi
6. ✅ Door'da genişlik gösterimi

### **GELECEKsuggestions** (İyileştirme):
7. Anchor arası mesafe çizgisi
8. Measurement tool (ruler)
9. Area calculator (alan hesaplama)
10. Export measurements to PDF

---

## 📊 Test Checklist:

### Map Config:
- [ ] Config butonu AppBar'da
- [ ] Dialog açılıyor
- [ ] Scale değiştirilebiliyor
- [ ] Unit değiştirilebiliyor (m/cm/ft)
- [ ] Ayarlar kaydediliyor
- [ ] Ölçüler doğru gösteriliyor

### Wall Edit:
- [ ] Wall'a çift tıkla
- [ ] Edit dialog açılıyor
- [ ] Thickness değiştirilebiliyor
- [ ] Color değiştirilebiliyor
- [ ] Değişiklikler kaydediliyor

### Landscape Mode:
- [ ] Telefonu yatay çevir
- [ ] Scroll çalışıyor
- [ ] Map tam görünüyor
- [ ] Side panel erişilebilir
- [ ] Element ekleme çalışıyor

### Measurements:
- [ ] Zone'larda boyut gösteriliyor
- [ ] Wall'larda uzunluk gösteriliyor
- [ ] Unit değişimi çalışıyor
- [ ] Ölçüler doğru hesaplanıyor

---

## 💡 Örnek Kullanım:

### Senaryo 1: Fabrika Planı
```
Scale: 1px = 0.05m (5cm)
Unit: meter

Zone "Assembly Area":
  - Pixel: 200x150
  - Real: 10m x 7.5m

Wall "North Wall":
  - Pixel length: 300px
  - Real length: 15m

Door "Main Entrance":
  - Pixel: 60px
  - Real: 3m (wide door)
```

### Senaryo 2: Office Layout
```
Scale: 1px = 0.02m (2cm)
Unit: meter

Zone "Meeting Room":
  - Pixel: 150x120
  - Real: 3m x 2.4m

Wall "Partition":
  - Pixel: 120px
  - Real: 2.4m
```

---

## 🚀 Implementation Order:

1. **Map Config Dialog** → 30 min
2. **Wall Edit Dialog** → 20 min
3. **Landscape Scroll** → 15 min
4. **Zone Measurements** → 15 min
5. **Wall Length Display** → 10 min

**Total**: ~90 minutes

Let's start! 🎯
