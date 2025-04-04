-- Create gift_recommendations table
CREATE TABLE IF NOT EXISTS gift_recommendations (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  occasion_id UUID NOT NULL REFERENCES occasions(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2),
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Add RLS (Row Level Security) policies
ALTER TABLE gift_recommendations ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to select only their own gift recommendations
CREATE POLICY "Users can view their own gift recommendations"
  ON gift_recommendations
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy to allow users to insert their own gift recommendations
CREATE POLICY "Users can insert their own gift recommendations"
  ON gift_recommendations
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to update their own gift recommendations
CREATE POLICY "Users can update their own gift recommendations"
  ON gift_recommendations
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy to allow users to delete their own gift recommendations
CREATE POLICY "Users can delete their own gift recommendations"
  ON gift_recommendations
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS gift_recommendations_user_id_idx ON gift_recommendations(user_id);
CREATE INDEX IF NOT EXISTS gift_recommendations_occasion_id_idx ON gift_recommendations(occasion_id);
