# 🔐 Demo Login Credentials

## Test Account for Development

Use these credentials to test the app without Supabase configuration:

```
Email:    test@1.com
Password: 123456
```

## Features Available

When logged in with the demo account, you have:

- ✅ **Full Admin Access** - All features unlocked
- ✅ **Dashboard** - View system statistics
- ✅ **Door Control** - Manage door access (UI only, no hardware connection)
- ✅ **Settings** - Configure app preferences
- ✅ **All UI Features** - Test complete user interface

## How to Login

### On Real Android Device:

1. **Connect your device** (USB Debugging enabled)
2. **Run the app:**
   ```bash
   flutter run -d android
   ```
   Or double-click:
   ```
   run_device.bat
   ```

3. **Enter credentials** on login screen:
   - Email: `test@1.com`
   - Password: `123456`

4. **Tap "Login"** button

5. ✅ You're in! Explore the dashboard

### On Web Browser:

```bash
flutter run -d chrome
```

Then use the same credentials.

### On Windows Desktop:

```bash
flutter run -d windows
```

## Important Notes

⚠️ **This is a DEMO MODE for testing only**

- No actual Supabase authentication happens
- Data is not saved to cloud
- Restarting the app will reset any changes
- Hardware features (door control, RTLS) won't work without backend setup

## Production Setup

To enable full functionality:

1. Create Supabase account at https://supabase.com
2. Create a new project
3. Update credentials in `lib/utils/constants.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```
4. Run database setup from `SETUP_GUIDE.md`
5. Create users through Supabase Dashboard or sign-up feature

## Demo User Details

- **Name:** Demo User
- **Role:** Admin (full access)
- **User ID:** demo-user-id-12345
- **Email:** test@1.com
- **Status:** Active

## Quick Start

```bash
# 1. Check devices
flutter devices

# 2. Run on Android
flutter run -d android

# 3. Login with:
#    Email: test@1.com
#    Password: 123456

# 4. Enjoy testing! 🚀
```

---

**Happy Testing! 📱✨**
