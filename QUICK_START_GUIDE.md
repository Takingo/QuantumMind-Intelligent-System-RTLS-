# QuantumMind RTLS - Quick Start Guide

## 🚀 How to Run the App

### Method 1: Using Flutter Command
```bash
flutter run -d android
```

### Method 2: Hot Restart (if app already running)
Press: **Ctrl + Shift + F5** (or **R** in terminal)

### Method 3: Clean Restart (if issues occur)
```bash
flutter clean
flutter pub get
flutter run -d android
```

---

## 🔐 Login Credentials

**Email:** `test@1.com`  
**Password:** `123456`

---

## 🎯 Quick Feature Test Checklist

### ✅ Access Logs (Giriş-Çıkış Kayıtları)
- [ ] Open Dashboard → Tap "Access Logs"
- [ ] Filter by: All / Entry / Exit
- [ ] Check statistics (Total, Entries, Exits)
- [ ] View personnel details in each card
- [ ] See timestamps and locations

### ✅ RTLS Map Editing
- [ ] Open Dashboard → Tap "RTLS Map"
- [ ] Tap **Edit** icon (✏️) in app bar
- [ ] Tap a tag to select it (red border appears)
- [ ] Drag tag to new position
- [ ] Tap **Delete Tag** button (when tag selected)
- [ ] Confirm deletion
- [ ] Tap **Done** (✓) to exit edit mode
- [ ] Tap **+ Add Tag** to add new tag

### ✅ Dark/Light Mode
- [ ] Open Settings
- [ ] Tap "Dark Mode" toggle
- [ ] Watch app change theme instantly
- [ ] Toggle back to confirm it works both ways

### ✅ Auto Backup
- [ ] Open Settings → System section
- [ ] Toggle "Auto Backup" ON
- [ ] See confirmation message
- [ ] Tap "Backup Now"
- [ ] Wait for loading indicator
- [ ] See "Backup completed successfully" message
- [ ] Check last backup timestamp appears

### ✅ Notifications
- [ ] Open Settings → Notifications section
- [ ] Toggle "Enable Notifications"
- [ ] See confirmation message

---

## 📱 App Navigation Map

```
[Splash Screen]
    ↓ (3 seconds)
[Login Screen]
    ↓ (test@1.com / 123456)
[Dashboard]
    ├─→ [Access Logs] ← NEW!
    │     ├─ Filter: All/Entry/Exit
    │     ├─ View details
    │     └─ Export logs
    │
    ├─→ [RTLS Map] ← ENHANCED!
    │     ├─ View mode (default)
    │     ├─ Edit mode (drag & delete)
    │     └─ Add new tags
    │
    └─→ [Settings] ← ENHANCED!
          ├─ Dark/Light Mode ← WORKING!
          ├─ Notifications ← WORKING!
          ├─ Auto Backup ← WORKING!
          ├─ Language
          ├─ Refresh Rate
          └─ Logout
```

---

## 🎨 Feature Highlights

### 1. Access Logs (NEW)
- **What it replaces:** Door Control
- **What it shows:** Entry/Exit records with:
  - Personnel name & ID
  - Department
  - Timestamp (date & time)
  - Location
  - Action type (Entry/Exit)
- **Filtering:** All / Entry / Exit
- **Statistics:** Total, Entries, Exits count

### 2. RTLS Map Editing (ENHANCED)
- **Edit Mode:** Toggle with ✏️ icon
- **Drag Tags:** Hold and drag to reposition
- **Delete Tags:** Select → Delete button → Confirm
- **Visual Feedback:** Selected tags have red border
- **Add Tags:** + button (always available)

### 3. Theme Switching (WORKING)
- **Toggle:** Settings → Dark Mode switch
- **Instant:** Theme changes immediately
- **Complete:** All screens update
- **Persistent:** Preference saved

### 4. Auto Backup (WORKING)
- **Auto Mode:** Daily automatic backups
- **Manual:** "Backup Now" button
- **Progress:** Loading indicator during backup
- **Feedback:** Success/failure messages
- **History:** Last backup timestamp

### 5. Notifications (WORKING)
- **Toggle:** Enable/Disable all notifications
- **Persistent:** Preference saved
- **Feedback:** Confirmation messages

---

## 🐛 Troubleshooting

### Splash Screen Stuck
**Solution:** Hot restart (**Ctrl + Shift + F5**)

### Theme Not Changing
**Solution:** 
1. Toggle the switch again
2. If still not working, hot restart

### Backup Not Working
**Solution:**
1. Check if toggle is ON
2. Wait for loading indicator
3. Check for success message

### Can't Drag Tags
**Solution:**
1. Make sure you're in **Edit Mode** (tap ✏️ icon)
2. Tap tag first to select it
3. Then drag

### App Won't Start
**Solution:**
```bash
flutter clean
flutter pub get
flutter run -d android
```

---

## 📝 Demo Data

### Access Logs - Sample Personnel
1. **Ahmet Yılmaz** - EMP-001 - Engineering
2. **Ayşe Kaya** - EMP-042 - HR
3. **Mehmet Demir** - EMP-015 - Operations
4. **Fatma Şahin** - EMP-028 - Finance
5. **Ali Yıldız** - EMP-033 - Engineering
6. **Zeynep Aksoy** - EMP-019 - Marketing

### RTLS Tags - Sample Tags
1. **Worker-1** (001) - Active
2. **Worker-2** (002) - Active
3. **Forklift-1** (003) - Active
4. **Cart-1** (004) - Inactive

---

## ✨ Pro Tips

1. **Access Logs Filtering:** Use filters to quickly find entries or exits
2. **RTLS Map:** Drag tags freely - positions auto-save
3. **Theme:** Test both modes to see which you prefer
4. **Backup:** Enable auto backup for peace of mind
5. **Edit Mode:** Exit edit mode (✓) to prevent accidental changes

---

## 🎯 All Features Working

- ✅ Splash Screen with animations
- ✅ Login with demo account
- ✅ Dashboard with statistics
- ✅ Access Logs (Entry/Exit tracking)
- ✅ RTLS Map (View & Edit modes)
- ✅ Theme Switching (Dark/Light)
- ✅ Auto Backup (Toggle & Manual)
- ✅ Notification Settings
- ✅ Settings Persistence

---

**Ready to test!** 🚀

Just run: `flutter run -d android`

Then login with: `test@1.com` / `123456`
