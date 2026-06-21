import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ranking_provider.dart';
import '../theme/app_theme.dart';
import 'create_category_screen.dart';
import 'ranking_lists_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RankingProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rankingProvider = Provider.of<RankingProvider>(context);
    final user = authProvider.user;

    final filteredCategories = rankingProvider.categories.where((cat) {
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cat.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.insights_rounded, color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
            Text(
              'RankeRating',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => rankingProvider.loadCategories(),
        color: AppColors.accent,
        backgroundColor: AppColors.background,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Text(
                'Hey, ${user?.name.split(" ").first ?? "Explorer"}! 👋',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find topics to rank',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
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
              const SizedBox(height: 24),

              // Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filteredCategories.length} items',
                    style: const TextStyle(color: AppColors.accent, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories Listing
              if (rankingProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (filteredCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      const Icon(Icons.category_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No categories found.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateCategoryScreen(),
                            ),
                          );
                        },
                        child: const Text('Create the first one!'),
                      )
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RankingListsScreen(category: cat),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'cat_card_${cat.id}',
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Category Cover Image
                              Expanded(
                                flex: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        cat.imageUrl ?? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=300',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Category Title & Info
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cat.description,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCategoryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
