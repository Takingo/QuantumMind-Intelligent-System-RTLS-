# 🚀 Supabase Quick Start - 5 Minutes Setup

## ⚡ Super Fast Setup (For Experienced Developers)

### 1️⃣ Create Supabase Project (2 min)
```
1. Go to: https://supabase.com
2. Create Project: "QuantumMind RTLS"
3. Copy: Project URL + anon key
```

### 2️⃣ Execute SQL (1 min)
Run this in Supabase SQL Editor:
```sql
-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL DEFAULT 'User',
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    last_login_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT valid_role CHECK (role IN ('Admin', 'User', 'Viewer'))
);

CREATE TABLE public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uid TEXT UNIQUE NOT NULL,
    secret_key TEXT NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    user_name TEXT,
    active BOOLEAN DEFAULT true,
    access_level TEXT DEFAULT 'user',
    department TEXT,
    description TEXT,
    last_x DOUBLE PRECISION,
    last_y DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    last_seen_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT valid_access_level CHECK (access_level IN ('admin', 'user', 'blocked'))
);

CREATE TABLE public.rtls_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    node_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    x DOUBLE PRECISION NOT NULL,
    y DOUBLE PRECISION NOT NULL,
    z DOUBLE PRECISION DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    floor_level INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    last_seen_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE public.doors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    threshold DOUBLE PRECISION DEFAULT 1.5,
    relay_pin INTEGER NOT NULL,
    status TEXT DEFAULT 'closed',
    is_enabled BOOLEAN DEFAULT true,
    location TEXT,
    open_duration INTEGER DEFAULT 3000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    last_triggered_at TIMESTAMP WITH TIME ZONE,
    last_triggered_by UUID,
    CONSTRAINT valid_status CHECK (status IN ('open', 'closed', 'locked'))
);

CREATE TABLE public.sensor_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_type TEXT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    unit TEXT,
    location TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    metadata JSONB
);

CREATE TABLE public.logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    log_type TEXT NOT NULL,
    severity TEXT DEFAULT 'info',
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    tag_id UUID REFERENCES public.tags(id) ON DELETE SET NULL,
    door_id UUID REFERENCES public.doors(id) ON DELETE SET NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT valid_severity CHECK (severity IN ('info', 'warning', 'error', 'critical'))
);

CREATE TABLE public.zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    zone_type TEXT DEFAULT 'safe',
    polygon JSONB NOT NULL,
    floor_level INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT valid_zone_type CHECK (zone_type IN ('safe', 'restricted', 'danger', 'neutral'))
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rtls_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sensor_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zones ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Authenticated users can view all users" ON public.users FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view tags" ON public.tags FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can insert tags" ON public.tags FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update tags" ON public.tags FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view nodes" ON public.rtls_nodes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view doors" ON public.doors FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can update doors" ON public.doors FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view sensor data" ON public.sensor_data FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can insert sensor data" ON public.sensor_data FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view logs" ON public.logs FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can insert logs" ON public.logs FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can view zones" ON public.zones FOR SELECT USING (auth.role() = 'authenticated');

-- Success
SELECT 'Setup complete!' AS status;
```

### 3️⃣ Configure App (1 min)
**Edit:** `lib/utils/constants.dart`
```dart
// Line 10-11: Replace with your credentials
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOi...your_key_here';
```

**Edit:** `lib/main.dart`
```dart
// Line 27-33: Uncomment this block
try {
  await SupabaseService.initialize();
  debugPrint('✅ Supabase initialized successfully!');
} catch (e) {
  debugPrint('❌ Supabase initialization error: $e');
}
```

### 4️⃣ Run & Test (1 min)
```bash
flutter pub get
flutter run -d chrome
```

**Login with:**
- Email: `test@1.com`
- Password: `123456`

---

## ✅ Verification

You should see in console:
```
✅ Supabase initialized successfully!
```

And be able to login and see the dashboard!

---

## 🎯 Optional: Create Real User

In Supabase Dashboard → Authentication → Users:
```
Click "Add User"
Email: your-email@example.com
Password: YourSecurePassword123!
Auto Confirm: ON
```

Then login with these credentials!

---

## 📚 Full Documentation

For detailed setup and troubleshooting:
- See: `SUPABASE_SETUP_GUIDE.md`
- Checklist: `SUPABASE_INTEGRATION_CHECKLIST.md`

---

## 🐛 Quick Troubleshooting

**Issue:** "Invalid API credentials"
```
→ Double-check URL and key in constants.dart
→ Ensure no extra spaces or quotes
```

**Issue:** "Connection timeout"
```
→ Check internet connection
→ Verify Supabase project is active
```

**Issue:** "RLS policy violation"
```
→ Re-run the SQL script above
→ Check Authentication tab for test user
```

---

## 🎉 Done!

You're now connected to Supabase and ready to:
- ✅ Authenticate users
- ✅ Store real-time data
- ✅ Manage tags and sensors
- ✅ Track access logs

**Next:** Configure MQTT for ESP32 real-time data!
