import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/kairos_palette.dart';
import '../widgets/k_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _savedJobs = <String>{};
  OpportunityType? _selectedType;
  String? _selectedSpecialization;

  static const List<String> _specializations = [
    'Mecatronica',
    'Automatizacion',
    'Recursos Humanos',
    'Mecanica',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = jobs.where(_matchesFilter).toList(growable: false);
    final isCompany = widget.role == UserRole.company;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Oportunidades Laborales',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text('Practicas y trabajos del Liceo Tecnico Cardenal Jose Maria Caro'),
                  ],
                ),
              ),
              if (isCompany)
                ElevatedButton.icon(
                  onPressed: () => _showCreateOfferDialog(context),
                  style: ElevatedButton.styleFrom(backgroundColor: KairosPalette.accent),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Publicar oferta'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          KCard(
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
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Automatiza tu CV', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Genera CVs personalizados para cada oferta en segundos.'),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Generar CV'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por habilidad, empresa o cargo...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                const Text('Tipo de oportunidad', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _typeChip('Todas', null),
                    _typeChip('Practicas', OpportunityType.practice),
                    _typeChip('Trabajos', OpportunityType.job),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Especializacion', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _specializationChip('Todas', null),
                    ..._specializations.map((s) => _specializationChip(s, s)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: wide ? 3 : 1,
                childAspectRatio: wide ? 3 : 4.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _statCard(Icons.work_rounded, '${jobs.length}', 'Ofertas activas'),
                  _statCard(Icons.bookmark_rounded, '${_savedJobs.length}', 'Guardadas'),
                  _statCard(Icons.schedule_rounded, '12', 'Nuevas esta semana'),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (filteredJobs.isEmpty)
            const KCard(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No hay resultados con esos filtros.'),
                ),
              ),
            )
          else
            ...filteredJobs.map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _jobTile(job),
                )),
        ],
      ),
    );
  }

  bool _matchesFilter(JobModel job) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesSearch = query.isEmpty ||
        job.title.toLowerCase().contains(query) ||
        job.company.toLowerCase().contains(query) ||
        job.skills.any((skill) => skill.toLowerCase().contains(query));

    final matchesType = _selectedType == null || job.type == _selectedType;

    final matchesSpecialization =
        _selectedSpecialization == null || job.specializations.contains(_selectedSpecialization);

    return matchesSearch && matchesType && matchesSpecialization;
  }

  Widget _jobTile(JobModel job) {
    final saved = _savedJobs.contains(job.id);

    return KCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(job.logoUrl, width: 58, height: 58, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 2),
                Text(job.company, style: const TextStyle(fontWeight: FontWeight.w600, color: KairosPalette.secondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _meta(Icons.pin_drop_rounded, job.location),
                    _meta(Icons.work_rounded, job.type.label),
                    if (job.salary != null) _meta(Icons.attach_money_rounded, job.salary!),
                    _meta(Icons.schedule_rounded, job.postedDate),
                  ],
                ),
                const SizedBox(height: 8),
                Text(job.description),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.skills
                      .map((skill) => Chip(label: Text(skill), side: BorderSide.none, backgroundColor: KairosPalette.muted))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: saved ? 'Quitar de guardadas' : 'Guardar',
                onPressed: () {
                  setState(() {
                    if (saved) {
                      _savedJobs.remove(job.id);
                    } else {
                      _savedJobs.add(job.id);
                    }
                  });
                },
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: KairosPalette.accent),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Aplicar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Ver detalles'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: KairosPalette.secondary),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: KairosPalette.secondary)),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return KCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: KairosPalette.muted,
            ),
            child: Icon(icon, color: KairosPalette.primary),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: KairosPalette.secondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, OpportunityType? type) {
    final selected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedType = type),
      selectedColor: KairosPalette.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : KairosPalette.foreground, fontWeight: FontWeight.w700),
    );
  }

  Widget _specializationChip(String label, String? value) {
    final selected = _selectedSpecialization == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedSpecialization = value),
      selectedColor: KairosPalette.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : KairosPalette.foreground, fontWeight: FontWeight.w700),
    );
  }

  void _showCreateOfferDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Publicar oferta'),
          content: const Text('Frontend listo para integracion. Aqui puedes conectar el formulario al backend C#.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
          ],
        );
      },
    );
  }
}
