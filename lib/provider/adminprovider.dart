import 'package:flutter_splim/dto/AdminDTO.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  AdminDTO? _admin;
  AdminDTO? get user => _admin;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void updateLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  void updateAdmin(AdminDTO newUser) {
    _admin = newUser;
    notifyListeners();
  }

  void clearAdmin() {
    _admin = null;
    notifyListeners();
  }
}