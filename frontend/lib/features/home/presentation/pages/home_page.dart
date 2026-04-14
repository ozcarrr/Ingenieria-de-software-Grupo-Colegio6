import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/data/mock_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/social_hub_service.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../staff/presentation/pages/staff_management_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.currentUser, required this.role});

  final UserProfile currentUser;
  final UserRole role;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _postFocusNode = FocusNode();

  // ── SignalR live updates ───────────────────────────────────────────────────
  // Call connectHub(jwt) from the parent after successful login.
  SocialHubService? hub;

  @override
  void dispose() {
    _postFocusNode.dispose();
    _postController.dispose();
    hub?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width > 1240;
    final canCreateEvent =
        widget.role == UserRole.staff || widget.role == UserRole.company;
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
                canCreateJobOffer: canCreateJobOffer,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: _rightSidebar(canCreateJobOffer: canCreateJobOffer),
            ),
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
            canCreateJobOffer: canCreateJobOffer,
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: KairosPalette.primary),
                  SizedBox(width: 8),
                  Text(
                    'En demanda',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trendingSkills
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        side: BorderSide.none,
                        backgroundColor: KairosPalette.muted,
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mainContent({
    required bool canCreateEvent,
    required bool canCreateJobOffer,
  }) {
    final isStaff = widget.role == UserRole.staff;
    final currentAvatar = widget.currentUser.avatarUrl.trim();
    return Column(
      children: [
        // ── Banner de gestión para staff ────────────────────────────────────
        if (isStaff)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: KCard(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x1A0F766E), Color(0xFFE8F3EF)],
              ),
              borderColor: KairosPalette.primary,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: KairosPalette.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panel de Gestión',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crea cuentas de alumnos o staff desde un CSV.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StaffManagementPage(),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Importar CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KairosPalette.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        KCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: currentAvatar.isNotEmpty
                        ? NetworkImage(currentAvatar)
                        : null,
                    child: currentAvatar.isEmpty
                        ? const Icon(Icons.person_rounded)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _postController,
                          focusNode: _postFocusNode,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1000),
                          ],
                          minLines: 1,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: 'Que quieres compartir hoy?',
                            filled: true,
                            fillColor: KairosPalette.background,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: KairosPalette.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: KairosPalette.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: KairosPalette.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        ListenableBuilder(
                          listenable: _postFocusNode,
                          builder: (context, _) {
                            if (!_postFocusNode.hasFocus) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                const SizedBox(height: 4),
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: _postController,
                                  builder: (context, value, _) {
                                    final count = value.text.characters.length;
                                    final atLimit = count >= 1000;
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '$count/1000',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: atLimit
                                              ? Colors.redAccent
                                              : KairosPalette.secondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildComposerActions(
                canCreateEvent: canCreateEvent,
                canCreateJobOffer: canCreateJobOffer,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PostCard(post: post),
          ),
        ),
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
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: KairosPalette.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Consejos del dia',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
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
                  Text(
                    'Oficios destacados',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
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
                      fontWeight: FontWeight.w800,
                    ),
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
                const Text(
                  'Publica una oferta',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 6),
                const Text('Encuentra talento tecnico para tu empresa.'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KairosPalette.accent,
                    ),
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

  Widget _tip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: KairosPalette.muted,
      ),
      child: Text(text),
    );
  }

  Widget _buildComposerActions({
    required bool canCreateEvent,
    required bool canCreateJobOffer,
  }) {
    final actions = <Widget>[
      _mediaAction(),
      if (canCreateEvent) _ghostAction(Icons.calendar_month_rounded, 'Evento'),
      if (canCreateJobOffer)
        _accentAction(Icons.work_rounded, 'Oferta laboral'),
      _publishAction(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  actions[i],
                  if (i != actions.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mediaAction() {
    return SizedBox(
      width: 116,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.image_rounded, size: 16),
        label: const Text('Media'),
        style: OutlinedButton.styleFrom(
          foregroundColor: KairosPalette.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: KairosPalette.border),
        ),
      ),
    );
  }

  Widget _ghostAction(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: KairosPalette.secondary,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: KairosPalette.border),
      ),
    );
  }

  Widget _accentAction(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: KairosPalette.accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _publishAction() {
    return SizedBox(
      width: 116,
      height: 40,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 4,
          shadowColor: KairosPalette.primary.withValues(alpha: 0.35),
        ),
        child: const Text(
          'Publicar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
