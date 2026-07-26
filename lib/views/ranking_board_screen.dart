import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../models/ranking_list_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/unsplash_search_dialog.dart';

class RankingBoardScreen extends StatefulWidget {
  final RankingListModel rankingList;

  const RankingBoardScreen({super.key, required this.rankingList});

  @override
  State<RankingBoardScreen> createState() => _RankingBoardScreenState();
}

class _RankingBoardScreenState extends State<RankingBoardScreen> {
  List<ItemModel> _allItems = [];
  List<ItemModel> _selectedItems = [];
  bool _isInitialized = false;
  bool _isSubmitting = false;
  bool _hasPreviousRanking = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  List<ItemModel> get _availableItems {
    final selectedIds = _selectedItems.map((e) => e.id).toSet();
    return _allItems.where((item) => !selectedIds.contains(item.id)).toList();
  }

  void _loadItems() async {
    final rankingProvider = Provider.of<RankingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await rankingProvider.loadTopicWithUserRanking(
        topicId: widget.rankingList.id,
        userId: authProvider.user!.id,
      );
    } else {
      await rankingProvider.loadItems(widget.rankingList.id);
    }

    setState(() {
      _allItems = List.from(rankingProvider.currentItems);
      _isInitialized = true;
    });

    final userRanking = rankingProvider.userRanking;
    if (userRanking.isNotEmpty) {
      final itemMap = {for (var item in _allItems) item.id: item};
      final sortedRanking = List<Map<String, dynamic>>.from(userRanking);
      sortedRanking.sort(
        (a, b) => (a['position'] as int).compareTo(b['position'] as int),
      );
      final rankedIds = sortedRanking.map((r) => r['candidate_id'] as String).toSet();
      final missingItems = _allItems.where((item) => !rankedIds.contains(item.id)).toList();

      setState(() {
        _selectedItems = sortedRanking
            .map((r) => itemMap[r['candidate_id'] as String])
            .whereType<ItemModel>()
            .toList();
        _selectedItems.addAll(missingItems);
        _hasPreviousRanking = true;
      });
    } else {
      setState(() {
        _selectedItems = List.from(_allItems);
        _hasPreviousRanking = false;
      });
    }
  }

  void _addToSelected(ItemModel item) {
    setState(() {
      _selectedItems.add(item);
    });
  }

  void _removeFromSelected(ItemModel item) {
    setState(() {
      _selectedItems.removeWhere((e) => e.id == item.id);
    });
  }

  void _showCandidateSelector() {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final searchQuery = searchController.text.toLowerCase();
            final filtered = _availableItems.where((item) {
              return item.name.toLowerCase().contains(searchQuery);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag Handle
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Title
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 20,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Select a candidate',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setSheetState(() {}),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search candidates...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setSheetState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // List
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 40,
                                      color:                                       AppColors.textSecondary
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      searchController.text.isEmpty
                                          ? 'No candidates available'
                                          : 'No matches found',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: GlassCard(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      borderColor:
                                          AppColors.border.withValues(alpha: 0.2),
                                      child: Row(
                                        children: [
                                          if (item.imageUrl != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: item.imageUrl!,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                  Icons.image,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          if (item.imageUrl != null)
                                            const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _addToSelected(item);
                                              Navigator.pop(sheetContext);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color:                                                 AppColors.accent
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 22,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    XFile? itemImage;
    String? externalImageUrl;
    final ImagePicker picker = ImagePicker();
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> showImageSourceOptions() async {
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
                          onTap: () async {
                            Navigator.pop(context);
                            try {
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 500,
                                maxHeight: 500,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  itemImage = picked;
                                  externalImageUrl = null;
                                });
                              }
                            } catch (e) {
                              debugPrint("Error picking image: $e");
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.cloud_download_outlined, color: AppColors.accent),
                          title: const Text('Search Unsplash (Cloud Photos)'),
                          onTap: () async {
                            Navigator.pop(context);
                            final selectedUrl = await showDialog<String>(
                              context: context,
                              builder: (context) => UnsplashSearchDialog(
                                initialQuery: nameController.text.isNotEmpty 
                                    ? nameController.text.trim() 
                                    : widget.rankingList.title,
                              ),
                            );
                            if (selectedUrl != null) {
                              setDialogState(() {
                                externalImageUrl = selectedUrl;
                                itemImage = null; // Clear local picked image
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              title: const Text(
                'Add Candidate Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: dialogLoading ? null : showImageSourceOptions,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: itemImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: kIsWeb
                                      ? Image.network(
                                          itemImage!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(itemImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : externalImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        externalImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: AppColors.accent,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Photo (Optional)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
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
                  onPressed: dialogLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
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
                            final rankingProvider =
                                Provider.of<RankingProvider>(
                                  context,
                                  listen: false,
                                );
                            await rankingProvider.createItem(
                              listId: widget.rankingList.id,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              imageFile: itemImage,
                              externalImageUrl: externalImageUrl,
                            );

                            _loadItems();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setDialogState(() {
                              dialogLoading = false;
                            });
                            debugPrint("Error adding item: $e");
                          }
                        },
                  child: dialogLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog() {
    if (_selectedItems.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 2 candidates before submitting.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final topCandidates = _selectedItems.take(3).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: const [
              Icon(Icons.how_to_vote_outlined, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'Confirm Your Ballot',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to submit this ranking? Here is your top choice summary:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < topCandidates.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? AppColors.accent.withValues(alpha: 0.2)
                                    : AppColors.border.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: i == 0 ? AppColors.accent : AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: i == 0 ? AppColors.accent : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                topCandidates[i].name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: This will overwrite any previous ranking you made for this topic.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('EDIT VOTE', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitBallot();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shadowColor: AppColors.accent.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('SUBMIT'),
            ),
          ],
        );
      },
    );
  }

  void _submitBallot() async {
    if (_selectedItems.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Select at least 2 candidates before submitting.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rankingProvider = Provider.of<RankingProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final orderedIds = _selectedItems.map((item) => item.id).toList();
      await rankingProvider.submitVote(
        listId: widget.rankingList.id,
        userId: authProvider.user!.id,
        userName: authProvider.user!.name,
        rankedItemIds: orderedIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Ballot submitted successfully! Leaderboard updated.",
            ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Arrange Rankings'),
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // ─── Header ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 22,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Your Ranking (${_selectedItems.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (_hasPreviousRanking)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 4),
                          child: Text(
                            'Previously submitted. You may edit your ranking at any time.',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  AppColors.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Add Candidate Button Removed

                // ─── Ranking List ──────────────────────────────────────
                Expanded(
                  child: _selectedItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color:
                                    AppColors.textSecondary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No candidates selected.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap 'Add Candidate' to start building your ranking.",
                                style: TextStyle(
                                  color:                                   AppColors.textSecondary
                                      .withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.transparent,
                          ),
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            itemCount: _selectedItems.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item =
                                    _selectedItems.removeAt(oldIndex);
                                _selectedItems.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _selectedItems[index];
                              final rankNumber = index + 1;

                              return Padding(
                                key: ValueKey(item.id),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  borderColor: rankNumber == 1
                                      ? AppColors.accent.withValues(alpha: 0.5)
                                      : rankNumber == 2
                                          ? const Color(0xFFC0C0C0)
                                              .withValues(alpha: 0.4)
                                          : rankNumber == 3
                                              ? const Color(0xFFCD7F32)
                                                  .withValues(alpha: 0.4)
                                              : AppColors.border
                                                  .withValues(alpha: 0.25),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      // Rank Badge
                                      Container(
                                        width: 36,
                                        height: 36,
                                        margin:
                                            const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          color: rankNumber == 1
                                              ? AppColors.accent
                                                  .withValues(alpha: 0.2)
                                              : rankNumber == 2
                                                  ? const Color(0xFFC0C0C0)
                                                      .withValues(alpha: 0.15)
                                                  : rankNumber == 3
                                                      ? const Color(0xFFCD7F32)
                                                          .withValues(alpha: 0.15)
                                                      : Colors.white
                                                          .withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: rankNumber == 1
                                                ? AppColors.accent
                                                : rankNumber == 2
                                                    ? const Color(0xFFC0C0C0)
                                                    : rankNumber == 3
                                                        ? const Color(
                                                            0xFFCD7F32)
                                                        : AppColors.border,
                                            width: 1.8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$rankNumber',
                                          style: TextStyle(
                                            color: rankNumber == 1
                                                ? AppColors.accent
                                                : rankNumber == 2
                                                    ? const Color(0xFFC0C0C0)
                                                    : rankNumber == 3
                                                        ? const Color(
                                                            0xFFCD7F32)
                                                        : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Image Avatar
                                      if (item.imageUrl != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: item.imageUrl!,
                                            width: 38,
                                            height: 38,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const SizedBox(
                                              width: 38,
                                              height: 38,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              Icons.image,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      if (item.imageUrl != null)
                                        const SizedBox(width: 12),

                                      // Name
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Remove button removed for ballot completeness

                                      // Drag Handle
                                      const Icon(
                                        Icons.drag_indicator,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),

                // ─── Submit Button ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 0),
                        AppColors.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          shadowColor: AppColors.accent.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.how_to_vote, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'SUBMIT BALLOT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
