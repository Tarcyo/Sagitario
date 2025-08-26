import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String? _location;

  String? get location => _location;

  set location(String? value) {
    _location = value;
    notifyListeners();
  }


}
