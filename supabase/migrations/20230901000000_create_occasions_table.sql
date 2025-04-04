-- Create occasions table
CREATE TABLE IF NOT EXISTS occasions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  person_name TEXT NOT NULL,
  date DATE NOT NULL,
  relation_type TEXT NOT NULL,
  description TEXT,
  reminders JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS occasions_user_id_idx ON occasions(user_id);
CREATE INDEX IF NOT EXISTS occasions_date_idx ON occasions(date);

-- Add RLS (Row Level Security) policies
ALTER TABLE occasions ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to select only their own occasions
CREATE POLICY select_own_occasions ON occasions
  FOR SELECT USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own occasions
CREATE POLICY insert_own_occasions ON occasions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own occasions
CREATE POLICY update_own_occasions ON occasions
  FOR UPDATE USING (auth.uid() = user_id);

-- Create policy to allow users to delete their own occasions
CREATE POLICY delete_own_occasions ON occasions
  FOR DELETE USING (auth.uid() = user_id);
