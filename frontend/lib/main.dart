import 'package:flutter/material.dart';

import 'core/data/mock_data.dart';
import 'core/state/user_role_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/chat/presentation/pages/chats_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/jobs/presentation/pages/jobs_page.dart';
import 'features/network/presentation/pages/network_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

void main() {
  runApp(const KairosApp());
}

class KairosApp extends StatefulWidget {
  const KairosApp({super.key});

  @override
  State<KairosApp> createState() => _KairosAppState();
}

class _KairosAppState extends State<KairosApp> {
  final UserRoleController _roleController = UserRoleController();
  int _selectedIndex = 0;
  String? _liveNotification;

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _roleController,
        builder: (context, _) {
          final user = currentUserForRole(_roleController.role);
          return AppShell(
            selectedIndex: _selectedIndex,
            onSelectIndex: (index) => setState(() => _selectedIndex = index),
            currentUser: user,
            roleController: _roleController,
            liveNotification: _liveNotification,
            child: _buildScreen(),
          );
        },
      ),
    );
  }

  Widget _buildScreen() {
    final user = currentUserForRole(_roleController.role);
    switch (_selectedIndex) {
      case 0:
        return HomePage(currentUser: user, role: _roleController.role);
      case 1:
        return JobsPage(role: _roleController.role);
      case 2:
        return const NetworkPage();
      case 3:
        return ChatsPage(currentUser: user);
      case 4:
        return ProfilePage(currentUser: user);
      default:
        return HomePage(currentUser: user, role: _roleController.role);
    }
  }
}
