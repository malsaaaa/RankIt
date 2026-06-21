import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _localLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking image: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to create categories."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _localLoading = true;
    });

    try {
      await rankingProvider.createCategory(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFile: _imageFile,
        userId: authProvider.user!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Category created successfully!"),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create category: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _localLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<RankingProvider>(context);
    final isLoading = _localLoading || rankingProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image Selector
              GestureDetector(
                onTap: isLoading ? null : _showImagePickerOptions,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.02),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image_outlined, size: 48, color: AppColors.accent),
                              SizedBox(height: 8),
                              Text(
                                'Select Cover Image',
                                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cloudinary storage integration',
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g., Board Games, Fast Food, Anime',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                enabled: !isLoading,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Tell users what they can rank in this category...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 55.0),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('CREATE CATEGORY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
