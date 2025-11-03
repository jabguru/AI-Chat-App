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

_(Add screenshots here)_

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
git clone https://github.com/jabguru/AI-Chat-App.git
cd AI-Chat-App
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup

#### Create Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in your project details
4. Wait for the project to be created

#### Get API Credentials

1. In your Supabase project, go to **Settings** (gear icon)
2. Click **API** in the sidebar
3. Copy the following:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public** key (the `anon` key)

#### Setup Database

1. In your Supabase project, go to **SQL Editor**
2. Click **New Query**
3. Copy the entire content of `supabase_schema.sql` from this project
4. Paste it into the SQL editor
5. Click **Run** (or press Cmd/Ctrl + Enter)
6. You should see "Success. No rows returned" - that's good!

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
