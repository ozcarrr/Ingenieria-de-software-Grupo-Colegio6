import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int connections;
  final int views;
  final List<String> inDemandSkills;

  const ProfileCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.connections,
    required this.views,
    required this.inDemandSkills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileInfoCard(
          name: name,
          subtitle: subtitle,
          connections: connections,
          views: views,
        ),
        const SizedBox(height: 12),
        _InDemandCard(skills: inDemandSkills),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int connections;
  final int views;

  const _ProfileInfoCard({
    required this.name,
    required this.subtitle,
    required this.connections,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teal banner
          Container(
            height: 72,
            color: AppColors.primary,
          ),
          // Avatar + content — Stack to overlay avatar on banner
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 10),
                    _StatRow(label: 'Conexiones', value: connections),
                    const SizedBox(height: 6),
                    _StatRow(label: 'Vistas', value: views),
                  ],
                ),
              ),
              Positioned(
                top: -36,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFB0BEC5),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InDemandCard extends StatelessWidget {
  final List<String> skills;

  const _InDemandCard({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 6),
              Text(
                '🔥 En Demanda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => _SkillChip(label: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.chipBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
