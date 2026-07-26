import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../services/config_service.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    try {
      if (_isSignUp) {
        await authProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      // Navigation handled automatically by AuthCheckWrapper
      // when AuthProvider.isAuthenticated changes to true.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showConfigSettingsDialog() {
    final configService = ConfigService();
    final urlController = TextEditingController();
    final cloudNameController = TextEditingController();
    final uploadPresetController = TextEditingController();
    final apiKeyController = TextEditingController();
    final geminiKeyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder(
          future: Future.wait([
            configService.getBaseUrl(),
            configService.getCloudName(),
            configService.getUploadPreset(),
            configService.getCloudinaryApiKey(),
            configService.getGeminiKey(),
          ]),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              urlController.text = snapshot.data![0];
              cloudNameController.text = snapshot.data![1];
              uploadPresetController.text = snapshot.data![2];
              apiKeyController.text = snapshot.data![3];
              geminiKeyController.text = snapshot.data![4];
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              title: Row(
                children: const [
                  Icon(Icons.settings_outlined, color: AppColors.accent),
                  SizedBox(width: 12),
                  Text(
                    'Connection Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Configure your local servers and cloud API credentials.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'Laravel Server API URL',
                          hintText: 'e.g. http://127.0.0.1:8000/api',
                          prefixIcon: Icon(Icons.dns_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'API URL is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cloudNameController,
                        decoration: const InputDecoration(
                          labelText: 'Cloudinary Cloud Name',
                          hintText: 'e.g. dfq28c11q',
                          prefixIcon: Icon(Icons.cloud_queue_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: uploadPresetController,
                        decoration: const InputDecoration(
                          labelText: 'Cloudinary Upload Preset',
                          hintText: 'e.g. preset_unsigned',
                          prefixIcon: Icon(Icons.upload_file_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Cloudinary API Key (Public)',
                          hintText: 'e.g. 786632886799257',
                          prefixIcon: Icon(Icons.key_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: geminiKeyController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'OpenRouter API Key',
                          hintText: 'Enter OpenRouter API key',
                          prefixIcon: Icon(Icons.api_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    await configService.setBaseUrl(urlController.text);
                    await configService.setCloudName(cloudNameController.text);
                    await configService.setUploadPreset(uploadPresetController.text);
                    await configService.setCloudinaryApiKey(apiKeyController.text);
                    await configService.setGeminiKey(geminiKeyController.text);

                    // Update runtime active URL
                    ApiService.baseUrl = urlController.text.trim();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
              ),
            ),
          ),
          
          // Main Scrollable Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand / Logo Section
                    Icon(
                      Icons.insights_rounded,
                      size: 72,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'RankeIt',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 32,
                        letterSpacing: 1.5,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Community-Based Ranking Aggregation',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Login Card
                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isSignUp ? 'Create Account' : 'Welcome Back',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // Name Field (Only on Sign Up)
                            if (_isSignUp) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Error Message Display
                            if (authProvider.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Submit Button
                            ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _submit,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(_isSignUp ? 'SIGN UP' : 'LOG IN'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Expanded(child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.border)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      try {
                                        await authProvider.signInWithGoogle();
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              icon: FaIcon(FontAwesomeIcons.google, size: 16, color: AppColors.accent),
                              label: const Text('CONTINUE WITH GOOGLE'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Toggle Auth State Text
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          authProvider.signOut(); // Clear errors
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Log In'
                            : 'Don\'t have an account? Sign Up',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
