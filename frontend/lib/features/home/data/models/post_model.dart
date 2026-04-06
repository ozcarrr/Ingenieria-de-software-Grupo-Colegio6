enum PostType { regular, event }

class PostModel {
  final String id;
  final String authorName;
  final String authorTitle;
  final String? authorBadge;
  final String timeAgo;
  final String content;
  final PostType type;
  final String? eventDate;
  final List<String> details;

  const PostModel({
    required this.id,
    required this.authorName,
    required this.authorTitle,
    this.authorBadge,
    required this.timeAgo,
    required this.content,
    this.type = PostType.regular,
    this.eventDate,
    this.details = const [],
  });
}
