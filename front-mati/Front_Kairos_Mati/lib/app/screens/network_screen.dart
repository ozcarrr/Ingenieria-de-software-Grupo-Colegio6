import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/kairos_palette.dart';
import '../widgets/k_card.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _connected = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = suggestedUsers.where((u) {
      if (query.isEmpty) {
        return true;
      }
      return u.name.toLowerCase().contains(query) ||
          u.title.toLowerCase().contains(query) ||
          u.skills.any((skill) => skill.toLowerCase().contains(query));
    }).toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu Red Profesional', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Conecta con profesionales tecnicos y amplia tus oportunidades.'),
          const SizedBox(height: 16),
          KCard(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, oficio o habilidad...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 900;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: wide ? 2 : 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: wide ? 3 : 4,
                children: [
                  _stats(Icons.people_alt_rounded, '${_connected.length + 234}', 'Conexiones totales'),
                  _stats(Icons.person_add_alt_1_rounded, '${suggestedUsers.length}', 'Sugerencias para ti'),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              int cross = 1;
              if (constraints.maxWidth > 1260) {
                cross = 3;
              } else if (constraints.maxWidth > 760) {
                cross = 2;
              }

              return GridView.builder(
                itemCount: visible.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final user = visible[index];
                  final connected = _connected.contains(user.id);
                  return KCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 72,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0x140F766E), Color(0x0F00B5AD)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(17),
                              topRight: Radius.circular(17),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -30),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(user.avatarUrl),
                                  ),
                                ),
                              ),
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const SizedBox(height: 2),
                              Text(user.title, style: const TextStyle(color: KairosPalette.secondary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.pin_drop_rounded, size: 16, color: KairosPalette.secondary),
                                  const SizedBox(width: 4),
                                  Text(user.location, style: const TextStyle(color: KairosPalette.secondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(user.bio, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: user.skills.take(3).map((skill) {
                                  return Chip(
                                    label: Text(skill),
                                    side: BorderSide.none,
                                    backgroundColor: KairosPalette.muted,
                                  );
                                }).toList(growable: false),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${user.connections} conexiones',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: KairosPalette.primary),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          if (connected) {
                                            _connected.remove(user.id);
                                          } else {
                                            _connected.add(user.id);
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: connected ? KairosPalette.muted : KairosPalette.accent,
                                        foregroundColor: connected ? KairosPalette.foreground : Colors.white,
                                      ),
                                      icon: const Icon(Icons.person_add_rounded, size: 16),
                                      label: Text(connected ? 'Conectado' : 'Conectar'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: const Text('Ver perfil'),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _stats(IconData icon, String value, String label) {
    return KCard(
      borderColor: KairosPalette.primary.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: KairosPalette.muted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: KairosPalette.primary),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              Text(label, style: const TextStyle(color: KairosPalette.secondary)),
            ],
          ),
        ],
      ),
    );
  }
}
