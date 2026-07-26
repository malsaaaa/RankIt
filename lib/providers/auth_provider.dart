import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
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
      photoUrl: _currentUser!['photo_url']?.toString(),
      createdAt: DateTime.now(),
    );
  }

  AuthProvider() {
    _authService.onAuthStateChanged.listen((user) async {
      if (user != null) {
        _isLoggedIn = true;
        try {
          final idToken = await _authService.getIdToken();
          _token = idToken;
          if (idToken != null) {
            await _tokenStorage.saveToken(idToken);
            await _syncUserWithBackend(idToken);
          }
        } catch (_) {}
        _currentUser ??= {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'photo_url': user.photoUrl,
        };
      } else {
        _isLoggedIn = false;
        _token = null;
        _currentUser = null;
        await _tokenStorage.deleteToken();
      }
      notifyListeners();
    });
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
      await _authService.createUserWithEmailAndPassword(name, email, password);
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
      await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signOut();
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
      if (AuthService.useMock) {
        final user = _authService.currentUser;
        if (user != null) {
          _isLoggedIn = true;
          _token = 'mock_firebase_uid_123456';
          _currentUser = {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'photo_url': user.photoUrl,
          };
        } else {
          _isLoggedIn = false;
          _token = null;
          _currentUser = null;
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _isLoggedIn = true;
          final idToken = await user.getIdToken();
          _token = idToken;
          if (idToken != null) {
            await _tokenStorage.saveToken(idToken);
            await _syncUserWithBackend(idToken);
          }
          _currentUser ??= {
            'id': user.uid,
            'name': user.displayName ?? user.email?.split('@').first ?? 'User',
            'email': user.email ?? '',
            'photo_url': user.photoURL,
          };
        } else {
          _isLoggedIn = false;
          _token = null;
          _currentUser = null;
          await _tokenStorage.deleteToken();
        }
      }
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
    }
  }

  // Legacy Methods (Backward Compatibility)
  Future<bool> signIn(String email, String password) async {
    try {
      await login(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      await register(name: name, email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await logout();
    } catch (e) {
      _token = null;
      _currentUser = null;
      _isLoggedIn = false;
      _isLoading = false;
      await _tokenStorage.deleteToken();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _syncUserWithBackend(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to sync user with backend: $e");
    }
  }
}
