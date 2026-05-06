import 'package:flutter/material.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/theme/kairos_palette.dart';
import '../../../../core/widgets/k_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  final Set<int> _deleting = {};
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getAllUsers();
      if (mounted) setState(() => _users = data.cast<Map<String, dynamic>>());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar usuarios.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteUser(int userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('Eliminar perfil', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro que deseas eliminar la cuenta de "$name"?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Esta acción es permanente. Se eliminarán todos sus datos, publicaciones y postulaciones.',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar permanentemente', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting.add(userId));
    try {
      await _api.deleteUser(userId);
      if (mounted) {
        setState(() => _users.removeWhere((u) => u['id'] == userId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil de "$name" eliminado.'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el perfil.'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting.remove(userId));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users
        .where((u) =>
            (u['fullName'] as String? ?? '').toLowerCase().contains(q) ||
            (u['email'] as String? ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(tooltip: 'Actualizar', onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o correo...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('${filtered.length} usuario${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: KairosPalette.secondary)),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      final id = u['id'] as int;
                      final busy = _deleting.contains(id);
                      final status = u['status'] as String? ?? 'approved';
                      final roleLabel = switch ((u['role'] as String? ?? 'student').toLowerCase()) {
                        'company' => 'Empresa',
                        'staff' => 'Staff',
                        'alumni' => 'Egresado',
                        _ => 'Estudiante',
                      };
                      return KCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: KairosPalette.muted,
                              child: Text(
                                (u['fullName'] as String? ?? '?').substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u['fullName'] as String? ?? '-',
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(u['email'] as String? ?? '-',
                                      style: const TextStyle(color: KairosPalette.secondary, fontSize: 12)),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(roleLabel, style: const TextStyle(fontSize: 11)),
                                        side: BorderSide.none,
                                        backgroundColor: KairosPalette.muted,
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 6),
                                      if (status == 'pending')
                                        Chip(
                                          label: const Text('Pendiente', style: TextStyle(fontSize: 11, color: Colors.orange)),
                                          side: const BorderSide(color: Colors.orange),
                                          backgroundColor: Colors.orange.shade50,
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (busy)
                              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            else
                              IconButton(
                                tooltip: 'Eliminar perfil',
                                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                                onPressed: () => _deleteUser(id, u['fullName'] as String? ?? '-'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
