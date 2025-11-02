# AI Chat App

A beautiful Flutter AI chat application with voice support, powered by OpenAI and Supabase.

## Features

- 🤖 **AI Conversations**: Chat with OpenAI's GPT-3.5 Turbo
- 🎤 **Voice Input**: Speak your messages using speech-to-text
- 🔊 **Voice Output**: Listen to AI responses with text-to-speech
- 💬 **Chat History**: View and manage your conversation history
- 🔐 **Authentication**: Secure email/password authentication with Supabase
- 🎨 **Beautiful UI**: Clean, modern interface with dark theme
- 📱 **Real-time Streaming**: See AI responses as they're generated

## Screenshots

*(Add screenshots here)*

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (Authentication & Database)
- **AI**: OpenAI GPT-3.5 Turbo
- **Voice**: 
  - `speech_to_text` for voice input
  - `flutter_tts` for text-to-speech

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Supabase Account ([Sign up here](https://supabase.com))
- OpenAI API Key ([Get one here](https://platform.openai.com/api-keys))

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ai_chat_app.git
cd ai_chat_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup

1. Create a new project on [Supabase](https://app.supabase.com)
2. Go to Project Settings > API
3. Copy your `Project URL` and `anon/public` key
4. Create the following tables in your Supabase database:

#### Chat Sessions Table

```sql
create table chat_sessions (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table chat_sessions enable row level security;

-- Create policies
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
```

#### Messages Table

```sql
create table messages (
  id uuid default uuid_generate_v4() primary key,
  session_id uuid references chat_sessions(id) on delete cascade not null,
  content text not null,
  is_user boolean not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  audio_url text
);

-- Enable RLS
alter table messages enable row level security;

-- Create policies
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
```

### 4. Configure Environment Variables

Update the configuration in `lib/config/env_config.dart`:

```dart
class EnvConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
}
```

### 5. iOS Specific Setup (for voice features)

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice input.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition for voice input.</string>
```

### 6. Android Specific Setup (for voice features)

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 7. Run the App

```bash
flutter run
```

## Usage

1. **Sign Up/Login**: Create an account or log in with your email and password
2. **Start Chatting**: Type a message or tap the microphone icon to speak
3. **Listen to Responses**: Tap the speaker icon on AI messages to hear them read aloud
4. **View History**: Open the drawer (tap the menu icon) to see all your chat sessions
5. **New Chat**: Tap the + icon in the app bar to start a new conversation

## Project Structure

```
lib/
├── config/
│   └── env_config.dart          # Environment configuration
├── models/
│   ├── message.dart             # Message model
│   └── chat_session.dart        # Chat session model
├── screens/
│   ├── welcome.dart             # Welcome screen
│   ├── login.dart               # Login screen
│   ├── create_account.dart      # Sign up screen
│   └── chat_screen.dart         # Main chat interface
├── services/
│   ├── supabase_service.dart    # Supabase integration
│   ├── openai_service.dart      # OpenAI integration
│   └── voice_service.dart       # Voice input/output
├── theme/
│   ├── colors.dart              # App colors
│   └── theme.dart               # Theme configuration
├── widgets/
│   └── ...                      # Reusable widgets
└── main.dart                    # App entry point
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for the GPT-3.5 Turbo API
- Supabase for backend infrastructure
- Flutter team for the amazing framework
