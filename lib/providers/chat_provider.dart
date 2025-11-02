import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ai_chat_app/models/chat_session.dart';
import 'package:ai_chat_app/models/message.dart';
import 'package:ai_chat_app/services/supabase_service.dart';
import 'package:ai_chat_app/services/openai_service.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatSessions extends _$ChatSessions {
  @override
  Future<List<ChatSession>> build() async {
    final supabase = SupabaseService.instance;
    return await supabase.getChatSessions();
  }

  Future<void> createSession(String title) async {
    final supabase = SupabaseService.instance;
    await supabase.createChatSession(title);
    ref.invalidateSelf();
  }

  Future<void> deleteSession(String sessionId) async {
    final supabase = SupabaseService.instance;
    await supabase.deleteChatSession(sessionId);
    ref.invalidateSelf();
  }

  Future<void> updateSession(String sessionId, String title) async {
    final supabase = SupabaseService.instance;
    await supabase.updateChatSession(sessionId, title);
    ref.invalidateSelf();
  }
}

@riverpod
class CurrentSession extends _$CurrentSession {
  @override
  ChatSession? build() => null;

  void setSession(ChatSession session) {
    state = session;
  }

  void clear() {
    state = null;
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  Future<List<Message>> build(String sessionId) async {
    final supabase = SupabaseService.instance;
    return await supabase.getMessages(sessionId);
  }

  Future<void> sendMessage(String content) async {
    final sessionId = ref.read(currentSessionProvider)?.id;
    if (sessionId == null) return;

    final supabase = SupabaseService.instance;
    final openai = OpenAIService.instance;

    await supabase.saveMessage(
      sessionId: sessionId,
      content: content,
      isUser: true,
    );

    ref.invalidateSelf();

    final messages = await future;
    final response = await openai.sendMessage(
      message: content,
      conversationHistory: messages,
    );

    await supabase.saveMessage(
      sessionId: sessionId,
      content: response,
      isUser: false,
    );

    ref.invalidateSelf();

    if (messages.length == 0) {
      final title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
      await supabase.updateChatSession(sessionId, title);
      ref.invalidate(chatSessionsProvider);
    }
  }
}
