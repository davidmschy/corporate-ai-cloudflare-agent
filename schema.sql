-- Corporate AI Agent Database Schema
-- Cloudflare D1

-- Conversations with David
CREATE TABLE conversations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chat_id TEXT NOT NULL,
  message TEXT NOT NULL,
  response TEXT,
  timestamp INTEGER NOT NULL,
  context TEXT -- JSON metadata
);

-- Projects
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'active',
  priority INTEGER DEFAULT 3,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Tasks
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  project_id TEXT,
  title TEXT NOT NULL,
  status TEXT DEFAULT 'todo',
  assigned_to TEXT,
  due_date INTEGER,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Notes/Memory
CREATE TABLE memory (
  id TEXT PRIMARY KEY,
  category TEXT, -- 'business', 'personal', 'project', 'contact'
  content TEXT NOT NULL,
  tags TEXT, -- JSON array
  created_at INTEGER NOT NULL
);

-- Heartbeats
CREATE TABLE heartbeats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  status TEXT
);

-- Indexes
CREATE INDEX idx_conversations_chat ON conversations(chat_id);
CREATE INDEX idx_conversations_time ON conversations(timestamp);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_tasks_project ON tasks(project_id);
