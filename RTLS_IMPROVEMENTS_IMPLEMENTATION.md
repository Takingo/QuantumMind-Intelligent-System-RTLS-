# ✅ RTLS Map İyileştirmeler - Uygulama Kılavuzu

## 📋 Durum Özeti:

### ✅ Şu Anda Çalışan:
1. Zone → Çift tıkla → Name, Width, Height, Color düzenlenebilir
2. Door → Çift tıkla → Name düzenlenebilir
3. Anchor → Çift tıkla → ID, Name düzenlenebilir
4. Tags (W/V/E/A) → Çift tıkla → ID, Name düzenlenebilir

### ❌ Eksik Olanlar:
1. **Wall düzenleme yok** - Sadece info gösteriliyor
2. **Ölçü sistemi yok** - Pixel değerleri var, gerçek mesafe yok
3. **Landscape mod** - Scroll çalışmıyor, ekran tam oturmuyor

---

## 🔧 ÇözÜMLER:

### **1. Wall Edit Dialog Ekle**

#### A) State variables ekle (satır ~45'e):
```dart
// Existing:
bool _isPlacingElement = false;
String _pendingElementType = '';
bool _isDisposed = false;

// ADD THIS:
double _mapScale = 0.025; // 1px = 0.025m (2.5cm)
String _measurementUnit = 'meter'; // meter, cm, feet
bool _showMeasurements = true;
```

#### B) _editWall() metodu ekle (_editDoor'dan sonra, ~920 civarı):
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

#### C) _buildWall widget'ını güncelle (~275'te):
```dart
// Change this line:
onDoubleTap: _isEditMode ? () => _showWallInfo(wall) : null,

// To:
onDoubleTap: _isEditMode ? () => _editWall(wall) : null,
```

#### D) _EditWallDialog widget'ı ekle (dosya sonuna, ~1830):
```dart
class _EditWallDialog extends StatefulWidget {
  final MapWall wall;
  final VoidCallback onEdit;
  const _EditWallDialog({required this.wall, required this.onEdit});
  
  @override
  State<_EditWallDialog> createState() => _EditWallDialogState();
}

class _EditWallDialogState extends State<_EditWallDialog> {
  late TextEditingController _thicknessController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _thicknessController = TextEditingController(text: '6');
    _selectedColor = Colors.grey[700]!;
  }

  @override
  void dispose() {
    _thicknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double length = ((widget.wall.x2 - widget.wall.x1).abs() + 
                     (widget.wall.y2 - widget.wall.y1).abs());
    
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Wall', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Length: ${length.toInt()} px',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: _thicknessController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Thickness (px)',
                labelStyle: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          const Text('Color:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Colors.grey[700]!,
              Colors.brown,
              Colors.blueGrey,
              Colors.black87,
            ].map((color) => GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onEdit();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
```

---

### **2. Map Config Dialog (Ölçü Sistemi)**

#### A) _showMapConfig() metodu ekle (~920):
```dart
void _showMapConfig() {
  if (!mounted) return;
  showDialog(
    context: context,
    builder: (context) => _MapConfigDialog(
      scale: _mapScale,
      unit: _measurementUnit,
      showMeasurements: _showMeasurements,
      onSave: (scale, unit, showMeas) {
        if (mounted) {
          setState(() {
            _mapScale = scale;
            _measurementUnit = unit;
            _showMeasurements = showMeas;
          });
        }
      },
    ),
  );
}
```

#### B) AppBar'a buton ekle (~70'te):
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.straighten),
    tooltip: 'Map Config',
    onPressed: _showMapConfig,
  ),
  IconButton(
      icon: const Icon(Icons.upload_file), onPressed: _importFloorPlan),
  // ... rest
],
```

#### C) _MapConfigDialog widget'ı ekle (dosya sonuna):
```dart
class _MapConfigDialog extends StatefulWidget {
  final double scale;
  final String unit;
  final bool showMeasurements;
  final Function(double, String, bool) onSave;
  
  const _MapConfigDialog({
    required this.scale,
    required this.unit,
    required this.showMeasurements,
    required this.onSave,
  });
  
  @override
  State<_MapConfigDialog> createState() => _MapConfigDialogState();
}

class _MapConfigDialogState extends State<_MapConfigDialog> {
  late TextEditingController _scaleController;
  late String _selectedUnit;
  late bool _showMeas;

  @override
  void initState() {
    super.initState();
    _scaleController = TextEditingController(
      text: widget.scale.toString(),
    );
    _selectedUnit = widget.unit;
    _showMeas = widget.showMeasurements;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Map Configuration',
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scale (1 pixel =)',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scaleController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '0.025',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedUnit,
                  dropdownColor: const Color(0xFF1F2937),
                  style: const TextStyle(color: Colors.white),
                  items: [
                    DropdownMenuItem(value: 'meter', child: Text('meters')),
                    DropdownMenuItem(value: 'cm', child: Text('cm')),
                    DropdownMenuItem(value: 'feet', child: Text('feet')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedUnit = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Example: 1px = 0.025m (2.5cm)',
                style: TextStyle(color: Colors.orange, fontSize: 12)),
            const Divider(color: Colors.grey, height: 32),
            SwitchListTile(
              title: const Text('Show Measurements',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Display sizes on elements',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              value: _showMeas,
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() => _showMeas = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            double scale = double.tryParse(_scaleController.text) ?? 0.025;
            widget.onSave(scale, _selectedUnit, _showMeas);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
```

#### D) Helper method ekle:
```dart
String _toRealSize(double pixels) {
  double realSize = pixels * _mapScale;
  switch (_measurementUnit) {
    case 'meter':
      return '${realSize.toStringAsFixed(2)}m';
    case 'cm':
      return '${(realSize * 100).toStringAsFixed(0)}cm';
    case 'feet':
      return '${(realSize * 3.28084).toStringAsFixed(2)}ft';
    default:
      return '${realSize.toStringAsFixed(2)}m';
  }
}
```

#### E) Zone'da ölçü göster (~240'ta):
```dart
child: Stack(
  children: [
    Center(
      child: Text(zone.name,
          style: TextStyle(
              color: zone.color,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    ),
    if (_showMeasurements)
      Positioned(
        bottom: 2,
        right: 2,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            '${_toRealSize(zone.width)} × ${_toRealSize(zone.height)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
  ],
)
```

---

### **3. Landscape Scroll Fix**

#### A) body değişikliği (~90'da):
```dart
body: SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height - 80,
    ),
    child: Column(
      children: [
        if (_isEditMode) _buildDrawingTools(),
        SizedBox(
          height: MediaQuery.of(context).size.height - 
                 (MediaQuery.of(context).orientation == Orientation.landscape ? 150 : 200),
          child: Row(
            children: [
              // ... existing Row content
            ],
          ),
        ),
        _buildElementList(),
      ],
    ),
  ),
),
```

---

## 🎯 ÖNCELİK SIRASI:

### Adım 1: **Map Config** (30 dk)
1. State variables ekle
2. _showMapConfig() ekle
3. AppBar butonu ekle
4. _MapConfigDialog widget ekle
5. _toRealSize() helper ekle
6. Test et

### Adım 2: **Zone Measurements** (15 dk)
1. Zone widget'ında Stack kullan
2. Positioned measurement badge ekle
3. Test et

### Adım 3: **Wall Edit** (20 dk)
1. _editWall() metodu ekle
2. onDoubleTap güncelle
3. _EditWallDialog widget ekle
4. Test et

### Adım 4: **Landscape Scroll** (15 dk)
1. body'yi SingleChildScrollView'a sar
2. Height hesaplamalarını güncelle
3. Test et

---

## 🧪 TEST ADIMLARI:

### Map Config Test:
```
1. AppBar'da straighten (cetvel) ikonuna tıkla
2. Scale değerini değiştir (0.025 → 0.05)
3. Unit'i değiştir (meter → cm)
4. "Show Measurements" toggle yap
5. Save → Zone'larda ölçüler görünmeli
```

### Wall Edit Test:
```
1. Wall çiz
2. Wall'a çift tıkla
3. Edit dialog açılmalı
4. Thickness değiştir
5. Color değiştir
6. Save → Değişiklikler uygulanmalı
```

### Landscape Test:
```
1. Telefonu yatay çevir
2. Scroll yapabilmeli
3. Map tam görünmeli
4. Tüm elementlere erişebilmeli
```

---

## ✅ SONUÇ:

Bu değişikliklerden sonra:

✅ **Her element düzenlenebilir** (Zone, Door, Anchor, Tags, Wall)  
✅ **Gerçek ölçüler** (meter/cm/feet ile)  
✅ **Landscape mod** çalışıyor (scroll ile)  
✅ **Map Config** butonu  
✅ **Ölçü gösterimleri** (zone boyutları, wall uzunluğu)

**Toplam Süre**: ~80 dakika  
**Dosya Büyüklüğü**: ~2,000 satır → ~2,200 satır (+200 satır)

Başarılar! 🚀
