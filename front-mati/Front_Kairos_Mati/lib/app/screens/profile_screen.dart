import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/kairos_palette.dart';
import '../widgets/k_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.currentUser});

  final UserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 12),
              if (currentUser.socioemotionalTest != null) _socioemotional(),
              const SizedBox(height: 12),
              _about(),
              const SizedBox(height: 12),
              _skills(),
              const SizedBox(height: 12),
              _experience(),
              const SizedBox(height: 12),
              _certifications(),
              const SizedBox(height: 12),
              _projects(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -52),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundImage: NetworkImage(currentUser.avatarUrl),
                    ),
                  ),
                ),
                Text(currentUser.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(currentUser.title, style: const TextStyle(color: KairosPalette.secondary, fontSize: 16)),
                if (currentUser.specialization != null) ...[
                  const SizedBox(height: 8),
                  Chip(label: Text('Especializacion: ${currentUser.specialization}')),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _meta(Icons.pin_drop_rounded, currentUser.location),
                    _meta(Icons.email_rounded, 'matias.silva@liceocardenal.cl'),
                    if (currentUser.graduationYear != null)
                      _meta(Icons.school_rounded, 'Egreso ${currentUser.graduationYear}'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _counter('${currentUser.connections}', 'Conexiones'),
                    _counter('23', 'Visitas perfil'),
                    _counter('8', 'Publicaciones'),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Editar perfil'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socioemotional() {
    final test = currentUser.socioemotionalTest!;
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: KairosPalette.primary),
              SizedBox(width: 8),
              Text('Evaluacion socioemocional', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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
                            Text(skill.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (skill.badge)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.star_rounded, size: 16, color: KairosPalette.accent),
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
            const Text('Test pendiente. Realizar test puede mejorar visibilidad del perfil.'),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: KairosPalette.accent),
              onPressed: () {},
              child: const Text('Realizar test ahora'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _about() {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Acerca de mi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(currentUser.bio, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }

  Widget _skills() {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Habilidades tecnicas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: currentUser.skills.map((skill) => Chip(label: Text(skill), side: BorderSide.none)).toList(growable: false),
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

  Widget _experience() {
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
          const Text('Experiencia', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...exp.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: KairosPalette.muted, child: Icon(Icons.work_rounded)),
              title: Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _certifications() {
    const certs = [
      ('Curso de Arduino Avanzado', 'INACAP  2025'),
      ('Certificacion en Impresion 3D', 'FabLab Santiago  2025'),
      ('Programacion en C++', 'Coursera  2024'),
    ];

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Certificaciones y formacion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...certs.map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: KairosPalette.muted, child: Icon(Icons.school_rounded)),
              title: Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _projects() {
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
          const Text('Proyectos destacados', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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
                            child: Image.network(p.$2, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(p.$3, maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _counter(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: KairosPalette.primary)),
          Text(label, style: const TextStyle(color: KairosPalette.secondary)),
        ],
      ),
    );
  }
}
