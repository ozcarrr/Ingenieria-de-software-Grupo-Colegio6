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

  @override
  void initState() {
    super.initState();
    _liked = false;
    _likes = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return KCard(
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
                  backgroundImage: NetworkImage(post.author.avatarUrl),
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
            child: Text(post.content, style: const TextStyle(height: 1.4)),
          ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: KairosPalette.border)),
            ),
            child: Row(
              children: [
                Text('$_likes Me gusta',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${post.comments} Comentarios'),
                const SizedBox(width: 12),
                Text('${post.shares} Compartidos'),
              ],
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
              Text(label,
                  style:
                      TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
