import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/ranking_list_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';

class RankingBoardScreen extends StatefulWidget {
  final RankingListModel rankingList;

  const RankingBoardScreen({super.key, required this.rankingList});

  @override
  State<RankingBoardScreen> createState() => _RankingBoardScreenState();
}

class _RankingBoardScreenState extends State<RankingBoardScreen> {
  List<ItemModel> _localItems = [];
  bool _isInitialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
    await rankingProvider.loadItems(widget.rankingList.id);
    setState(() {
      _localItems = List.from(rankingProvider.currentItems);
      _isInitialized = true;
    });
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    File? itemImage;
    final ImagePicker picker = ImagePicker();
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDialogImage() async {
              try {
                final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);
                if (picked != null) {
                  setDialogState(() {
                    itemImage = File(picked.path);
                  });
                }
              } catch (e) {
                print("Error picking image: $e");
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              title: const Text('Add Candidate Item', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mini Image Pick
                      GestureDetector(
                        onTap: dialogLoading ? null : pickDialogImage,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: itemImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(itemImage!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined, color: AppColors.accent),
                                    SizedBox(height: 8),
                                    Text('Add Photo (Optional)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        enabled: !dialogLoading,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        enabled: !dialogLoading,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Short Description',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setDialogState(() {
                            dialogLoading = true;
                          });

                          try {
                            final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
                            await rankingProvider.createItem(
                              listId: widget.rankingList.id,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              imageFile: itemImage,
                            );
                            
                            // Re-fetch and sync state
                            _loadItems();
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setDialogState(() {
                              dialogLoading = false;
                            });
                            print("Error adding item: $e");
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitBallot() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);

    if (authProvider.user == null) return;
    if (_localItems.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final orderedIds = _localItems.map((item) => item.id).toList();
      
      await rankingProvider.submitVote(
        listId: widget.rankingList.id,
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        rankedItemIds: orderedIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ballot submitted successfully! Leaderboard updated."),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit ballot: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Arrange Rankings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppColors.accent),
            tooltip: 'Add Candidate Item',
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Text(
                    'Drag and drop items to arrange your Top 10 choice (Rank 1 at the top gets 10 points):',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Reorderable List
                Expanded(
                  child: _localItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.playlist_add, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              const Text('No candidate items yet.', style: TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _showAddItemDialog,
                                child: const Text('ADD FIRST CANDIDATE'),
                              ),
                            ],
                          ),
                        )
                      : Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent, // Fix transparent background drag shadow
                          ),
                          child: ReorderableListView.builder(
                            itemCount: _localItems.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = _localItems.removeAt(oldIndex);
                                _localItems.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _localItems[index];
                              final rankNumber = index + 1;
                              
                              return Padding(
                                key: ValueKey(item.id),
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  borderColor: rankNumber == 1
                                      ? AppColors.accent.withOpacity(0.5)
                                      : AppColors.border.withOpacity(0.3),
                                  child: Row(
                                    children: [
                                      // Rank Badge
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: rankNumber == 1
                                              ? AppColors.accent.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: rankNumber == 1 ? AppColors.accent : AppColors.border,
                                            width: 1.5,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '#$rankNumber',
                                          style: TextStyle(
                                            color: rankNumber == 1 ? AppColors.accent : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Image Avatar (Cloudinary/Mock)
                                      if (item.imageUrl != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: item.imageUrl!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const SizedBox(width: 44, height: 44),
                                            errorWidget: (context, url, error) => const Icon(Icons.image),
                                          ),
                                        ),
                                      const SizedBox(width: 12),

                                      // Item Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              item.description,
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Reorder handle icon
                                      const Icon(Icons.drag_indicator, color: AppColors.textSecondary),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
                
                // Submit Button Panel
                if (_localItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBallot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        shadowColor: AppColors.accent.withOpacity(0.4),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                            )
                          : const Text('SUBMIT BALLOT', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
    );
  }
}
