import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/home/data/models/post_model.dart';
import '../theme/kairos_palette.dart';
import 'k_card.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final PostModel post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likes;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _liked = false;
    _likes = widget.post.likes;
    _isExpanded = false;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  bool _shouldUseSquareMedia(String? url) {
    if (url == null || url.isEmpty) return false;

    final normalized = url.toLowerCase();
    if (normalized.contains('1x1') ||
        normalized.contains('1:1') ||
        normalized.contains('square')) {
      return true;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final widthRaw = uri.queryParameters['w'] ?? uri.queryParameters['width'];
    final heightRaw = uri.queryParameters['h'] ?? uri.queryParameters['height'];
    final width = int.tryParse(widthRaw ?? '');
    final height = int.tryParse(heightRaw ?? '');

    return width != null && height != null && width == height;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final authorAvatar = post.author.avatarUrl.trim();
    final imageUrl = post.imageUrl?.trim();
    final content = post.content.trim();
    final canCollapseContent = content.length > 180;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = switch (constraints.maxWidth) {
          >= 1200 => 620.0,
          >= 900 => 580.0,
          >= 700 => 540.0,
          _ => constraints.maxWidth,
        };
        final cardWidth = math.min(constraints.maxWidth, maxCardWidth);
        final mediaAspectRatio = _shouldUseSquareMedia(imageUrl) ? 1.0 : 3 / 4;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: cardWidth,
            child: KCard(
      borderColor: post.isEvent
          ? KairosPalette.primary.withValues(alpha: 0.4)
          : KairosPalette.border,
      gradient: post.isEvent
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1A0F766E), Colors.white],
            )
          : null,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isEvent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: KairosPalette.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Evento  ${post.eventDate ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
                  child: authorAvatar.isEmpty
                      ? const Icon(Icons.person_rounded)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(post.author.title,
                          style: const TextStyle(
                              color: KairosPalette.secondary, fontSize: 12)),
                      Text(post.timestamp,
                          style: const TextStyle(
                              color: KairosPalette.secondary, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: KairosPalette.secondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(height: 1.4),
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (canCollapseContent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton(
                      onPressed: _toggleExpanded,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: KairosPalette.primary,
                      ),
                      child: Text(_isExpanded ? 'Ver menos' : 'Ver mas'),
                    ),
                  ),
              ],
            ),
          ),
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: mediaAspectRatio,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: KairosPalette.border)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                if (isCompact) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text('$_likes Me gusta',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${post.comments} Comentarios'),
                      Text('${post.shares} Compartidos'),
                    ],
                  );
                }

                return Row(
                  children: [
                    Text('$_likes Me gusta',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${post.comments} Comentarios'),
                    const SizedBox(width: 12),
                    Text('${post.shares} Compartidos'),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              _ActionButton(
                icon: _liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: 'Me gusta',
                color: _liked ? KairosPalette.accent : KairosPalette.secondary,
                onTap: _toggleLike,
              ),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Comentar',
                color: KairosPalette.secondary,
                onTap: () {},
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Compartir',
                color: KairosPalette.secondary,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
