import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';
import 'leaderboard_screen.dart';

class RankingListsScreen extends StatefulWidget {
  final CategoryModel category;

  const RankingListsScreen({super.key, required this.category});

  @override
  State<RankingListsScreen> createState() => _RankingListsScreenState();
}

class _HomeScreenState {} // Typo protection or just standard code

class _RankingListsScreenState extends State<RankingListsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RankingProvider>(context, listen: false).loadRankingLists(widget.category.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateListDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.border),
              ),
              title: const Text('Create Ranking List', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'List Title',
                          hintText: 'e.g., Top Action Movies, Best Cafes',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe this ranking list...',
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
                    
                    if (authProvider.user == null) return;
                    
                    Navigator.pop(context); // Close dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Creating list...'), duration: Duration(seconds: 1)),
                    );

                    try {
                      await rankingProvider.createRankingList(
                        categoryId: widget.category.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        userId: authProvider.user!.id,
                      );
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("List created successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to create list: $e"),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('CREATE'),
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
    final rankingProvider = Provider.of<RankingProvider>(context);
    
    final filteredLists = rankingProvider.rankingLists.where((list) {
      return list.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          list.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible AppBar with Hero Background Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
                  ],
                ),
              ),
              background: Hero(
                tag: 'cat_card_${widget.category.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.category.imageUrl ?? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=400',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.background],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Search & Info Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.category.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search lists...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Lists items
          if (rankingProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else if (filteredLists.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt_outlined, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text('No ranking lists yet.', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _showCreateListDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('CREATE FIRST LIST'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderWithParagraph(
                (context, index) {
                  final list = filteredLists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeaderboardScreen(rankingList: list),
                          ),
                        );
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Left design accent
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                              ),
                              child: const Icon(Icons.format_list_numbered_rtl, color: AppColors.accent),
                            ),
                            const SizedBox(width: 16),
                            
                            // Info Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    list.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    list.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Chevron/Details indicator
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                const SizedBox(height: 4),
                                Text(
                                  '${list.itemsCount} items',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredLists.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showCreateListDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Custom SliverChildBuilderDelegate helper to avoid typo or syntax errors
class SliverChildBuilderWithParagraph extends SliverChildBuilderDelegate {
  SliverChildBuilderWithParagraph(Widget? Function(BuildContext, int) builder, {int? childCount})
      : super(builder, childCount: childCount);
}
