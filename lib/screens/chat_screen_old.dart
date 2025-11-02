import 'package:ai_chat_app/models/chat_session.dart';
import 'package:ai_chat_app/models/message.dart';
import 'package:ai_chat_app/services/openai_service.dart';
import 'package:ai_chat_app/services/supabase_service.dart';
import 'package:ai_chat_app/services/voice_service.dart';
import 'package:ai_chat_app/theme/colors.dart';
import 'package:ai_chat_app/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _supabase = SupabaseService.instance;
  final _openai = OpenAIService.instance;
  final _voice = VoiceService.instance;

  List<Message> _messages = [];
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _streamingResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadChatSessions();
    if (_chatSessions.isEmpty) {
      await _createNewChat();
    } else {
      _currentSession = _chatSessions.first;
      await _loadMessages();
    }
  }

  Future<void> _loadChatSessions() async {
    try {
      final sessions = await _supabase.getChatSessions();
      setState(() {
        _chatSessions = sessions;
      });
    } catch (e) {
      print('Error loading chat sessions: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (_currentSession == null) return;
    try {
      final messages = await _supabase.getMessages(_currentSession!.id);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _createNewChat() async {
    try {
      final session = await _supabase.createChatSession('New Chat');
      setState(() {
        _currentSession = session;
        _chatSessions.insert(0, session);
        _messages = [];
      });
    } catch (e) {
      print('Error creating new chat: $e');
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _currentSession == null) return;

    setState(() => _isLoading = true);

    try {
      // Save user message
      final userMessage = await _supabase.saveMessage(
        sessionId: _currentSession!.id,
        content: content,
        isUser: true,
      );

      setState(() {
        _messages.add(userMessage);
        _messageController.clear();
      });
      _scrollToBottom();

      // Get AI response
      _streamingResponse = '';
      final responseStream = _openai.sendMessageStream(
        message: content,
        conversationHistory: _messages,
      );

      // Create a placeholder message for streaming
      final aiMessageId = Uuid().v4();
      final aiMessage = Message(
        id: aiMessageId,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
      });

      await for (final chunk in responseStream) {
        _streamingResponse += chunk;
        setState(() {
          final index = _messages.indexWhere((m) => m.id == aiMessageId);
          if (index != -1) {
            _messages[index] = Message(
              id: aiMessageId,
              content: _streamingResponse,
              isUser: false,
              timestamp: DateTime.now(),
            );
          }
        });
        _scrollToBottom();
      }

      // Save AI response to database
      await _supabase.saveMessage(
        sessionId: _currentSession!.id,
        content: _streamingResponse,
        isUser: false,
      );

      // Update chat session title if it's the first message
      if (_messages.length == 2) {
        final title = content.length > 30
            ? '${content.substring(0, 30)}...'
            : content;
        await _supabase.updateChatSession(_currentSession!.id, title);
        await _loadChatSessions();
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
      print('Error with voice input: $e');
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
    setState(() {
      _currentSession = session;
      _messages = [];
    });
    await _loadMessages();
    Navigator.of(context).pop(); // Close drawer
  }

  Future<void> _deleteChat(ChatSession session) async {
    try {
      await _supabase.deleteChatSession(session.id);
      await _loadChatSessions();
      if (_currentSession?.id == session.id) {
        if (_chatSessions.isEmpty) {
          await _createNewChat();
        } else {
          _currentSession = _chatSessions.first;
          await _loadMessages();
        }
      }
    } catch (e) {
      print('Error deleting chat: $e');
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
    final user = _supabase.currentUser;

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
          _currentSession?.title ?? 'AI Chat',
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
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Section
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
            // Chat History Section
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
              child: _chatSessions.isEmpty
                  ? Center(
                      child: Text(
                        'No chat history',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        final isSelected = session.id == _currentSession?.id;
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
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
            ),
            Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.textSecondary),
              title: Text(
                'Sign Out',
                style: TextStyle(color: AppColors.white),
              ),
              onTap: () async {
                await _supabase.signOut();
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
            color: AppColors.textSecondary.withOpacity(0.3),
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
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
                    : AppColors.border.withOpacity(0.5),
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
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
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
                      : AppColors.border.withOpacity(0.3),
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
              onTap: _isLoading
                  ? null
                  : () => _sendMessage(_messageController.text),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.white),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: AppColors.background,
                        size: 24,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
