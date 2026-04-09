import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'models/models.dart';
import 'screens/home_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/network_screen.dart';
import 'screens/profile_screen.dart';
import 'state/user_role_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

class KairosApp extends StatefulWidget {
  const KairosApp({super.key});

  @override
  State<KairosApp> createState() => _KairosAppState();
}

class _KairosAppState extends State<KairosApp> {
  final UserRoleController _roleController = UserRoleController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairos Flutter Web',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _roleController,
        builder: (context, child) {
          final user = currentUserForRole(_roleController.role);
          return AppShell(
            selectedIndex: _selectedIndex,
            onSelectIndex: (index) => setState(() => _selectedIndex = index),
            currentUser: user,
            roleController: _roleController,
            child: _buildScreen(user),
          );
        },
      ),
    );
  }

  Widget _buildScreen(UserProfile currentUser) {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(currentUser: currentUser, role: _roleController.role);
      case 1:
        return JobsScreen(role: _roleController.role);
      case 2:
        return const NetworkScreen();
      case 3:
        return const MessagesScreen();
      case 4:
        return ProfileScreen(currentUser: currentUser);
      default:
        return HomeScreen(currentUser: currentUser, role: _roleController.role);
    }
  }
}
