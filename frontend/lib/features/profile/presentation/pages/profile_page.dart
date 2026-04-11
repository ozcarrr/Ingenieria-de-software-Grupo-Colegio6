import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.currentUser});

  final UserProfile currentUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api    = ApiClient();
  final _picker = ImagePicker();

  bool    _isUploadingAvatar  = false;
  bool    _isDownloadingReport = false;
  String? _uploadedAvatarUrl;

  Future<void> _pickAndUploadAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final result = await _api.uploadFile(image.path, 'image/jpeg');
      setState(() => _uploadedAvatarUrl = result['cdnUrl'] as String?);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _downloadReport() async {
    setState(() => _isDownloadingReport = true);
    try {
      final now   = DateTime.now();
      final bytes = await _api.downloadReport(month: now.month, year: now.year);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte descargado (${bytes.length} bytes).')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el reporte.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 12),
              if (user.socioemotionalTest != null) ...[
                _buildSocioemotional(user.socioemotionalTest!),
                const SizedBox(height: 12),
              ],
              _buildAbout(user),
              const SizedBox(height: 12),
              _buildSkills(user),
              const SizedBox(height: 12),
              _buildExperience(),
              const SizedBox(height: 12),
              _buildCertifications(),
              const SizedBox(height: 12),
              _buildProjects(),
              const SizedBox(height: 12),
              _buildReportCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserProfile user) {
    final avatarUrl = (_uploadedAvatarUrl ?? user.avatarUrl).trim();
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x260F766E), Color(0x1000B5AD)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -52),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 47,
                              backgroundImage:
                                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person_rounded)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: KairosPalette.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: _isUploadingAvatar
                                    ? const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Editar perfil'),
                    ),
                  ],
                ),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(user.title,
                    style: const TextStyle(
                        color: KairosPalette.secondary, fontSize: 16)),
                if (user.specialization != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text('Especializacion: ${user.specialization}'),
                    side: BorderSide.none,
                    backgroundColor: KairosPalette.muted,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _meta(Icons.pin_drop_rounded, user.location),
                    _meta(Icons.group_rounded, '${user.connections} conexiones'),
                    if (user.graduationYear != null)
                      _meta(Icons.school_rounded, 'Egreso ${user.graduationYear}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _counter('${user.connections}', 'Conexiones'),
                    _counter('23', 'Visitas perfil'),
                    _counter('8', 'Publicaciones'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Socioemotional ──────────────────────────────────────────────────────────

  Widget _buildSocioemotional(SocioemotionalTest test) {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: KairosPalette.primary),
              SizedBox(width: 8),
              Text('Evaluacion socioemocional',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          if (test.completed) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KairosPalette.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Test completado: ${test.completedDate ?? '-'}'),
            ),
            const SizedBox(height: 12),
            ...test.skills.map((skill) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(skill.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            if (skill.badge)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.star_rounded,
                                    size: 16, color: KairosPalette.accent),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: LinearProgressIndicator(
                          value: skill.level / 5,
                          minHeight: 9,
                          borderRadius: BorderRadius.circular(20),
                          backgroundColor: KairosPalette.border,
                          color: KairosPalette.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${skill.level}/5'),
                    ],
                  ),
                )),
          ] else ...[
            const Text(
                'Test pendiente. Realizar el test puede mejorar la visibilidad de tu perfil.'),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: KairosPalette.accent),
              onPressed: () {},
              child: const Text('Realizar test ahora'),
            ),
          ],
        ],
      ),
    );
  }

  // ── About ────────────────────────────────────────────────────────────────────

  Widget _buildAbout(UserProfile user) {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Acerca de mi',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(user.bio, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }

  // ── Skills ───────────────────────────────────────────────────────────────────

  Widget _buildSkills(UserProfile user) {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Habilidades tecnicas',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills
                .map((skill) =>
                    Chip(label: Text(skill), side: BorderSide.none))
                .toList(growable: false),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar habilidad'),
          ),
        ],
      ),
    );
  }

  // ── Experience ───────────────────────────────────────────────────────────────

  Widget _buildExperience() {
    const exp = [
      (
        'Proyecto de Robotica - Competencia Regional',
        'Liceo Tecnico Cardenal Jose Maria Caro',
        'La Florida, Santiago  2025-2026',
        'Diseno y programacion de robot autonomo de clasificacion. Primer lugar regional.'
      ),
      (
        'Ayudante de Laboratorio',
        'Liceo Tecnico Cardenal Jose Maria Caro',
        'La Florida, Santiago  2025',
        'Apoyo en mantencion y preparacion de equipos de laboratorio de mecatronica.'
      ),
    ];

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Experiencia',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...exp.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 52,
              leading: _sectionBubble(Icons.work_rounded),
              title: Text(e.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${e.$2}\n${e.$3}\n${e.$4}'),
              isThreeLine: true,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar experiencia'),
          ),
        ],
      ),
    );
  }

  // ── Certifications ───────────────────────────────────────────────────────────

  Widget _buildCertifications() {
    const certs = [
      ('Curso de Arduino Avanzado', 'INACAP  2025'),
      ('Certificacion en Impresion 3D', 'FabLab Santiago  2025'),
      ('Programacion en C++', 'Coursera  2024'),
    ];

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certificaciones y formacion',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...certs.map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 52,
              leading: _sectionBubble(Icons.school_rounded),
              title: Text(c.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(c.$2),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar certificacion'),
          ),
        ],
      ),
    );
  }

  // ── Projects ─────────────────────────────────────────────────────────────────

  Widget _buildProjects() {
    const projects = [
      (
        'Robot Clasificador Autonomo',
        'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=900',
        'Robot que clasifica objetos por color y tamano usando sensores y Arduino.'
      ),
      (
        'Sistema de Riego Automatizado',
        'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=900',
        'Control de riego por humedad del suelo y temperatura para invernadero.'
      ),
    ];

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Proyectos destacados',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth > 800 ? 2 : 1;
              return GridView.builder(
                itemCount: projects.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final p = projects[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: KairosPalette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(p.$2,
                                width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.$1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(p.$3,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Report ───────────────────────────────────────────────────────────────────

  Widget _buildReportCard() {
    return KCard(
      borderColor: KairosPalette.primary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: KairosPalette.primary),
              SizedBox(width: 8),
              Text('Reporte de actividad',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'Descarga un resumen PDF de tu participacion social del mes actual.',
              style: TextStyle(color: KairosPalette.secondary)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloadingReport ? null : _downloadReport,
              style: ElevatedButton.styleFrom(
                  backgroundColor: KairosPalette.primary),
              icon: _isDownloadingReport
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download_rounded, size: 18),
              label: const Text('Descargar reporte mensual'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _meta(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: KairosPalette.secondary),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(color: KairosPalette.secondary)),
      ],
    );
  }

  Widget _counter(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: KairosPalette.primary)),
          Text(label,
              style: const TextStyle(color: KairosPalette.secondary)),
        ],
      ),
    );
  }

  Widget _sectionBubble(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: KairosPalette.muted,
      child: Icon(icon, size: 20, color: KairosPalette.primary),
    );
  }
}
