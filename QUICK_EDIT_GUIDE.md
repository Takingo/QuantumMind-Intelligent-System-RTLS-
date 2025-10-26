# 🎯 Quick Guide: How to Edit Map Elements

## 🚀 Quick Start

### Enable Edit Mode First!
```
1. Open Advanced RTLS Map
2. Click ✏️ (Edit) icon in top-right app bar
3. Edit mode is now ON
```

---

## 📏 NEW: Measure Distance Between Zones

### Step-by-Step:
```
1. Click "Distance" tool (yellow 📏 icon)
2. Click first zone (e.g., "Assembly Area")
   → Message: "First zone selected..."
3. Click second zone (e.g., "Warehouse")
   → Yellow dashed line appears with distance!
```

### Visual:
```
Assembly Area [🔵]----------📏 12.50m----------[🔵] Warehouse
              (Blue)                              (Blue)
              
Distance badge: [📏 12.50m]  ← Shows in yellow badge
```

### Edit Distance Label:
```
1. Double-click the distance line
2. Edit "Custom Label" field
   - Enter custom text (e.g., "Main Corridor")
   - Or leave empty for auto distance
3. Click "Save"
```

---

## 🧱 Edit Walls (Two Methods)

### Method 1: Drag Endpoints
```
1. Click wall to select (turns RED)
2. Two circles appear:
   🔵 Blue = Start point
   🔴 Red = End point
3. Drag blue/red circles to adjust wall
4. Wall updates in real-time!
```

### Method 2: Precise Coordinates
```
1. Double-click wall
2. Edit coordinates:
   Start Point: X1, Y1
   End Point: X2, Y2
3. See live length calculation
4. Click "Save"
```

---

## 🔧 Edit Other Elements

### Zones (Areas)
```
Double-click zone → Edit:
- Name
- Width (pixels)
- Height (pixels)
- Color (blue/green/orange/purple/red)
```

### Doors
```
Double-click door → Edit:
- Door name
```

### Anchors (UWB)
```
Double-click anchor → Edit:
- Anchor ID (e.g., "A001")
- Anchor name
```

### Tags (Workers/Vehicles/Equipment/Assets)
```
Double-click tag → Edit:
- Tag ID (e.g., "W001", "V001")
- Tag name (e.g., "John Smith", "Forklift-A")
```

---

## 🗑️ Delete Elements

```
1. Click element to select (turns RED)
2. Click "Del" button in left side panel
   OR
   Click 🗑️ icon in top toolbar
3. Element removed immediately
```

---

## 🎨 Visual Indicators

### Selected Element
```
✅ Selected → RED border/highlight
❌ Not selected → Original color
```

### Draggable Points
```
When selected:
- Walls: 🔵 Blue + 🔴 Red circles
- Zones: Can drag entire zone
- Tags/Anchors/Doors: Can drag entire element
```

### Distance Lines
```
Normal: Yellow dashed line + yellow badge
Selected: RED dashed line + red badge
First zone selected: Waiting for second click
```

---

## 💡 Pro Tips

### Tip 1: Cancel Distance Measurement
```
Click same zone twice → Cancels measurement
OR
Click different drawing tool → Resets
```

### Tip 2: Precise Wall Editing
```
Use drag: Quick visual adjustment
Use dialog: Exact coordinates
```

### Tip 3: Map Scale Configuration
```
Click ⚙️ (Map Config) icon to set:
- Map scale (1px = ? meters)
- Measurement unit (m/cm/ft)
- Show/hide measurements
```

### Tip 4: Move Elements
```
Select element → Drag anywhere on element
(Except when in Distance mode)
```

---

## ⚠️ Common Issues

### "Can't edit element"
```
✅ Solution: Make sure Edit Mode is ON (✏️ icon)
```

### "Distance line not appearing"
```
✅ Solution: 
1. Check "Distance" tool is selected (yellow)
2. Click two DIFFERENT zones
```

### "Can't drag wall endpoints"
```
✅ Solution:
1. Click wall to SELECT it first (turns red)
2. Then drag blue/red circles
```

### "Element won't move"
```
✅ Solution:
- Exit Distance mode
- Make sure element is not a distance line
  (distance lines are automatic, can't be moved)
```

---

## 🎯 Workflow Example

### Complete Workflow: Add & Measure Factory Layout
```
1. Enable Edit Mode (✏️)

2. Add Zones:
   - Click "Zone" tool
   - Add "Assembly Area" (blue)
   - Add "Warehouse" (green)
   - Add "Office" (orange)

3. Add Walls:
   - Click "Wall" tool
   - Click start → Click end for each wall
   - Repeat for all walls

4. Measure Distances:
   - Click "Distance" tool
   - Assembly Area → Warehouse (creates line)
   - Warehouse → Office (creates line)

5. Edit Distance Labels:
   - Double-click "Assembly → Warehouse" line
   - Set label: "Main Corridor"
   - Save

6. Adjust Wall:
   - Click wall to select
   - Drag endpoints to correct position
   
7. Done! Exit Edit Mode (✏️)
```

---

## 📊 Element Summary

Bottom bar shows live count:
```
Tags: 2 | Zones: 3 | Walls: 8 | Doors: 4 | Anchors: 6 | Distances: 2
                                                           ↑↑↑↑↑↑↑↑↑↑
                                                           NEW!
```

---

**Remember**: All elements are now FULLY EDITABLE! 
**Question**: Need help? Double-click any element to edit it!

---

Last Updated: 2025-10-22
Version: Quick Guide v1.0
