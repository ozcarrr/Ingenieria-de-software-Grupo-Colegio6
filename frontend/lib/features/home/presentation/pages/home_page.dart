import 'package:flutter/material.dart';

import '../../../../core/data/mock_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/social_hub_service.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';
import '../../../../core/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.currentUser, required this.role});

  final UserProfile currentUser;
  final UserRole role;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _postController = TextEditingController();

  // ── SignalR live updates ───────────────────────────────────────────────────
  // Call connectHub(jwt) from the parent after successful login.
  SocialHubService? hub;

  @override
  void dispose() {
    _postController.dispose();
    hub?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width > 1240;
    final canCreateEvent    = widget.role == UserRole.staff   || widget.role == UserRole.company;
    final canCreateJobOffer = widget.role == UserRole.company;

    if (desktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 280, child: _leftSidebar()),
            const SizedBox(width: 16),
            Expanded(
                child: _mainContent(
                    canCreateEvent: canCreateEvent,
                    canCreateJobOffer: canCreateJobOffer)),
            const SizedBox(width: 16),
            SizedBox(
                width: 300,
                child: _rightSidebar(canCreateJobOffer: canCreateJobOffer)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _leftSidebar(),
          const SizedBox(height: 12),
          _mainContent(
              canCreateEvent: canCreateEvent,
              canCreateJobOffer: canCreateJobOffer),
          const SizedBox(height: 12),
          _rightSidebar(canCreateJobOffer: canCreateJobOffer),
        ],
      ),
    );
  }

  Widget _leftSidebar() {
    return Column(
      children: [
        KCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 86,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [KairosPalette.primary, KairosPalette.accent]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -38),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 34,
                          backgroundImage:
                              NetworkImage(widget.currentUser.avatarUrl),
                        ),
                      ),
                    ),
                    Text(widget.currentUser.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(widget.currentUser.title,
                        style:
                            const TextStyle(color: KairosPalette.secondary)),
                    const SizedBox(height: 14),
                    _statRow('Conexiones',
                        widget.currentUser.connections.toString()),
                    _statRow('Vistas', '89'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: KairosPalette.primary),
                  SizedBox(width: 8),
                  Text('En demanda',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trendingSkills
                    .map((skill) => Chip(
                          label: Text(skill,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          side: BorderSide.none,
                          backgroundColor: KairosPalette.muted,
                        ))
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mainContent(
      {required bool canCreateEvent, required bool canCreateJobOffer}) {
    return Column(
      children: [
        KCard(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        NetworkImage(widget.currentUser.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      maxLines: 3,
                      minLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Que quieres compartir hoy?',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ghostAction(Icons.image_rounded, 'Imagen'),
                        _ghostAction(Icons.videocam_rounded, 'Video'),
                        if (canCreateEvent)
                          _ghostAction(
                              Icons.calendar_month_rounded, 'Evento'),
                        if (canCreateJobOffer)
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.work_rounded, size: 18),
                            label: const Text('Oferta laboral'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: KairosPalette.accent),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Publicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...posts.map((post) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PostCard(post: post),
            )),
      ],
    );
  }

  Widget _rightSidebar({required bool canCreateJobOffer}) {
    return Column(
      children: [
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      color: KairosPalette.primary),
                  SizedBox(width: 8),
                  Text('Consejos del dia',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              _tip('Completa tu perfil para recibir mas visitas.'),
              _tip('Agrega certificaciones y proyectos para destacar.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.build_rounded, color: KairosPalette.primary),
                  SizedBox(width: 8),
                  Text('Oficios destacados',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),
              ...highlightedTrades.asMap().entries.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      trailing: Text(
                        '${120 - (entry.key * 15)} ofertas',
                        style: const TextStyle(
                            color: KairosPalette.primary,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (canCreateJobOffer) ...[
          const SizedBox(height: 12),
          KCard(
            gradient: const LinearGradient(
              colors: [Color(0x1A00B5AD), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: KairosPalette.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Publica una oferta',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 6),
                const Text(
                    'Encuentra talento tecnico para tu empresa.'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: KairosPalette.accent),
                    onPressed: () {},
                    child: const Text('Crear oferta laboral'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: KairosPalette.secondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: KairosPalette.primary)),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: KairosPalette.muted),
      child: Text(text),
    );
  }

  Widget _ghostAction(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: KairosPalette.secondary,
        side: const BorderSide(color: KairosPalette.border),
      ),
    );
  }
}
