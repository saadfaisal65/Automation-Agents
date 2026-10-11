-- Run once in your Postgres database
CREATE TABLE IF NOT EXISTS fb_settings (k text PRIMARY KEY, v text NOT NULL);
INSERT INTO fb_settings (k, v) VALUES ('panel_key', 'CHANGE_ME_LONG_RANDOM_KEY'), ('alert_url', '')
ON CONFLICT (k) DO NOTHING;

CREATE TABLE IF NOT EXISTS fb_accounts (
  id serial PRIMARY KEY,
  name text NOT NULL,
  page_id text UNIQUE NOT NULL,
  access_token text NOT NULL,          -- long-lived PAGE token
  active boolean DEFAULT true,
  daily_cap int DEFAULT 20,
  token_status text DEFAULT 'ok',
  paused_until timestamptz,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fb_jobs (
  id serial PRIMARY KEY,
  source_account_id int REFERENCES fb_accounts(id),
  post_type text, message text, media_url text,
  delay_min int, delay_max int,
  comment_mode text, share_enabled boolean,
  target_ids jsonb, languages jsonb,
  status text, fb_post_id text, permalink text, error text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS fb_actions (
  id serial PRIMARY KEY,
  job_id int REFERENCES fb_jobs(id),
  account_id int REFERENCES fb_accounts(id),
  action_type text,                    -- comment | share
  text text,
  run_at timestamptz,
  status text,                         -- pending_approval | scheduled | processing | done | failed | cancelled
  attempts int DEFAULT 0,
  last_error text, fb_result_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS fb_actions_due ON fb_actions (status, run_at);

-- Account add karne ka example:
-- INSERT INTO fb_accounts (name, page_id, access_token) VALUES ('My Page A', '1234567890', 'EAAB...');
