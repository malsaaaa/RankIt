import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authService.onAuthStateChanged.listen((UserModel? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.createUserWithEmailAndPassword(name, email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll(RegExp(r'\[.*\]'), '').trim());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setError(null);
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
