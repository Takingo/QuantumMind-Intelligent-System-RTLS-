# 🚀 Supabase Integration Guide - QuantumMind RTLS

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase Project Setup](#supabase-project-setup)
3. [Database Schema Creation](#database-schema-creation)
4. [Row Level Security (RLS) Configuration](#row-level-security-rls-configuration)
5. [Application Configuration](#application-configuration)
6. [Testing the Integration](#testing-the-integration)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

Before starting, ensure you have:
- ✓ Supabase account (free tier is sufficient)
- ✓ Flutter SDK installed and working
- ✓ Project dependencies installed (`flutter pub get`)

---

## 🎯 Supabase Project Setup

### Step 1: Create a Supabase Project

1. **Visit Supabase**
   - Go to: https://supabase.com
   - Sign in or create a free account

2. **Create New Project**
   - Click "New Project"
   - Fill in the details:
     - **Name**: QuantumMind RTLS
     - **Database Password**: Choose a strong password (SAVE THIS!)
     - **Region**: Select closest to your location
     - **Pricing Plan**: Free (sufficient for testing)

3. **Wait for Initialization**
   - Project setup takes ~2 minutes
   - You'll see a "Setting up project..." message

### Step 2: Get Your API Credentials

Once your project is ready:

1. **Navigate to Settings**
   - Click on the gear icon (⚙️) at bottom left
   - Select "API" from the menu

2. **Copy These Values:**
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon/public key**: Long string starting with `eyJ...`

📝 **Save these values - you'll need them soon!**

---

## 🗄️ Database Schema Creation

### Step 3: Create Database Tables

1. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

2. **Execute This SQL Script:**

```sql
-- =====================================================
-- QUANTUMMIND RTLS DATABASE SCHEMA
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.users (
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

-- =====================================================
-- 2. UWB TAGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tags (
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

-- =====================================================
-- 3. RTLS NODES (ANCHORS) TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.rtls_nodes (
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

-- =====================================================
-- 4. DOORS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.doors (
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

-- =====================================================
-- 5. SENSOR DATA TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sensor_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sensor_type TEXT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    unit TEXT,
    location TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    metadata JSONB
);

-- =====================================================
-- 6. ACCESS LOGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.logs (
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

-- =====================================================
-- 7. ZONES TABLE (GEO-FENCING)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    zone_type TEXT DEFAULT 'safe',
    polygon JSONB NOT NULL,
    floor_level INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT valid_zone_type CHECK (zone_type IN ('safe', 'restricted', 'danger', 'neutral'))
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_tags_user_id ON public.tags(user_id);
CREATE INDEX idx_tags_active ON public.tags(active);
CREATE INDEX idx_logs_created_at ON public.logs(created_at DESC);
CREATE INDEX idx_logs_severity ON public.logs(severity);
CREATE INDEX idx_sensor_data_timestamp ON public.sensor_data(timestamp DESC);
CREATE INDEX idx_doors_status ON public.doors(status);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'Database schema created successfully!' AS status;
```

3. **Run the Query**
   - Click "Run" button (or press F5)
   - Verify you see: "Database schema created successfully!"

---

## 🔒 Row Level Security (RLS) Configuration

### Step 4: Enable RLS and Create Policies

**Execute this SQL to enable security:**

```sql
-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rtls_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sensor_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zones ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES - USERS TABLE
-- =====================================================

-- Allow users to read their own data
CREATE POLICY "Users can view own data"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- Allow authenticated users to read all users (for admin panel)
CREATE POLICY "Authenticated users can view all users"
    ON public.users FOR SELECT
    USING (auth.role() = 'authenticated');

-- Allow users to update their own data
CREATE POLICY "Users can update own data"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- =====================================================
-- RLS POLICIES - TAGS TABLE
-- =====================================================

-- Allow all authenticated users to read tags
CREATE POLICY "Authenticated users can view tags"
    ON public.tags FOR SELECT
    USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert tags
CREATE POLICY "Authenticated users can insert tags"
    ON public.tags FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update tags
CREATE POLICY "Authenticated users can update tags"
    ON public.tags FOR UPDATE
    USING (auth.role() = 'authenticated');

-- =====================================================
-- RLS POLICIES - OTHER TABLES (READ-ONLY FOR NOW)
-- =====================================================

-- RTLS Nodes
CREATE POLICY "Authenticated users can view nodes"
    ON public.rtls_nodes FOR SELECT
    USING (auth.role() = 'authenticated');

-- Doors
CREATE POLICY "Authenticated users can view doors"
    ON public.doors FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update doors"
    ON public.doors FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Sensor Data
CREATE POLICY "Authenticated users can view sensor data"
    ON public.sensor_data FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert sensor data"
    ON public.sensor_data FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Logs
CREATE POLICY "Authenticated users can view logs"
    ON public.logs FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert logs"
    ON public.logs FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Zones
CREATE POLICY "Authenticated users can view zones"
    ON public.zones FOR SELECT
    USING (auth.role() = 'authenticated');

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'RLS policies configured successfully!' AS status;
```

---

## ⚙️ Application Configuration

### Step 5: Configure Your Flutter App

1. **Open the constants file:**
   - Navigate to: `lib/utils/constants.dart`

2. **Replace the placeholder values:**

```dart
// ========== Supabase Configuration ==========
static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
```

**Example:**
```dart
// ========== Supabase Configuration ==========
static const String supabaseUrl = 'https://abcdefghijk.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

3. **Enable Supabase Initialization:**
   - Open: `lib/main.dart`
   - Find the commented block (lines 27-33)
   - Uncomment it:

```dart
// Uncomment below when Supabase is properly configured:
try {
  await SupabaseService.initialize();
} catch (e) {
  debugPrint('Supabase initialization error: $e');
}
```

Should become:

```dart
// Initialize Supabase
try {
  await SupabaseService.initialize();
  debugPrint('✅ Supabase initialized successfully!');
} catch (e) {
  debugPrint('❌ Supabase initialization error: $e');
}
```

---

## 🧪 Testing the Integration

### Step 6: Test Database Connection

**Option A: Create Test User via Supabase Dashboard**

1. Go to Authentication > Users
2. Click "Add User"
3. Create a test user:
   - Email: `test@quantummind.com`
   - Password: `Test123456!`
   - Auto Confirm: ON

**Option B: Use Demo Credentials**

The app already supports demo mode:
- Email: `test@1.com`
- Password: `123456`

### Step 7: Run Your App

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Or run on Windows
flutter run -d windows
```

### Step 8: Verify Connection

Watch the console for:
```
✅ Supabase initialized successfully!
```

If you see errors, check the Troubleshooting section below.

---

## 🔧 Troubleshooting

### Common Issues

#### ❌ "Invalid API credentials"
**Solution:**
- Verify you copied the correct URL and anon key
- Make sure there are no extra spaces
- Check that the URL starts with `https://`

#### ❌ "Connection timeout"
**Solution:**
- Check your internet connection
- Verify your Supabase project is active
- Try restarting the app

#### ❌ "RLS policy violation"
**Solution:**
- Re-run the RLS configuration SQL
- Ensure you're authenticated before accessing data

#### ❌ "Table does not exist"
**Solution:**
- Re-run the database schema SQL
- Check for SQL errors in the query execution

### Additional Help

**Check Supabase Logs:**
1. Go to Supabase Dashboard
2. Select "Logs" from left sidebar
3. Choose "Postgres Logs" or "Auth Logs"
4. Look for errors

**Enable Debug Mode:**
```dart
// In lib/main.dart
debugPrint('🔍 Debug mode enabled');
```

---

## 📚 Next Steps

Once Supabase is configured:

1. ✅ **Create your first user** (via Auth or SQL)
2. ✅ **Test authentication** (login/logout)
3. ✅ **Add sample tags** (via dashboard)
4. ✅ **Configure MQTT** for real-time updates
5. ✅ **Deploy to production**

---

## 🎉 Success!

You've successfully configured Supabase for QuantumMind RTLS!

**What You Can Do Now:**
- ✓ User authentication
- ✓ Real-time database sync
- ✓ Tag management
- ✓ Access logs
- ✓ Sensor data storage
- ✓ Geo-fencing zones

---

## 📞 Support

Need help? Check:
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- Project README.md

---

**Created by:** QuantumMind Innovation Team  
**Last Updated:** December 2024  
**Version:** 1.0.0
