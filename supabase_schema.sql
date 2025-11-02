-- AI Chat App - Supabase Database Schema
-- Run this script in your Supabase SQL Editor

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create chat_sessions table
create table if not exists chat_sessions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create messages table
create table if not exists messages (
  id uuid default uuid_generate_v4() primary key,
  session_id uuid references chat_sessions(id) on delete cascade not null,
  content text not null,
  is_user boolean not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  audio_url text
);

-- Enable Row Level Security (RLS)
alter table chat_sessions enable row level security;
alter table messages enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Users can view their own chat sessions" on chat_sessions;
drop policy if exists "Users can create their own chat sessions" on chat_sessions;
drop policy if exists "Users can update their own chat sessions" on chat_sessions;
drop policy if exists "Users can delete their own chat sessions" on chat_sessions;
drop policy if exists "Users can view messages from their chat sessions" on messages;
drop policy if exists "Users can create messages in their chat sessions" on messages;

-- Chat Sessions Policies
create policy "Users can view their own chat sessions"
  on chat_sessions for select
  using (auth.uid() = user_id);

create policy "Users can create their own chat sessions"
  on chat_sessions for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own chat sessions"
  on chat_sessions for update
  using (auth.uid() = user_id);

create policy "Users can delete their own chat sessions"
  on chat_sessions for delete
  using (auth.uid() = user_id);

-- Messages Policies
create policy "Users can view messages from their chat sessions"
  on messages for select
  using (
    exists (
      select 1 from chat_sessions
      where chat_sessions.id = messages.session_id
      and chat_sessions.user_id = auth.uid()
    )
  );

create policy "Users can create messages in their chat sessions"
  on messages for insert
  with check (
    exists (
      select 1 from chat_sessions
      where chat_sessions.id = messages.session_id
      and chat_sessions.user_id = auth.uid()
    )
  );

-- Create indexes for better performance
create index if not exists chat_sessions_user_id_idx on chat_sessions(user_id);
create index if not exists chat_sessions_updated_at_idx on chat_sessions(updated_at desc);
create index if not exists messages_session_id_idx on messages(session_id);
create index if not exists messages_timestamp_idx on messages(timestamp);

-- Create function to update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Create trigger to automatically update updated_at
drop trigger if exists update_chat_sessions_updated_at on chat_sessions;
create trigger update_chat_sessions_updated_at
  before update on chat_sessions
  for each row
  execute function update_updated_at_column();
