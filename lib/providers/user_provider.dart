import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _role = "Both"; // default

  String get role => _role;

  void setRole(String newRole) {
    _role = newRole;
    notifyListeners(); // to refresh screens depend on role
  }
}