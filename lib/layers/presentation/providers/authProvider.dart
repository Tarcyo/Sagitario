import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _id;

  // Getter do token
  String? get token => _token;

  // Setter do token
  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  // Getter do id
  String? get id => _id;

  // Setter do id
  set id(String? value) {
    _id = value;
    notifyListeners();
  }

  // Método para logout
  void logout() {
    _token = null;
    _id = null;
    notifyListeners();
  }
}