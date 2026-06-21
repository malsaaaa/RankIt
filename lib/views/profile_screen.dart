import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Avatar & Name Card
            GlassCard(
              borderColor: AppColors.primary.withOpacity(0.3),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.primary,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User Name',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@rankerating.com',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Header
            Text(
              'My Activity Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Statistics Grid (Glassmorphism layout)
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(Icons.how_to_vote, color: AppColors.accent, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '12',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ballots Cast',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(Icons.format_list_bulleted, color: AppColors.primary, size: 28),
                        SizedBox(height: 8),
                        Text(
                          '3',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lists Created',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                authProvider.signOut();
                Navigator.pop(context); // Return to auth check layer
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.15),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
