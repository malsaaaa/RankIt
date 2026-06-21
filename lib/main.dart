import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/ranking_provider.dart';
import 'theme/app_theme.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    // Suppress configuration errors to fall back cleanly to Mock implementations
    print("Firebase initialization skipped/failed. Running in Local Mock Mode. Details: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
      ],
      child: const RankeRatingApp(),
    ),
  );
}

class RankeRatingApp extends StatelessWidget {
  const RankeRatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RankeRating',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthCheckWrapper(),
    );
  }
}

class AuthCheckWrapper extends StatelessWidget {
  const AuthCheckWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider user changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
