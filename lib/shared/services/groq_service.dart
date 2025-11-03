import 'package:ai_chat_app/core/config/env_config.dart';
import 'package:ai_chat_app/features/chat/data/models/message.dart';
import 'package:ai_chat_app/shared/services/ai_service.dart';
import 'package:groq/groq.dart';

class GroqService implements AIService {
  late final Groq _groq;

  final groqConfiguration = Configuration(
    model: "qwen/qwen3-32b", // Set a different model
    temperature: 0.7,
    seed: 10,
  );

  GroqService() {
    _groq = Groq(
      apiKey: EnvConfig.groqApiKey,
      configuration: groqConfiguration,
    );

    _groq.startChat();

    _groq.setCustomInstructionsWith(
      "You are a helpful AI assistant. Be concise and friendly.",
    );
  }

  @override
  Future<String> sendMessage({
    required String message,
    List<Message>? conversationHistory,
  }) async {
    try {
      final response = await _groq.sendMessage(message);
      return response.choices.first.message.content;
    } on GroqException catch (e) {
      throw Exception('Groq API Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<String> sendMessageStream({
    required String message,
    List<Message>? conversationHistory,
  }) async* {
    // Groq package doesn't support streaming, so we'll return the full response at once
    try {
      final response = await sendMessage(
        message: message,
        conversationHistory: conversationHistory,
      );

      // Simulate streaming by yielding chunks
      const chunkSize = 10;
      for (int i = 0; i < response.length; i += chunkSize) {
        final end = (i + chunkSize < response.length)
            ? i + chunkSize
            : response.length;
        yield response.substring(i, end);
        await Future.delayed(
          Duration(milliseconds: 20),
        ); // Simulate streaming delay
      }
    } catch (e) {
      rethrow;
    }
  }
}
