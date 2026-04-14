import 'package:flutter/material.dart';

import '../../../../core/data/mock_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';
import '../../data/models/job_model.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key, required this.role});

  final UserRole role;

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
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
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 760;
    final pagePadding = mobile
        ? const EdgeInsets.fromLTRB(14, 14, 14, 16)
        : const EdgeInsets.all(20);
    final filteredJobs = jobs.where(_matchesFilter).toList(growable: false);
    final isCompany = widget.role == UserRole.company;

    return SingleChildScrollView(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oportunidades Laborales',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Practicas y trabajos del Liceo Tecnico Cardenal Jose Maria Caro',
                ),
                if (isCompany) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateOfferDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KairosPalette.accent,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Publicar oferta'),
                    ),
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oportunidades Laborales',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Practicas y trabajos del Liceo Tecnico Cardenal Jose Maria Caro',
                      ),
                    ],
                  ),
                ),
                if (isCompany)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateOfferDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KairosPalette.accent,
                    ),
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
            child: mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: KairosPalette.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Automatiza tu CV',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Genera CVs personalizados para cada oferta en segundos.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.bolt_rounded),
                          label: const Text('Generar CV'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: KairosPalette.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automatiza tu CV',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Genera CVs personalizados para cada oferta en segundos.',
                            ),
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
                            onPressed: () =>
                                setState(() => _searchController.clear()),
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tipo de oportunidad',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
                const Text(
                  'Especializacion',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
          if (mobile)
            Column(
              children: [
                _statCard(
                  Icons.work_rounded,
                  '${jobs.length}',
                  'Ofertas activas',
                ),
                const SizedBox(height: 10),
                _statCard(
                  Icons.bookmark_rounded,
                  '${_savedJobs.length}',
                  'Guardadas',
                ),
                const SizedBox(height: 10),
                _statCard(Icons.schedule_rounded, '12', 'Nuevas esta semana'),
              ],
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                return GridView.count(
                  crossAxisCount: wide ? 3 : 1,
                  childAspectRatio: wide ? 3 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _statCard(
                      Icons.work_rounded,
                      '${jobs.length}',
                      'Ofertas activas',
                    ),
                    _statCard(
                      Icons.bookmark_rounded,
                      '${_savedJobs.length}',
                      'Guardadas',
                    ),
                    _statCard(
                      Icons.schedule_rounded,
                      '12',
                      'Nuevas esta semana',
                    ),
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
            ...filteredJobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _jobTile(job, mobile: mobile),
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilter(JobModel job) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        job.title.toLowerCase().contains(query) ||
        job.company.toLowerCase().contains(query) ||
        job.skills.any((skill) => skill.toLowerCase().contains(query));
    final matchesType = _selectedType == null || job.type == _selectedType;
    final matchesSpecialization =
        _selectedSpecialization == null ||
        job.specializations.contains(_selectedSpecialization);
    return matchesSearch && matchesType && matchesSpecialization;
  }

  Widget _jobTile(JobModel job, {required bool mobile}) {
    final saved = _savedJobs.contains(job.id);
    final applyButtonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(mobile ? 0 : 136, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: KairosPalette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    );
    final actionButtonStyle = OutlinedButton.styleFrom(
      minimumSize: Size(mobile ? 0 : 136, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: KairosPalette.primary),
      foregroundColor: KairosPalette.primary,
    );

    if (mobile) {
      return KCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    job.logoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: KairosPalette.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _metaChip(Icons.pin_drop_rounded, job.location),
                _metaChip(Icons.work_rounded, job.type.label),
                if (job.salary != null)
                  _metaChip(Icons.attach_money_rounded, job.salary!),
                _metaChip(Icons.schedule_rounded, job.postedDate),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      side: BorderSide.none,
                      backgroundColor: KairosPalette.muted,
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: applyButtonStyle,
                    child: const Text('Aplicar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: actionButtonStyle,
                    child: const Text('Ver detalles'),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    tooltip: saved ? 'Quitar de guardadas' : 'Guardar',
                    onPressed: () => setState(() {
                      if (saved) {
                        _savedJobs.remove(job.id);
                      } else {
                        _savedJobs.add(job.id);
                      }
                    }),
                    icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return KCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              job.logoUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.company,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: KairosPalette.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _metaChip(Icons.pin_drop_rounded, job.location),
                    _metaChip(Icons.work_rounded, job.type.label),
                    if (job.salary != null)
                      _metaChip(Icons.attach_money_rounded, job.salary!),
                    _metaChip(Icons.schedule_rounded, job.postedDate),
                  ],
                ),
                const SizedBox(height: 8),
                Text(job.description),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          side: BorderSide.none,
                          backgroundColor: KairosPalette.muted,
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: applyButtonStyle,
                    child: const Text('Aplicar'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: actionButtonStyle,
                    child: const Text('Ver detalles'),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: saved ? 'Quitar de guardadas' : 'Guardar',
                onPressed: () => setState(() {
                  if (saved) {
                    _savedJobs.remove(job.id);
                  } else {
                    _savedJobs.add(job.id);
                  }
                }),
                icon: Icon(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String value) {
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: KairosPalette.secondary),
                ),
              ],
            ),
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
      labelStyle: TextStyle(
        color: selected ? Colors.white : KairosPalette.foreground,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _specializationChip(String label, String? value) {
    final selected = _selectedSpecialization == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedSpecialization = value),
      selectedColor: KairosPalette.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : KairosPalette.foreground,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _showCreateOfferDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Publicar oferta'),
        content: const Text(
          'Formulario listo para integracion con el backend C#.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
