import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  // Getter do token
  String? get token => _token;

  // Setter do token
  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  // Método para logout
  void logout() {
    _token = null;
    notifyListeners();
  }
}
