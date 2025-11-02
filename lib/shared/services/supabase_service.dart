import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_chat_app/core/config/env_config.dart';
import 'package:ai_chat_app/features/chat/data/models/message.dart';
import 'package:ai_chat_app/features/chat/data/models/chat_session.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Chat Session methods
  Future<List<ChatSession>> getChatSessions() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await client
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => ChatSession.fromJson(json))
        .toList();
  }

  Future<ChatSession> createChatSession(String title) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await client
        .from('chat_sessions')
        .insert({
          'user_id': userId,
          'title': title,
        })
        .select()
        .single();

    return ChatSession.fromJson(response);
  }

  Future<void> updateChatSession(String sessionId, String title) async {
    await client
        .from('chat_sessions')
        .update({
          'title': title,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', sessionId);
  }

  Future<void> deleteChatSession(String sessionId) async {
    await client.from('chat_sessions').delete().eq('id', sessionId);
  }

  // Message methods
  Future<List<Message>> getMessages(String sessionId) async {
    final response = await client
        .from('messages')
        .select()
        .eq('session_id', sessionId)
        .order('timestamp', ascending: true);

    return (response as List).map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> saveMessage({
    required String sessionId,
    required String content,
    required bool isUser,
    String? audioUrl,
  }) async {
    final response = await client
        .from('messages')
        .insert({
          'session_id': sessionId,
          'content': content,
          'is_user': isUser,
          'audio_url': audioUrl,
        })
        .select()
        .single();

    return Message.fromJson(response);
  }

  Stream<List<Message>> messageStream(String sessionId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('timestamp')
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }
}
