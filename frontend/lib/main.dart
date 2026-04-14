import 'package:flutter/material.dart';

import 'core/models/user_profile.dart';
import 'core/state/user_role_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/auth/presentation/pages/login_page.dart';
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
  UserProfile? _currentUser;
  final UserRoleController _roleController = UserRoleController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  void _onLoginSuccess(UserProfile user) {
    _roleController.setRole(user.role);
    setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _currentUser == null
          ? LoginPage(onLoginSuccess: _onLoginSuccess)
          : AnimatedBuilder(
              animation: _roleController,
              builder: (context, _) {
                return AppShell(
                  selectedIndex: _selectedIndex,
                  onSelectIndex: (index) =>
                      setState(() => _selectedIndex = index),
                  currentUser: _currentUser!,
                  roleController: _roleController,
                  child: _buildScreen(),
                );
              },
            ),
    );
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(currentUser: _currentUser!, role: _roleController.role);
      case 1:
        return JobsPage(role: _roleController.role);
      case 2:
        return const NetworkPage();
      case 3:
        return ChatsPage(currentUser: _currentUser!);
      case 4:
        return ProfilePage(
          currentUser: _currentUser!,
          activeRole: _roleController.role,
        );
      default:
        return HomePage(currentUser: _currentUser!, role: _roleController.role);
    }
  }
}
