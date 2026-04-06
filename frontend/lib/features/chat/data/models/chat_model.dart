class ChatModel {
  final String id;
  final String participantName;
  final String participantTitle;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const ChatModel({
    required this.id,
    required this.participantName,
    required this.participantTitle,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}

class MessageModel {
  final String id;
  final String text;
  final bool isMine;
  final String time;

  const MessageModel({
    required this.id,
    required this.text,
    required this.isMine,
    required this.time,
  });
}
