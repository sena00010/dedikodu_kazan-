class GossipThread {
  const GossipThread({
    required this.id,
    required this.content,
    required this.commentCount,
    required this.createdAt,
  });

  final String id;
  final String content;
  final int commentCount;
  final DateTime createdAt;

  factory GossipThread.fromJson(Map<String, dynamic> json) => GossipThread(
        id: json['id'] as String,
        content: json['content'] as String,
        commentCount: json['comment_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.isAi,
    required this.messageType,
    required this.createdAt,
    this.persona,
    this.mediaUrl,
    this.mimeType,
    this.fileName,
    this.fileSize,
    this.durationMs,
  });

  final String id;
  final String content;
  final bool isAi;
  final String messageType;
  final String? persona;
  final String? mediaUrl;
  final String? mimeType;
  final String? fileName;
  final int? fileSize;
  final int? durationMs;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        isAi: json['is_ai'] as bool? ?? false,
        messageType: json['message_type'] as String? ?? 'text',
        persona: json['ai_persona_type'] as String?,
        mediaUrl: json['media_url'] as String?,
        mimeType: json['mime_type'] as String?,
        fileName: json['file_name'] as String?,
        fileSize: json['file_size'] as int?,
        durationMs: json['duration_ms'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
