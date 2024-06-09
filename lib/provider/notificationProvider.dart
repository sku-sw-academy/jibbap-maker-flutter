import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  void incrementCount() {
    _notificationCount++;
    notifyListeners();
  }

  void resetCount() {
    _notificationCount = 0;
    notifyListeners();
  }
}