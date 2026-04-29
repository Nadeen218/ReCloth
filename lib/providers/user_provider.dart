import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // 1. Private variables
  String _role = "Both";
  String _name = "User";
  int _points = 0;
  String _email = "";
  String _address = ""; // Added this to fix the 'address' error

  // 2. Getters to access data from UI
  String get role => _role;
  String get name => _name;
  int get points => _points;
  String get email => _email;
  String get address => _address; // Added getter for address

  // 3. Method to update name (Used in Edit Profile)
  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  // 4. Method to update address (Used in Edit Profile)
  void setAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
  }

  // 5. Method to set individual role (used in Switch Account)
  void setRole(String newRole) {
    _role = newRole;
    notifyListeners(); // Refreshes Home, Nav Bar, and Profile immediately
  }

  // 6. Method to update all details at once (used in Login & Splash)
  void setUserDetails({
    required String name,
    required String role,
    required String email,
    String? address, // Added address here
    int? points,
  }) {
    _name = name;
    _role = role;
    _email = email;
    _address = address ?? "";
    _points = points ?? 0;
    notifyListeners();
  }

  // 7. Method to update points only (if user earns points)
  void updatePoints(int newPoints) {
    _points = newPoints;
    notifyListeners();
  }
  // Method to add points (increment)
  void addPoints(int pointsToAdd) {
    _points += pointsToAdd; // This adds 30 to the current balance
    notifyListeners();
  }
}