import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavItemTapped;

  const TopNavBar({
    super.key,
    required this.selectedIndex,
    required this.onNavItemTapped,
  });

  static const _navItems = [
    (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
    (Icons.work_rounded, Icons.work_outline, 'Trabajos'),
    (Icons.people_rounded, Icons.people_outline, 'Red'),
    (Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 'Mensajes'),
    (Icons.person_rounded, Icons.person_outline, 'Perfil'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Kairos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Search bar
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Nav items
          ..._navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _NavItem(
              activeIcon: item.$1,
              inactiveIcon: item.$2,
              label: item.$3,
              isSelected: selectedIndex == i,
              onTap: () => onNavItemTapped(i),
            );
          }),
          const SizedBox(width: 20),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
            onPressed: () {},
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
