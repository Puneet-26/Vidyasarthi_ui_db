-- ==================== FIX BATCHES RLS POLICY ====================
-- Run this in Supabase SQL Editor
-- This allows anyone to insert/update/delete batches (since we use custom auth)

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Admins manage batches" ON batches;
DROP POLICY IF EXISTS "Everyone can view batches" ON batches;

-- Create open policies (since we handle auth in the app)
CREATE POLICY "Allow all select on batches" ON batches FOR SELECT USING (TRUE);
CREATE POLICY "Allow all insert on batches" ON batches FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow all update on batches" ON batches FOR UPDATE USING (TRUE);
CREATE POLICY "Allow all delete on batches" ON batches FOR DELETE USING (TRUE);

-- Verify policies
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'batches';
