import 'user_models.dart';

class PostModel {
  const PostModel({
    required this.id,
    required this.author,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
    this.imageUrl,
    this.isEvent = false,
    this.eventDate,
  });

  final String id;
  final UserProfile author;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final String timestamp;
  final bool isEvent;
  final String? eventDate;
}
