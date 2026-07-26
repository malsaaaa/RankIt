import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/ranking_list_model.dart';
import '../providers/ranking_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'ranking_board_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  final RankingListModel rankingList;

  const LeaderboardScreen({super.key, required this.rankingList});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isGeneratingAi = false;
  List<Map<String, dynamic>>? _loadedLeaderboardItems;

  void _showSuggestCandidateDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to suggest candidates.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmittingSuggestion = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              title: Row(
                children: const [
                  Icon(Icons.lightbulb_outline, color: AppColors.accent),
                  SizedBox(width: 10),
                  Text(
                    'Suggest Candidate',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Suggest a missing item for the admin to review and add to this list.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Candidate Name',
                        hintText: 'e.g. Zinedine Zidane',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a candidate name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Brief Description',
                        hintText: 'e.g. Legendary midfielder who won...',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmittingSuggestion ? null : () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSubmittingSuggestion
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() {
                            isSubmittingSuggestion = true;
                          });

                          try {
                            final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
                            await rankingProvider.suggestCandidate(
                              topicId: widget.rankingList.id,
                              userId: user.id,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Suggestion submitted! The admin will review it.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isSubmittingSuggestion = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to submit suggestion: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmittingSuggestion
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('SUGGEST'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateAiAnalysis() async {
    if (_loadedLeaderboardItems == null || _loadedLeaderboardItems!.isEmpty) return;

    setState(() {
      _isGeneratingAi = true;
    });

    final provider = Provider.of<RankingProvider>(context, listen: false);
    
    // Request analysis from Gemini
    final summary = await provider.generateAiAnalysis(
      listId: widget.rankingList.id,
      title: widget.rankingList.title,
      description: widget.rankingList.description,
      rawItems: _loadedLeaderboardItems!,
    );

    if (mounted) {
      setState(() {
        _isGeneratingAi = false;
      });
      _showAiSummaryBottomSheet(summary);
    }
  }

  void _showAiSummaryBottomSheet(String summary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppColors.accent),
                      SizedBox(width: 12),
                      Text(
                        'Gemini AI Analysis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    borderColor: AppColors.accent.withValues(alpha: 0.3),
                    color: AppColors.primary.withValues(alpha: 0.05),
                    child: Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('DISMISS'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<RankingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Community Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: rankingProvider.getLeaderboard(widget.rankingList.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load leaderboard. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          _loadedLeaderboardItems = items;

          final totalCandidates = items.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // List Title Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassCard(
                  borderColor: AppColors.primary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.rankingList.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.rankingList.description,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            '$totalCandidates candidates ranked',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Leaderboard Rankings
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bar_chart, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            const Text('No rankings calculated yet.', style: TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            const Text('Be the first to vote!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RankingBoardScreen(rankingList: widget.rankingList),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.how_to_vote),
                              label: const Text('CAST VOTE'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final name = item['name'];
                          final points = item['total_points'];
                          final displayName = (name ?? '').toString();
                          final pointsValue = double.tryParse((points ?? '').toString()) ?? 0;
                          final rank = index + 1;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              borderColor: rank <= 3
                                  ? AppColors.accent.withValues(alpha: 0.4)
                                  : AppColors.border.withValues(alpha: 0.2),
                              child: Row(
                                children: [
                                  // Medal or Rank Number
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: rank == 1
                                          ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                                          : rank == 2
                                              ? const Color(0xFFC0C0C0).withValues(alpha: 0.15)
                                              : rank == 3
                                                  ? const Color(0xFFCD7F32).withValues(alpha: 0.15)
                                                  : Colors.white.withValues(alpha: 0.02),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: rank == 1
                                            ? const Color(0xFFFFD700)
                                            : rank == 2
                                                ? const Color(0xFFC0C0C0)
                                                : rank == 3
                                                    ? const Color(0xFFCD7F32)
                                                    : AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: rank <= 3
                                        ? Icon(
                                            Icons.workspace_premium,
                                            size: 18,
                                            color: rank == 1
                                                ? const Color(0xFFFFD700)
                                                : rank == 2
                                                    ? const Color(0xFFC0C0C0)
                                                    : const Color(0xFFCD7F32),
                                          )
                                        : Text(
                                            '$rank',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Image Avatar
                                  if (item['image_url'] != null && (item['image_url'] as String).isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: item['image_url'] as String,
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const SizedBox(
                                          width: 38,
                                          height: 38,
                                        ),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.image,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],

                                  // Candidate details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Score Points Badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${pointsValue.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      const Text(
                                        'points',
                                        style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Bottom Action Row
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RankingBoardScreen(rankingList: widget.rankingList),
                        ),
                      ).then((_) {
                        // Refresh items when returning
                        setState(() {});
                      });
                    },
                    icon: const Icon(Icons.how_to_vote),
                    label: const Text('VOTE / ARRANGE LIST'),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextButton.icon(
            onPressed: _showSuggestCandidateDialog,
            icon: const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 18),
            label: const Text(
              "Don't see your favorite? Suggest Candidate",
              style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
