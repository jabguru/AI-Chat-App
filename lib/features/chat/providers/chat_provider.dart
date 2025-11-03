import 'package:ai_chat_app/features/chat/data/models/chat_session.dart';
import 'package:ai_chat_app/features/chat/data/models/message.dart';
import 'package:ai_chat_app/shared/services/openai_service.dart';
import 'package:ai_chat_app/shared/services/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  List<Message> _localMessages = [];

  @override
  Future<List<Message>> build(String sessionId) async {
    final supabase = SupabaseService.instance;
    final messages = await supabase.getMessages(sessionId);
    _localMessages = List.from(messages);
    return _localMessages;
  }

  Future<void> sendMessage(String content) async {
    final sessionId = ref.read(currentSessionProvider)?.id;
    if (sessionId == null) return;

    final supabase = SupabaseService.instance;
    final openai = OpenAIService.instance;

    // Add user message immediately to local state
    final userMessage = Message(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _localMessages.add(userMessage);
    state = AsyncValue.data(List.from(_localMessages));

    // Save user message to database
    await supabase.saveMessage(
      sessionId: sessionId,
      content: content,
      isUser: true,
    );

    // Add typing indicator
    final typingMessage = Message(
      id: 'temp_typing_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );
    _localMessages.add(typingMessage);
    state = AsyncValue.data(List.from(_localMessages));

    try {
      // Get messages for context
      final messages = await supabase.getMessages(sessionId);

      // Stream AI response
      String fullResponse = '';
      await for (final chunk in openai.sendMessageStream(
        message: content,
        conversationHistory: messages,
      )) {
        fullResponse += chunk;

        // Remove typing indicator and update with streaming response
        _localMessages.removeLast();
        final aiMessage = Message(
          id: 'temp_ai_${DateTime.now().millisecondsSinceEpoch}',
          content: fullResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _localMessages.add(aiMessage);
        state = AsyncValue.data(List.from(_localMessages));
      }

      // Save final AI response to database
      await supabase.saveMessage(
        sessionId: sessionId,
        content: fullResponse,
        isUser: false,
      );

      // Refresh from database to get proper IDs
      ref.invalidateSelf();

      // Update session title if first message
      if (messages.isEmpty) {
        final title = content.length > 30
            ? '${content.substring(0, 30)}...'
            : content;
        await supabase.updateChatSession(sessionId, title);
        ref.invalidate(chatSessionsProvider);
      }
    } catch (e) {
      // Remove typing indicator on error
      _localMessages.removeLast();
      state = AsyncValue.data(List.from(_localMessages));
      rethrow;
    }
  }
}
