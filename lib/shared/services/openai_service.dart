import 'package:ai_chat_app/core/config/env_config.dart';
import 'package:ai_chat_app/features/chat/data/models/message.dart';
import 'package:ai_chat_app/shared/services/ai_service.dart';
import 'package:dart_openai/dart_openai.dart';

class OpenAIService implements AIService {
  OpenAIService() {
    OpenAI.apiKey = EnvConfig.openAiApiKey;
  }

  @override
  Future<String> sendMessage({
    required String message,
    List<Message>? conversationHistory,
  }) async {
    try {
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

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      return chatCompletion.choices.first.message.content?.first.text ??
          "I apologize, but I couldn't generate a response.";
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<String> sendMessageStream({
    required String message,
    List<Message>? conversationHistory,
  }) async* {
    try {
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
      yield "I'm sorry, I encountered an error. Please try again.";
    }
  }
}
