CREATE TABLE IF NOT EXISTS broadcasts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  target_audience TEXT NOT NULL DEFAULT 'all',
  priority TEXT NOT NULL DEFAULT 'normal',
  sent_by TEXT NOT NULL DEFAULT 'Admin',
  sent_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE broadcasts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON broadcasts FOR ALL USING (true) WITH CHECK (true);

SELECT id, title, target_audience, priority, sent_date FROM broadcasts ORDER BY sent_date DESC LIMIT 5;
