import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/token_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  String? _token;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  // Legacy Getters (Backward Compatibility)
  bool get isAuthenticated => _isLoggedIn;

  UserModel? get user {
    if (_currentUser == null) return null;
    return UserModel(
      id: _currentUser!['id']?.toString() ?? '',
      name: _currentUser!['name']?.toString() ?? '',
      email: _currentUser!['email']?.toString() ?? '',
      photoUrl: _currentUser!['photo_url']?.toString() ?? _currentUser!['photoUrl']?.toString(),
      createdAt: DateTime.tryParse(_currentUser!['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authApiService.register(
        name: name,
        email: email,
        password: password,
      );

      _token = response['token']?.toString();
      _currentUser = response['user'] as Map<String, dynamic>?;
      _isLoggedIn = true;

      if (_token != null) {
        await _tokenStorage.saveToken(_token!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authApiService.login(
        email: email,
        password: password,
      );

      _token = response['token']?.toString();
      _currentUser = response['user'] as Map<String, dynamic>?;
      _isLoggedIn = true;

      if (_token != null) {
        await _tokenStorage.saveToken(_token!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    final currentToken = _token;
    if (currentToken == null) {
      throw Exception('Cannot logout: User is not authenticated (no token found).');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authApiService.logout(currentToken);

      await _tokenStorage.deleteToken();
      _token = null;
      _currentUser = null;
      _isLoggedIn = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCurrentUser() async {
    final currentToken = _token;
    if (currentToken == null) {
      throw Exception('Cannot load user: No authentication token found.');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authApiService.getCurrentUser(currentToken);
      _currentUser = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final savedToken = await _tokenStorage.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _token = savedToken;
      await loadCurrentUser();
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      await _tokenStorage.deleteToken();
      _token = null;
      _currentUser = null;
      _isLoggedIn = false;
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Legacy Methods (Backward Compatibility)
  Future<bool> signIn(String email, String password) async {
    try {
      await login(email: email, password: password);
      return true;
    } catch (e) {
      // errorMessage is already set in login() catch block.
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      await register(name: name, email: email, password: password);
      return true;
    } catch (e) {
      // errorMessage is already set in register() catch block.
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await logout();
    } catch (e) {
      // Keep going if logout fails, so the user can still attempt sign out locally.
      await _tokenStorage.deleteToken();
      _token = null;
      _currentUser = null;
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
