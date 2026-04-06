import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/person_model.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  // Sorted descending by mutualConnections — in production this comes from
  // the API query: SELECT ... ORDER BY mutual_friends_count DESC
  static const _suggestions = [
    PersonModel(
      id: '1',
      name: 'Camila Rojas',
      title: 'Estudiante de Electricidad - 4° Medio',
      mutualConnections: 12,
    ),
    PersonModel(
      id: '2',
      name: 'Diego Fuentes',
      title: 'Estudiante de Mecatrónica - 3° Medio',
      mutualConnections: 9,
    ),
    PersonModel(
      id: '3',
      name: 'Valentina Soto',
      title: 'Egresada Técnico en Refrigeración',
      mutualConnections: 8,
    ),
    PersonModel(
      id: '4',
      name: 'Andrés Morales',
      title: 'Estudiante de Construcción - 4° Medio',
      mutualConnections: 7,
    ),
    PersonModel(
      id: '5',
      name: 'Paula Vera',
      title: 'Profesora de Especialidad · Liceo',
      mutualConnections: 6,
    ),
    PersonModel(
      id: '6',
      name: 'Sebastián Castro',
      title: 'Técnico en Mantenimiento · Metalmecánica del Sur',
      mutualConnections: 5,
    ),
    PersonModel(
      id: '7',
      name: 'Isidora Núñez',
      title: 'Estudiante de Electricidad - 3° Medio',
      mutualConnections: 4,
    ),
    PersonModel(
      id: '8',
      name: 'Felipe Jiménez',
      title: 'Reclutador · Instalaciones Eléctricas López',
      mutualConnections: 3,
    ),
  ];

  final Set<String> _connected = {};
  final Set<String> _dismissed = {};

  List<PersonModel> get _visible =>
      _suggestions.where((p) => !_dismissed.contains(p.id)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personas que quizás conozcas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Basado en conexiones en común',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final person = _visible[i];
                      return _PersonCard(
                        person: person,
                        isConnected: _connected.contains(person.id),
                        onConnect: () =>
                            setState(() => _connected.add(person.id)),
                        onDismiss: () =>
                            setState(() => _dismissed.add(person.id)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final PersonModel person;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDismiss;

  const _PersonCard({
    required this.person,
    required this.isConnected,
    required this.onConnect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              person.name.substring(0, 1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  person.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${person.mutualConnections} conexiones en común',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isConnected)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Conectado',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.person_add_outlined, size: 15),
                  label: const Text('Conectar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (!isConnected) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDismiss,
                  child: const Text(
                    'Ignorar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
