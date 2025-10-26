# Quick User Guide - New Features 🚀

## 🎯 What's New

### 1. Map Config (Measurement System) 📏

**How to Access**:
1. Open RTLS Map screen
2. Look at top-right AppBar
3. Tap the **Ruler icon** (first icon)

**What You Can Configure**:

```
┌─────────────────────────────────┐
│   Map Configuration             │
├─────────────────────────────────┤
│                                 │
│ Map Scale (1 pixel = ? meters)  │
│ ┌─────────────────────────────┐ │
│ │ 0.025                       │ │
│ └─────────────────────────────┘ │
│                                 │
│ Measurement Unit                │
│ ┌─────────────────────────────┐ │
│ │ Meters (m)            ▼     │ │
│ └─────────────────────────────┘ │
│   Options: Meters, CM, Feet     │
│                                 │
│ ☑ Show measurements on elements │
│                                 │
│         [Cancel]  [Save]        │
└─────────────────────────────────┘
```

**Scale Examples**:
- `0.01` = 1 pixel = 1 cm (very detailed)
- `0.025` = 1 pixel = 2.5 cm (default)
- `0.05` = 1 pixel = 5 cm (larger scale)
- `0.1` = 1 pixel = 10 cm (very large scale)

**How to Calculate Scale**:
```
If your floor plan is 1000 pixels wide and represents 25 meters:
Scale = 25m ÷ 1000px = 0.025 meters per pixel
```

---

### 2. Zone Measurements 📐

**What It Shows**:
When you enable "Show measurements", each zone displays:

```
        ┌─────[3.00m]─────┐
        │                 │
   [2.50m]  Warehouse    │
        │                 │
        └─────────────────┘
```

- **Top badge** = Width in selected unit
- **Left badge** = Height in selected unit
- **Center text** = Zone name (unchanged)

**Visibility**:
- ✅ Visible when "Show measurements" is enabled
- ❌ Hidden when disabled (only zone name shows)

**Updates Automatically**:
- Change scale → measurements update
- Change unit → measurements convert
- No need to refresh

---

### 3. Wall Editing 🧱

**How to Edit Wall**:
1. Tap **Edit** button in AppBar (enters edit mode)
2. **Double-tap any wall**
3. Wall info dialog appears:

```
┌─────────────────────────────────┐
│   Wall Info                     │
├─────────────────────────────────┤
│                                 │
│ Start: (150.0, 200.0)           │
│                                 │
│ End: (450.0, 200.0)             │
│                                 │
│ Length: 300.0 px                │
│                                 │
│ Note: To edit wall, drag        │
│ endpoints in edit mode          │
│                                 │
│              [Close]            │
└─────────────────────────────────┘
```

**What You See**:
- Start coordinates (x, y)
- End coordinates (x, y)
- Wall length in pixels
- Helpful tip for editing

---

### 4. Landscape Mode 📱➡️

**How It Works**:
1. Rotate your device to landscape
2. Screen automatically adapts
3. **Swipe up/down** to scroll if content exceeds screen

**Features**:
- ✅ All elements remain accessible
- ✅ Edit panel stays visible
- ✅ Measurements still show
- ✅ Smooth scrolling
- ✅ No content cut off

**Auto-Detect**:
- Portrait → Normal view (no scroll)
- Landscape → Scrollable view (if needed)

---

## 📋 Complete Feature Checklist

### Editing (All Elements)
- [x] Zones - Double-tap to edit (name, size, color)
- [x] Walls - Double-tap to view info
- [x] Doors - Double-tap to edit (name)
- [x] Anchors - Double-tap to edit (ID, name)
- [x] Worker Tags - Double-tap to edit (ID, name)
- [x] Vehicle Tags - Double-tap to edit (ID, name)
- [x] Equipment Tags - Double-tap to edit (ID, name)
- [x] Asset Tags - Double-tap to edit (ID, name)

### Measurements
- [x] Configure map scale
- [x] Choose unit (m/cm/ft)
- [x] Show/hide toggle
- [x] Width display on zones
- [x] Height display on zones
- [x] Real-time conversion

### Responsive
- [x] Portrait mode optimized
- [x] Landscape mode with scroll
- [x] All screen sizes supported

---

## 🎬 Step-by-Step Tutorial

### Tutorial 1: Setting Up Your Floor Plan Measurements

**Goal**: Configure map to show real-world measurements

**Steps**:

1. **Measure Your Floor Plan**
   - Example: Your floor plan image is 2000 pixels wide
   - Real warehouse is 50 meters wide
   
2. **Calculate Scale**
   ```
   Scale = Real Size ÷ Pixel Size
   Scale = 50m ÷ 2000px
   Scale = 0.025 meters per pixel
   ```

3. **Open Map Config**
   - Tap ruler icon in AppBar
   
4. **Enter Scale**
   - Type: `0.025`
   - Select unit: `Meters (m)`
   - Enable: ☑ Show measurements
   
5. **Save**
   - Tap Save button
   - Measurements appear on zones!

6. **Verify**
   - Add a zone 400px wide
   - Should show: "10.00m" (400 × 0.025 = 10m) ✓

---

### Tutorial 2: Using Different Units

**Scenario**: Client prefers feet instead of meters

**Steps**:

1. **Open Map Config**
   - Tap ruler icon
   
2. **Change Unit**
   - Dropdown: Select "Feet (ft)"
   - Keep same scale: `0.025`
   
3. **Save**
   - Measurements auto-convert
   - 10.00m → 32.81ft ✓

---

### Tutorial 3: Creating Precise Zones

**Goal**: Create a zone exactly 5m × 4m

**Steps**:

1. **Calculate Pixels Needed**
   ```
   If scale = 0.025 (1px = 2.5cm):
   Width = 5m ÷ 0.025 = 200 pixels
   Height = 4m ÷ 0.025 = 160 pixels
   ```

2. **Add Zone**
   - Tap Edit mode
   - Side panel: Add Zone
   
3. **Edit Zone**
   - Double-tap new zone
   - Set Width: `200`
   - Set Height: `160`
   - Name: "Storage Area"
   
4. **Verify**
   - Width badge shows: "5.00m" ✓
   - Height badge shows: "4.00m" ✓

---

## 🔧 Common Use Cases

### Use Case 1: Warehouse Mapping
**Requirements**:
- Large facility
- Metric system
- Detailed measurements

**Configuration**:
```
Scale: 0.025 (1px = 2.5cm)
Unit: Meters (m)
Show Measurements: ✓ Enabled
```

**Example Zone**:
- 800px × 600px zone
- Shows: 20.00m × 15.00m
- Perfect for tracking pallets and forklifts

---

### Use Case 2: Office Floor Plan
**Requirements**:
- Smaller rooms
- Centimeter precision
- Detailed layout

**Configuration**:
```
Scale: 0.01 (1px = 1cm)
Unit: Centimeters (cm)
Show Measurements: ✓ Enabled
```

**Example Zone**:
- 400px × 300px zone
- Shows: 400cm × 300cm
- Great for desk and equipment placement

---

### Use Case 3: Factory (US Standards)
**Requirements**:
- Large industrial facility
- Imperial units
- Feet preferred

**Configuration**:
```
Scale: 0.05 (1px = 5cm)
Unit: Feet (ft)
Show Measurements: ✓ Enabled
```

**Example Zone**:
- 600px × 400px zone
- Shows: 98.43ft × 65.62ft
- Ideal for US-based facilities

---

## 💡 Pro Tips

### Tip 1: Quick Scale Calculation
Use this formula:
```
Scale = (Real Width in meters) ÷ (Image Width in pixels)
```

**Example**:
- Image: 1500px wide
- Real: 30m wide
- Scale: 30 ÷ 1500 = 0.02

### Tip 2: Hiding Measurements for Clean View
When presenting to clients:
1. Map Config → Uncheck "Show measurements"
2. Screenshot with clean zone names only
3. Re-enable for editing

### Tip 3: Testing Your Scale
1. Add a test zone
2. Set width to 100 pixels
3. Check measurement badge
4. Should match: 100 × your scale
5. Adjust scale if needed

### Tip 4: Landscape Mode for Large Maps
- Rotate device to landscape
- Gives more horizontal space
- Scroll vertically for full view
- Great for presentations

### Tip 5: Wall Info for Planning
- Double-tap walls to see exact length
- Use for planning door placement
- Calculate material needs
- Verify floor plan accuracy

---

## ❓ Troubleshooting

### Issue: Measurements Show Wrong Values
**Solution**:
1. Check your scale calculation
2. Verify: Scale = Real Size ÷ Pixel Size
3. Re-enter correct scale in Map Config
4. Save changes

### Issue: Measurements Not Visible
**Solution**:
1. Map Config → Check "Show measurements" is enabled
2. Make sure zone is large enough (badges need space)
3. Try different color zone (black badges on dark zones)

### Issue: Landscape Mode Not Scrolling
**Solution**:
1. Make sure you rotated device fully
2. Swipe with one finger (not two)
3. Content must exceed screen height
4. Try adding more elements

### Issue: Can't Edit Wall
**Solution**:
1. Walls show info only (by design)
2. To modify: Delete and redraw
3. Or drag wall endpoints in edit mode
4. Double-tap shows current properties

---

## 🎯 Quick Reference

### AppBar Icons
| Icon | Name | Function |
|------|------|----------|
| 📏 Ruler | Map Config | Open measurement settings |
| 📄 File | Import | Upload floor plan image |
| 📑 PDF | Export | Generate PDF report |
| ✏️ Edit | Edit Mode | Enable/disable editing |

### Keyboard Shortcuts (Edit Mode)
| Key | Action |
|-----|--------|
| Delete | Remove selected element |
| Double-tap | Edit element properties |
| Drag | Move element |
| Tap | Select element |

### Measurement Units
| Unit | Abbreviation | Best For |
|------|--------------|----------|
| Meters | m | Warehouses, large facilities |
| Centimeters | cm | Offices, detailed layouts |
| Feet | ft | US facilities, imperial system |

---

## 📞 Need Help?

### Common Questions

**Q: How do I know if my scale is correct?**  
A: Measure a known distance on your floor plan. If a 10m wall shows as 400px, your scale should be 10÷400 = 0.025.

**Q: Can I use different units for different zones?**  
A: No, the unit applies to all measurements. Change it in Map Config to convert all at once.

**Q: Do measurements affect PDF export?**  
A: Currently measurements show on screen only. Future update may include them in PDF.

**Q: Can I edit wall thickness or color?**  
A: Wall properties are set when created. Delete and recreate to change properties.

**Q: Why do some zones not show measurements?**  
A: Very small zones (< 30px) may not have space for badges. Zoom in or increase zone size.

---

## ✅ Next Steps

1. **Configure Your Map**
   - Open Map Config
   - Enter your scale
   - Choose preferred unit
   
2. **Test It Out**
   - Create a test zone
   - Verify measurements match expectations
   - Adjust scale if needed

3. **Start Mapping**
   - Add zones for different areas
   - Place walls for boundaries
   - Add doors, anchors, tags
   
4. **Export and Share**
   - Generate PDF report
   - Share with team
   - Use for facility management

---

**Happy Mapping! 🗺️**

For technical details, see: `IMPROVEMENTS_COMPLETED.md`
