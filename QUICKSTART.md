# Quick Start Guide

This guide will help you get the AI Chat App up and running quickly.

## Step-by-Step Setup

### 1. Prerequisites Check

Make sure you have:
- ✅ Flutter SDK installed (`flutter --version`)
- ✅ A Supabase account
- ✅ An OpenAI API key

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup (5 minutes)

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

### 4. OpenAI Setup (2 minutes)

1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign in or create an account
3. Go to **API Keys** section
4. Click **Create new secret key**
5. Copy the key (you won't be able to see it again!)
6. Note: You'll need to add billing information to use the API

### 5. Configure the App

Open `lib/config/env_config.dart` and replace the placeholder values:

```dart
class EnvConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co'; // Your Supabase URL
  static const String supabaseAnonKey = 'eyJhbGc...'; // Your Supabase anon key
  static const String openAiApiKey = 'sk-...'; // Your OpenAI API key
}
```

### 6. Run the App

```bash
flutter run
```

Choose your device/emulator when prompted.

## First Run

1. The app will open on the Welcome screen
2. Click **Create Account**
3. Enter your email and password
4. Accept the terms and click **Continue**
5. You'll be taken to the chat screen
6. Start chatting!

## Testing Voice Features

### On iOS Simulator
- Voice features require a physical device (simulator doesn't have microphone access)

### On Android Emulator
1. In the emulator, go to Settings
2. Click the three dots (...) menu
3. Go to Microphone and enable "Virtual microphone uses host audio input"

### On Physical Devices
- Just tap the microphone icon and allow permissions when prompted

## Troubleshooting

### "Bad state: No element" Error
- Make sure you've run the SQL schema in Supabase
- Check that your Supabase credentials are correct

### "Invalid API Key" Error
- Verify your OpenAI API key is correct
- Make sure you have billing enabled in your OpenAI account
- Check that the key hasn't been revoked

### Voice Not Working
- On iOS: Check Info.plist has microphone permissions (already configured)
- On Android: Check AndroidManifest.xml has RECORD_AUDIO permission (already configured)
- Grant microphone permission when the app asks

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Cost Considerations

### Supabase
- Free tier includes:
  - 500MB database
  - 1GB file storage
  - 2GB bandwidth
- Should be plenty for personal use!

### OpenAI
- GPT-3.5 Turbo costs approximately:
  - $0.0015 per 1K tokens (input)
  - $0.002 per 1K tokens (output)
- Typical conversation: ~500-1000 tokens
- Estimated: $0.001-0.003 per message exchange
- Budget: $5-10/month for regular personal use

## Next Steps

- Customize the UI colors in `lib/theme/colors.dart`
- Modify the AI system prompt in `lib/services/openai_service.dart`
- Add more features!

## Support

If you run into issues:
1. Check the main README.md for detailed documentation
2. Review the error messages carefully
3. Make sure all credentials are correctly configured
4. Try `flutter clean && flutter pub get`

Happy chatting! 🚀
