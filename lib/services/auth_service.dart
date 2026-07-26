import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class BaseAuthService {
  Stream<UserModel?> get onAuthStateChanged;
  UserModel? get currentUser;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  );
  Future<UserModel> signInWithGoogle();
  Future<String?> getIdToken();
  Future<void> signOut();
}

class AuthService implements BaseAuthService {
  FirebaseAuth? _firebaseAuth;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();
  UserModel? _cachedUser;

  // Set this to true to force Mock authentication for debugging/local testing
  static bool useMock = false;

  // Local mock store for when Firebase is not configured or in mockup mode
  static final Map<String, Map<String, String>> _mockUsers = {
    'demo@rankerating.com': {
      'id': 'demo_user_123',
      'name': 'Demo User',
      'password': 'password123',
    },
  };

  AuthService() {
    _init();
    debugPrint("AuthService started");
    debugPrint("useMock = $useMock");
  }

  void _init() {
    try {
      if (!useMock) {
        _firebaseAuth = FirebaseAuth.instance;
        _firebaseAuth!.authStateChanges().listen(
          (User? firebaseUser) {
            if (firebaseUser != null) {
              _cachedUser = UserModel(
                id: firebaseUser.uid,
                name:
                    firebaseUser.displayName ??
                    firebaseUser.email?.split('@').first ??
                    'User',
                email: firebaseUser.email ?? '',
                photoUrl: firebaseUser.photoURL,
                createdAt: DateTime.now(), // Fallback
              );
            } else {
              _cachedUser = null;
            }
            _authStateController.add(_cachedUser);
          },
          onError: (error) {
            debugPrint("FirebaseAuth error, switching to Mock: $error");
            _fallbackToMock();
          },
        );
      } else {
        _fallbackToMock();
      }
    } catch (e) {
      debugPrint(
        "Firebase initialization missing/failed. Falling back to Mock Auth. Error: $e",
      );
      useMock = true;
      _fallbackToMock();
    }
  }

  void _fallbackToMock() {
    debugPrint("SWITCHED TO MOCK AUTH");
    useMock = true;
    _cachedUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<UserModel?> get onAuthStateChanged => _authStateController.stream;

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (useMock) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network latency
      final normalizedEmail = email.trim().toLowerCase();
      if (_mockUsers.containsKey(normalizedEmail) &&
          _mockUsers[normalizedEmail]!['password'] == password) {
        final userData = _mockUsers[normalizedEmail]!;
        _cachedUser = UserModel(
          id: userData['id']!,
          name: userData['name']!,
          email: normalizedEmail,
          createdAt: DateTime.now(),
        );
        _authStateController.add(_cachedUser);
        return _cachedUser!;
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email or password is incorrect.',
        );
      }
    } else {
      try {
        final credentials = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final firebaseUser = credentials.user!;
        _cachedUser = UserModel(
          id: firebaseUser.uid,
          name:
              firebaseUser.displayName ??
              firebaseUser.email?.split('@').first ??
              'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        _authStateController.add(_cachedUser);
        return _cachedUser!;
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      final normalizedEmail = email.trim().toLowerCase();
      if (_mockUsers.containsKey(normalizedEmail)) {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.',
        );
      }
      final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _mockUsers[normalizedEmail] = {
        'id': newId,
        'name': name,
        'password': password,
      };
      _cachedUser = UserModel(
        id: newId,
        name: name,
        email: normalizedEmail,
        createdAt: DateTime.now(),
      );
      _authStateController.add(_cachedUser);
      return _cachedUser!;
    } else {
      try {
        final credentials = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final firebaseUser = credentials.user!;
        await firebaseUser.updateDisplayName(name);

        _cachedUser = UserModel(
          id: firebaseUser.uid,
          name: name,
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
        );
        _authStateController.add(_cachedUser);
        return _cachedUser!;
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _cachedUser = UserModel(
        id: 'mock_google_user_123',
        name: 'Mock Google User',
        email: 'google@rankit.demo',
        createdAt: DateTime.now(),
      );
      _authStateController.add(_cachedUser);
      return _cachedUser!;
    } else {
      try {
        final GoogleSignIn googleSignIn = _getGoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw FirebaseAuthException(
            code: 'sign-in-aborted',
            message: 'Sign in with Google was aborted.',
          );
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final credentials = await _firebaseAuth!.signInWithCredential(credential);
        final firebaseUser = credentials.user!;

        _cachedUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        _authStateController.add(_cachedUser);
        return _cachedUser!;
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<String?> getIdToken() async {
    if (useMock || _firebaseAuth == null) {
      return 'mock_firebase_uid_123456';
    }
    try {
      return await _firebaseAuth!.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  GoogleSignIn _getGoogleSignIn() {
    return GoogleSignIn(
      clientId: kIsWeb ? '105969995275-l5ilmcnbqn1mumf3ajcaabqovl6j3m0h.apps.googleusercontent.com' : null,
    );
  }

  @override
  Future<void> signOut() async {
    if (useMock) {
      _cachedUser = null;
      _authStateController.add(null);
    } else {
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
      try {
        await _getGoogleSignIn().signOut();
      } catch (_) {}
    }
  }
}
