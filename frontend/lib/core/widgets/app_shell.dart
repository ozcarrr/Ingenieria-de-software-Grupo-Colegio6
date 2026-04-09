import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../state/user_role_controller.dart';
import '../theme/kairos_palette.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.currentUser,
    required this.roleController,
    required this.child,
    this.liveNotification,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final UserProfile currentUser;
  final UserRoleController roleController;
  final Widget child;
  final String? liveNotification;

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Inicio',    icon: Icons.home_rounded),
    _NavItem(label: 'Trabajos',  icon: Icons.work_rounded),
    _NavItem(label: 'Red',       icon: Icons.group_rounded),
    _NavItem(label: 'Mensajes',  icon: Icons.chat_bubble_rounded),
    _NavItem(label: 'Perfil',    icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 960;
    final compactDesktop = width < 1320;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 16,
          title: _Brand(currentUser: currentUser),
          actions: [
            IconButton(
              tooltip: 'Cambiar perfil',
              onPressed: () => _openRoleSelector(context),
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            if (liveNotification != null) _LiveBanner(text: liveNotification!),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelectIndex,
          destinations: _navItems
              .map((item) =>
                  NavigationDestination(icon: Icon(item.icon), label: item.label))
              .toList(growable: false),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // ── Top nav bar ───────────────────────────────────────────────────
          Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: KairosPalette.border, width: 1.2)),
            ),
            child: Row(
              children: [
                _Brand(currentUser: currentUser, showUserName: !compactDesktop),
                const SizedBox(width: 16),
                SizedBox(
                  width: compactDesktop ? 220 : 320,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: KairosPalette.background,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: KairosPalette.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Wrap(
                            spacing: 6,
                            children: List.generate(_navItems.length, (index) {
                              final item = _navItems[index];
                              final active = selectedIndex == index;
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => onSelectIndex(index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: active
                                        ? KairosPalette.muted
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: active
                                            ? KairosPalette.primary
                                            : KairosPalette.secondary,
                                      ),
                                      if (!compactDesktop) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: active
                                                ? KairosPalette.primary
                                                : KairosPalette.secondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            tooltip: 'Cambiar perfil',
                            onPressed: () => _openRoleSelector(context),
                            icon: const Icon(Icons.swap_horiz_rounded,
                                color: KairosPalette.secondary),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(currentUser.avatarUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Live SignalR notification banner ──────────────────────────────
          if (liveNotification != null) _LiveBanner(text: liveNotification!),
          Expanded(child: child),
        ],
      ),
    );
  }

  void _openRoleSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cambiar perfil',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  const Text('Explora Kairos desde otra perspectiva.'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: UserRole.values.map((role) {
                      final selected = role == roleController.role;
                      return InkWell(
                        onTap: () {
                          roleController.setRole(role);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? KairosPalette.primary
                                  : KairosPalette.border,
                              width: selected ? 2 : 1.2,
                            ),
                            color: selected ? KairosPalette.muted : Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_iconForRole(role),
                                  color: KairosPalette.primary),
                              const SizedBox(height: 8),
                              Text(
                                _labelForRole(role),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: KairosPalette.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _subtitleForRole(role),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: KairosPalette.foreground),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _labelForRole(UserRole role) => switch (role) {
        UserRole.student || UserRole.alumni => 'Estudiante / Alumni',
        UserRole.staff                      => 'Staff del Liceo',
        UserRole.company                    => 'Empresa / Reclutador',
      };

  String _subtitleForRole(UserRole role) => switch (role) {
        UserRole.student || UserRole.alumni => 'Busca practicas y trabajos',
        UserRole.staff                      => 'Coordina y conecta estudiantes',
        UserRole.company                    => 'Publica ofertas y recluta',
      };

  IconData _iconForRole(UserRole role) => switch (role) {
        UserRole.student || UserRole.alumni => Icons.school_rounded,
        UserRole.staff                      => Icons.badge_rounded,
        UserRole.company                    => Icons.apartment_rounded,
      };
}

// ── Live notification banner ───────────────────────────────────────────────────

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: KairosPalette.primary.withValues(alpha: 0.9),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  const _Brand({required this.currentUser, this.showUserName = true});

  final UserProfile currentUser;
  final bool showUserName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [KairosPalette.primary, KairosPalette.accent],
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.bolt_rounded, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Text(
          'Kairos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: KairosPalette.secondary,
          ),
        ),
        if (showUserName) ...[
          const SizedBox(width: 12),
          Text(
            currentUser.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: KairosPalette.foreground),
          ),
        ],
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
