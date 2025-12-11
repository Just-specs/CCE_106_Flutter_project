# RLS POLICY ERROR - SIGNUP BLOCKED

## Error Message
\\\
new row violates row-level security policy for table users
\\\

## What This Means
When you try to register a new account, the app tries to create a user profile in the \public.users\ table, but Supabase's Row Level Security (RLS) policy is blocking the insert.

---

## Root Cause

The RLS policy requires:
\\\sql
WITH CHECK (auth.uid() = id)
\\\

**Problem:** During signup, there can be a timing issue where:
1. Auth user is created
2. Your app tries to insert profile
3. \uth.uid()\ might not be properly set yet
4. RLS blocks the insert

---

## Solution Options

### ✅ Option 1: Fix RLS Policies (RECOMMENDED)

Run this in **Supabase Dashboard → SQL Editor**:

\\\sql
-- Drop old policies
DROP POLICY IF EXISTS "Enable insert for authenticated users during signup" ON public.users;

-- Create new policy with TO authenticated
CREATE POLICY "Enable insert for authenticated users during signup"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Verify
 qf
\\\

### ✅ Option 2: Disable RLS Temporarily (QUICK FIX)

Run this in **Supabase Dashboard → SQL Editor**:

\\\sql
-- Disable RLS for users table
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Verify
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';
\\\

**Note:** This removes all security checks. Only use for testing!

### ✅ Option 3: Use Service Role Key (NOT RECOMMENDED)

Change your app to use the service_role key instead of anon key for profile creation. This bypasses RLS but is a security risk.

---

## Step-by-Step Fix

### 1. Go to Supabase Dashboard
- Open your project at https://supabase.com/dashboard

### 2. Open SQL Editor
- Click "SQL Editor" in the left sidebar
- Click "New Query"

### 3. Run This SQL

**For Production (Recommended):**
\\\sql
-- Fix the RLS policy
DROP POLICY IF EXISTS "Enable insert for authenticated users during signup" ON public.users;

CREATE POLICY "Enable insert for authenticated users during signup"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);
\\\

**For Testing Only:**
\\\sql
-- Disable RLS temporarily
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
\\\

### 4. Test Signup
- Run your Flutter app
- Try to register with a new email
- Should work now!

---

## Verification

### Check if RLS is enabled:
\\\sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'users';
\\\

### Check policies:
\\\sql
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'users';
\\\

### Expected output:
| policyname | cmd | roles | qual | with_check |
|------------|-----|-------|------|------------|
| Enable insert for authenticated users during signup | INSERT | {authenticated} | NULL | (auth.uid() = id) |
| Users can view own profile | SELECT | {authenticated} | (auth.uid() = id) | NULL |
| Users can update own profile | UPDATE | {authenticated} | (auth.uid() = id) | NULL |

---

## Alternative: Use Database Trigger

Create a trigger that automatically creates the profile when a user signs up:

\\\sql
-- Create a function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS \$\$
BEGIN
  INSERT INTO public.users (id, email, full_name, role, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    'user',
    NOW()
  );
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
\\\

**Advantage:** Profile is created automatically by the database, bypassing RLS issues.

---

## Files Created

1. **FIX_RLS_POLICY.sql** - Full policy fix with verification
2. **QUICK_FIX_DISABLE_RLS.sql** - Quick temporary fix
3. **RLS_POLICY_ERROR_FIX.md** - This documentation

---

## Recommendation

**For immediate testing:**
1. Run \QUICK_FIX_DISABLE_RLS.sql\ to disable RLS
2. Test signup - should work immediately

**For production:**
1. Run \FIX_RLS_POLICY.sql\ to fix policies properly
2. Or implement the database trigger approach

---

## Summary

| Method | Security | Complexity | Recommended |
|--------|----------|------------|-------------|
| Fix RLS Policies | ✅ High | ⭐ Easy | ✅ Yes |
| Disable RLS | ❌ None | ⭐ Very Easy | ⚠️ Testing Only |
| Database Trigger | ✅ High | ⭐⭐ Medium | ✅ Yes (Best) |
| Service Role Key | ⚠️ Medium | ⭐⭐ Medium | ❌ No |

**Next Step:** Go to Supabase SQL Editor and run one of the SQL scripts!

