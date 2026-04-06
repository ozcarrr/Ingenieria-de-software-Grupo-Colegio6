import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  static const _trades = [
    ('Electricista', 120),
    ('Soldador', 105),
    ('Carpintero', 90),
    ('Mecánico', 75),
    ('Fontanero', 60),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TipsCard(),
        const SizedBox(height: 12),
        _TradesCard(trades: _trades),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
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
              Icon(Icons.lightbulb_outline, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 6),
              Text(
                'Consejos del día',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TipCard(
            emoji: '💡',
            title: 'Completa tu perfil',
            description: 'Los perfiles completos reciben 3x más visitas',
            backgroundColor: AppColors.primaryLight,
          ),
          const SizedBox(height: 8),
          _TipCard(
            emoji: '🎯',
            title: 'Agrega certificaciones',
            description: 'Aunque no sean oficiales, muestra tus cursos y formaciones',
            backgroundColor: AppColors.tipAmber,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color backgroundColor;

  const _TipCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
          children: [
            TextSpan(text: '$emoji '),
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: '- $description'),
          ],
        ),
      ),
    );
  }
}

class _TradesCard extends StatelessWidget {
  final List<(String, int)> trades;

  const _TradesCard({required this.trades});

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
              Icon(Icons.build_outlined, size: 16, color: AppColors.textPrimary),
              SizedBox(width: 6),
              Text(
                'Oficios destacados',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...trades.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TradeRow(name: t.$1, count: t.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  final String name;
  final int count;

  const _TradeRow({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        Text(
          '$count ofertas',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
