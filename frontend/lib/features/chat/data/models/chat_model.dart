import '../../../../core/models/user_profile.dart';

class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
  });

  final String id;
  final UserProfile user;
  final String lastMessage;
  final String timestamp;
  final bool unread;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });

  final String id;
  final String text;
  final String timestamp;
  final bool isMine;
}
