import 'package:dart_openai/dart_openai.dart';
import 'package:ai_chat_app/config/env_config.dart';
import 'package:ai_chat_app/models/message.dart';

class OpenAIService {
  static OpenAIService? _instance;
  static OpenAIService get instance {
    _instance ??= OpenAIService._();
    return _instance!;
  }

  OpenAIService._() {
    OpenAI.apiKey = EnvConfig.openAiApiKey;
  }

  Future<String> sendMessage({
    required String message,
    List<Message>? conversationHistory,
  }) async {
    try {
      // Build conversation context
      final List<OpenAIChatCompletionChoiceMessageModel> messages = [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are a helpful AI assistant. Be concise and friendly.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      ];

      // Add conversation history if available
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (var msg in conversationHistory.take(10)) {
          // Limit history to last 10 messages
          messages.add(
            OpenAIChatCompletionChoiceMessageModel(
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  msg.content,
                ),
              ],
              role: msg.isUser
                  ? OpenAIChatMessageRole.user
                  : OpenAIChatMessageRole.assistant,
            ),
          );
        }
      }

      // Add current message
      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      );

      // Get response from OpenAI
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      return chatCompletion.choices.first.message.content?.first.text ?? 
          "I apologize, but I couldn't generate a response.";
    } catch (e) {
      print('OpenAI Error: $e');
      return "I'm sorry, I encountered an error. Please try again.";
    }
  }

  Stream<String> sendMessageStream({
    required String message,
    List<Message>? conversationHistory,
  }) async* {
    try {
      // Build conversation context (same as above)
      final List<OpenAIChatCompletionChoiceMessageModel> messages = [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are a helpful AI assistant. Be concise and friendly.",
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      ];

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (var msg in conversationHistory.take(10)) {
          messages.add(
            OpenAIChatCompletionChoiceMessageModel(
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  msg.content,
                ),
              ],
              role: msg.isUser
                  ? OpenAIChatMessageRole.user
                  : OpenAIChatMessageRole.assistant,
            ),
          );
        }
      }

      messages.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      );

      // Stream response from OpenAI
      final stream = OpenAI.instance.chat.createStream(
        model: "gpt-3.5-turbo",
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      await for (final chunk in stream) {
        final content = chunk.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          final firstContent = content.first;
          final text = firstContent?.text;
          if (text != null) {
            yield text;
          }
        }
      }
    } catch (e) {
      print('OpenAI Stream Error: $e');
      yield "I'm sorry, I encountered an error. Please try again.";
    }
  }
}
