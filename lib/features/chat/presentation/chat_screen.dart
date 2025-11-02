import 'package:ai_chat_app/core/theme/colors.dart';
import 'package:ai_chat_app/core/widgets/loading_provider.dart';
import 'package:ai_chat_app/core/widgets/space.dart';
import 'package:ai_chat_app/features/auth/providers/auth_provider.dart';
import 'package:ai_chat_app/features/chat/data/models/chat_session.dart';
import 'package:ai_chat_app/features/chat/data/models/message.dart';
import 'package:ai_chat_app/features/chat/providers/chat_provider.dart';
import 'package:ai_chat_app/shared/services/voice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _voice = VoiceService.instance;

  bool _isListening = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final sessions = await ref.read(chatSessionsProvider.future);
    if (sessions.isEmpty) {
      await ref.read(chatSessionsProvider.notifier).createSession('New Chat');
      final newSessions = await ref.read(chatSessionsProvider.future);
      ref.read(currentSessionProvider.notifier).setSession(newSessions.first);
    } else {
      ref.read(currentSessionProvider.notifier).setSession(sessions.first);
    }
  }

  Future<void> _createNewChat() async {
    await ref.read(chatSessionsProvider.notifier).createSession('New Chat');
    final sessions = await ref.read(chatSessionsProvider.future);
    ref.read(currentSessionProvider.notifier).setSession(sessions.first);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    ref.read(loadingProvider.notifier).show();
    _messageController.clear();

    try {
      final currentSession = ref.read(currentSessionProvider);
      if (currentSession != null) {
        await ref
            .read(chatMessagesProvider(currentSession.id).notifier)
            .sendMessage(content);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      ref.read(loadingProvider.notifier).hide();
    }
  }

  Future<void> _startVoiceInput() async {
    try {
      setState(() => _isListening = true);

      await _voice.startListening(
        onResult: (text) {
          _messageController.text = text;
        },
        onComplete: () {
          setState(() => _isListening = false);
        },
      );
    } catch (e) {
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _stopVoiceInput() async {
    await _voice.stopListening();
    setState(() => _isListening = false);
  }

  Future<void> _speakMessage(String text) async {
    if (_isSpeaking) {
      await _voice.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _voice.speak(text);
      setState(() => _isSpeaking = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _selectChatSession(ChatSession session) async {
    ref.read(currentSessionProvider.notifier).setSession(session);
    Navigator.of(context).pop();
  }

  Future<void> _deleteChat(ChatSession session) async {
    await ref.read(chatSessionsProvider.notifier).deleteSession(session.id);

    final currentSession = ref.read(currentSessionProvider);
    if (currentSession?.id == session.id) {
      final sessions = await ref.read(chatSessionsProvider.future);
      if (sessions.isEmpty) {
        await _createNewChat();
      } else {
        ref.read(currentSessionProvider.notifier).setSession(sessions.first);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final currentSession = ref.watch(currentSessionProvider);
    final messagesAsync = currentSession != null
        ? ref.watch(chatMessagesProvider(currentSession.id))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          currentSession?.title ?? 'AI Chat',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.white),
            onPressed: _createNewChat,
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync == null
                ? _buildEmptyState()
                : messagesAsync.when(
                    data: (messages) => messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(messages[index]);
                            },
                          ),
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDrawer(user) {
    final sessionsAsync = ref.watch(chatSessionsProvider);
    final currentSession = ref.watch(currentSessionProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  HorizontalSpacing(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        VerticalSpacing(2),
                        Text(
                          user?.email ?? 'User',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            VerticalSpacing(10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Chat History',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) => sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No chat history',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final isSelected = session.id == currentSession?.id;
                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.chat_bubble_outline,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              title: Text(
                                session.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                                onPressed: () => _deleteChat(session),
                              ),
                              onTap: () => _selectChatSession(session),
                            ),
                          );
                        },
                      ),
                loading: () => Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, stack) =>
                    Center(child: Text('Error loading sessions')),
              ),
            ),
            Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.textSecondary),
              title: Text('Sign Out', style: TextStyle(color: AppColors.white)),
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/welcome');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          VerticalSpacing(16),
          Text(
            'Start a conversation',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          VerticalSpacing(8),
          Text(
            'Send a message to begin chatting with AI',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser
                      ? AppColors.background
                      : AppColors.white,
                  fontSize: 15,
                ),
              ),
            ),
            if (!message.isUser)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSpeaking ? Icons.stop : Icons.volume_up,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => _speakMessage(message.content),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _sendMessage(value),
                ),
              ),
            ),
            HorizontalSpacing(8),
            GestureDetector(
              onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red
                      : AppColors.border.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
            HorizontalSpacing(8),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: AppColors.background, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
