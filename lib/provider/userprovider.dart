import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/UserDTO.dart';

class UserProvider extends ChangeNotifier {
  UserDTO? _user;
  UserDTO? get user => _user;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void updateLoginStatus(bool status) {
    _isLoggedIn = status;
    notifyListeners();
  }

  void updateUser(UserDTO newUser) {
    _user = newUser;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}