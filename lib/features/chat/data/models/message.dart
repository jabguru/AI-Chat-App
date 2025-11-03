class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? audioUrl;
  final bool isTyping;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.audioUrl,
    this.isTyping = false,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? audioUrl,
    bool? isTyping,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      audioUrl: audioUrl ?? this.audioUrl,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'audio_url': audioUrl,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      audioUrl: json['audio_url'] as String?,
    );
  }
}
