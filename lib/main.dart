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
      child: const RankeItApp(),
    ),
  );
}

class RankeItApp extends StatelessWidget {
  const RankeItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RankeIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthCheckWrapper(),
    );
  }
}

class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  late Future<void> _restoreFuture;

  @override
  void initState() {
    super.initState();
    _restoreFuture = context.read<AuthProvider>().restoreSession().catchError((error) {
      // Handle error gracefully so the app defaults to LoginScreen on failure
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _restoreFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
