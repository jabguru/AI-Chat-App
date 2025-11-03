import 'package:ai_chat_app/shared/services/ai_service.dart';
import 'package:ai_chat_app/shared/services/groq_service.dart';
import 'package:ai_chat_app/shared/services/openai_service.dart';

enum AIProvider { openai, groq }

class AIServiceFactory {
  static AIProvider currentProvider = AIProvider.groq;

  static AIService get instance {
    switch (currentProvider) {
      case AIProvider.openai:
        return OpenAIService();
      case AIProvider.groq:
        return GroqService();
    }
  }

  static void switchTo(AIProvider provider) {
    currentProvider = provider;
  }
}
