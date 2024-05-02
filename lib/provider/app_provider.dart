import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _loading = false;

  bool get isLoading => _loading;

  void toggleLoading() {
    _loading = !isLoading;
    notifyListeners(); // Notify listeners of the change
  }

  
}
