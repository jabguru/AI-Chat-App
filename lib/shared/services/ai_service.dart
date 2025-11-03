import 'package:ai_chat_app/features/chat/data/models/message.dart';

abstract class AIService {
  Future<String> sendMessage({
    required String message,
    List<Message>? conversationHistory,
  });

  Stream<String> sendMessageStream({
    required String message,
    List<Message>? conversationHistory,
  });
}
