import 'package:flutter/material.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _connected = <String>{};

  final _api = ApiClient();
  List<UserProfile> _apiSuggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final data = await _api.getNetworkSuggestions();
      final users = data.cast<Map<String, dynamic>>().map((json) {
        final roleStr = (json['role'] as String? ?? 'student').toLowerCase();
        final role = switch (roleStr) {
          'staff'   => UserRole.staff,
          'company' => UserRole.company,
          'alumni'  => UserRole.alumni,
          _         => UserRole.student,
        };
        return UserProfile(
          id: json['id'].toString(),
          name: json['fullName'] as String? ?? 'Usuario',
          role: role,
          title: json['title'] as String? ?? json['otherUserTitle'] as String? ?? '',
          avatarUrl: json['avatarUrl'] as String? ?? '',
          skills: const [],
          bio: json['bio'] as String? ?? '',
          location: json['location'] as String? ?? '',
          connections: json['followersCount'] as int? ?? 0,
        );
      }).toList();
      if (mounted) setState(() => _apiSuggestions = users);
    } catch (_) {
      // Fall back to mock data
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow(UserProfile user) async {
    final userId = int.tryParse(user.id);
    if (userId == null) {
      setState(() {
        if (_connected.contains(user.id)) {
          _connected.remove(user.id);
        } else {
          _connected.add(user.id);
        }
      });
      return;
    }

    final wasConnected = _connected.contains(user.id);
    setState(() {
      if (wasConnected) {
        _connected.remove(user.id);
      } else {
        _connected.add(user.id);
      }
    });

    try {
      if (wasConnected) {
        await _api.unfollowUser(userId);
      } else {
        await _api.followUser(userId);
      }
    } catch (_) {
      // Revert on failure
      if (mounted) {
        setState(() {
          if (wasConnected) {
            _connected.add(user.id);
          } else {
            _connected.remove(user.id);
          }
        });
      }
    }
  }

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
    final query = _searchController.text.trim().toLowerCase();
    final allSuggestions =
        _apiSuggestions.isNotEmpty ? _apiSuggestions : suggestedUsers;
    final visible = allSuggestions
        .where((u) {
          if (query.isEmpty) return true;
          return u.name.toLowerCase().contains(query) ||
              u.title.toLowerCase().contains(query) ||
              u.skills.any((skill) => skill.toLowerCase().contains(query));
        })
        .toList(growable: false);

    return SingleChildScrollView(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Red Profesional',
            style: TextStyle(
              fontSize: mobile ? 26 : 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Conecta con profesionales tecnicos y amplia tus oportunidades.',
          ),
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
          if (mobile)
            Column(
              children: [
                _stats(
                  Icons.people_alt_rounded,
                  '${_connected.length + 234}',
                  'Conexiones totales',
                ),
                const SizedBox(height: 10),
                _stats(
                  Icons.person_add_alt_1_rounded,
                  '${visible.length}',
                  'Sugerencias para ti',
                ),
              ],
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: wide ? 2 : 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                  children: [
                    _stats(
                      Icons.people_alt_rounded,
                      '${_connected.length + 234}',
                      'Conexiones totales',
                    ),
                    _stats(
                      Icons.person_add_alt_1_rounded,
                      '${visible.length}',
                      'Sugerencias para ti',
                    ),
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

              if (cross == 1) {
                return Column(
                  children: visible
                      .map(
                        (user) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _networkUserCard(user),
                        ),
                      )
                      .toList(growable: false),
                );
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
                  return _networkUserCard(user);
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 760 ? 26 : 30,
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

  Widget _networkUserCard(UserProfile user) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    final connected = _connected.contains(user.id);
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: mobile ? 62 : 72,
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
                  offset: Offset(0, mobile ? -24 : -30),
                  child: CircleAvatar(
                    radius: mobile ? 32 : 36,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: mobile ? 28 : 32,
                      backgroundImage: user.avatarUrl.trim().isNotEmpty
                          ? NetworkImage(user.avatarUrl)
                          : null,
                      child: user.avatarUrl.trim().isEmpty
                          ? const Icon(Icons.person_rounded)
                          : null,
                    ),
                  ),
                ),
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: mobile ? 17 : 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: KairosPalette.secondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.pin_drop_rounded,
                      size: 16,
                      color: KairosPalette.secondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: KairosPalette.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio,
                  maxLines: mobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: user.skills
                      .take(mobile ? 2 : 3)
                      .map((skill) {
                        return Chip(
                          label: Text(skill),
                          side: BorderSide.none,
                          backgroundColor: KairosPalette.muted,
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 10),
                Text(
                  '${user.connections} conexiones',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: KairosPalette.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleFollow(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: connected
                              ? KairosPalette.muted
                              : KairosPalette.accent,
                          foregroundColor: connected
                              ? KairosPalette.foreground
                              : Colors.white,
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
  }
}
