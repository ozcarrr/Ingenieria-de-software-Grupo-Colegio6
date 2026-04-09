import 'package:flutter/foundation.dart';

import '../models/models.dart';

class UserRoleController extends ChangeNotifier {
  UserRole _role = UserRole.student;

  UserRole get role => _role;

  void setRole(UserRole role) {
    if (_role == role) {
      return;
    }
    _role = role;
    notifyListeners();
  }
}
