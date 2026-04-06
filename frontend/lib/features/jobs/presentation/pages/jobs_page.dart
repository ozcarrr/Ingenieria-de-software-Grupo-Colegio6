import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/job_model.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String _selectedFilter = 'Todos';

  static const _filters = ['Todos', 'Práctica', 'Tiempo completo', 'Medio tiempo'];

  static const _mockJobs = [
    JobModel(
      id: '1',
      title: 'Técnico en Mantenimiento Industrial',
      company: 'Metalmecánica del Sur S.A.',
      location: 'Santiago, RM',
      type: JobType.internship,
      postedAgo: 'Hace 2 días',
      description:
          'Buscamos estudiante de 4° medio de la especialidad Mecánica Industrial para práctica profesional. Participará en mantenimiento preventivo y correctivo de maquinaria.',
      requirements: ['Especialidad Mecánica', 'Disponibilidad inmediata', 'Responsable'],
    ),
    JobModel(
      id: '2',
      title: 'Ayudante Electricista',
      company: 'Instalaciones Eléctricas López',
      location: 'Lo Espejo, RM',
      type: JobType.internship,
      postedAgo: 'Hace 3 días',
      description:
          'Empresa de instalaciones eléctricas residenciales y comerciales busca estudiante en práctica para apoyar en instalaciones y mantenciones.',
      requirements: ['Especialidad Electricidad', 'Licencia de conducir (deseable)'],
    ),
    JobModel(
      id: '3',
      title: 'Operador CNC',
      company: 'Piezas y Tornos Ltda.',
      location: 'Pudahuel, RM',
      type: JobType.fullTime,
      postedAgo: 'Hace 1 semana',
      description:
          'Se busca técnico con experiencia en operación de tornos CNC para producción de piezas de precisión. Turno diurno.',
      requirements: ['Manejo de AutoCAD', 'Experiencia en CNC', 'Egresado técnico'],
    ),
    JobModel(
      id: '4',
      title: 'Soldador MIG/TIG',
      company: 'Estructuras Metálicas Acero',
      location: 'Cerrillos, RM',
      type: JobType.fullTime,
      postedAgo: 'Hace 5 días',
      description:
          'Requerimos soldador con experiencia en procesos MIG y TIG para fabricación de estructuras metálicas industriales.',
      requirements: ['Certificación en soldadura', 'Experiencia mínima 1 año'],
    ),
    JobModel(
      id: '5',
      title: 'Técnico en Refrigeración (Práctica)',
      company: 'Frío Industrial Ltda.',
      location: 'Maipú, RM',
      type: JobType.internship,
      postedAgo: 'Hace 1 día',
      description:
          'Empresa de mantención de equipos de refrigeración industrial y comercial acepta estudiante en práctica.',
      requirements: ['Especialidad Refrigeración o Electricidad', '4° medio'],
    ),
  ];

  List<JobModel> get _filtered => _selectedFilter == 'Todos'
      ? _mockJobs
      : _mockJobs.where((j) => j.typeLabel == _selectedFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trabajos y Prácticas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_filtered.length} ofertas disponibles',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Filters
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _filters[i] == _selectedFilter;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = _filters[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Job list
                Expanded(
                  child: ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _JobCard(job: _filtered[i]),
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

class _JobCard extends StatefulWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _applied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company logo placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.job.company,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.job.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.job.postedAgo,
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
              _TypeBadge(label: widget.job.typeLabel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.job.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.job.requirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.job.requirements
                  .map((r) => _ReqChip(label: r))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_applied)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Postulación enviada',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => setState(() => _applied = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Postular',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  const _TypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ReqChip extends StatelessWidget {
  final String label;
  const _ReqChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}
