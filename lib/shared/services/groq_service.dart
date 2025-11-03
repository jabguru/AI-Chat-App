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

  String _cleanResponse(String response) {
    // Remove <think> tags and their content
    String cleaned = response.replaceAll(
      RegExp(r'<think>.*?</think>', dotAll: true),
      '',
    );

    // Remove any remaining angle bracket tags
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]+>'), '');

    // Remove markdown bold (**text** or __text__)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*\*([^\*]+)\*\*'),
      (match) => match.group(1)!,
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (match) => match.group(1)!,
    );

    // Remove markdown italic (*text* or _text_)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*([^\*]+)\*'),
      (match) => match.group(1)!,
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'_([^_]+)_'),
      (match) => match.group(1)!,
    );

    // Remove markdown code blocks (```code```)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'```[^\n]*\n(.*?)```', dotAll: true),
      (match) => match.group(1)!,
    );

    // Remove inline code (`code`)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match.group(1)!,
    );

    // Remove markdown headers (# Header)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove markdown links [text](url) - keep just the text
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)'),
      (match) => match.group(1)!,
    );

    // Clean up any extra whitespace
    cleaned = cleaned.trim();

    return cleaned;
  }

  @override
  Future<String> sendMessage({
    required String message,
    List<Message>? conversationHistory,
  }) async {
    try {
      final response = await _groq.sendMessage(message);
      final content = response.choices.first.message.content;
      return _cleanResponse(content);
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
