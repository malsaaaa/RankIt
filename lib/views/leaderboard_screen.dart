import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ranking_list_model.dart';
import '../providers/ranking_provider.dart';
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
  String? _aiAnalysisText;

  void _generateAiAnalysis() async {
    setState(() {
      _isGeneratingAi = true;
      _aiAnalysisText = null;
    });

    final provider = Provider.of<RankingProvider>(context, listen: false);
    
    // Request analysis from Gemini
    final summary = await provider.generateAiAnalysis(
      listId: widget.rankingList.id,
      title: widget.rankingList.title,
      description: widget.rankingList.description,
    );

    if (mounted) {
      setState(() {
        _isGeneratingAi = false;
        _aiAnalysisText = summary;
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
                    borderColor: AppColors.accent.withOpacity(0.3),
                    color: AppColors.primary.withOpacity(0.05),
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

          final totalCandidates = items.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // List Title Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassCard(
                  borderColor: AppColors.primary.withOpacity(0.4),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          // AI Summary Action
                          if (items.isNotEmpty)
                            TextButton.icon(
                              onPressed: _isGeneratingAi ? null : _generateAiAnalysis,
                              icon: _isGeneratingAi
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                                    )
                                  : const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                              label: const Text(
                                'AI Summary',
                                style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
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
                                  ? AppColors.accent.withOpacity(0.4)
                                  : AppColors.border.withOpacity(0.2),
                              child: Row(
                                children: [
                                  // Medal or Rank Number
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: rank == 1
                                          ? const Color(0xFFFFD700).withOpacity(0.15) // Gold
                                          : rank == 2
                                              ? const Color(0xFFC0C0C0).withOpacity(0.15) // Silver
                                              : rank == 3
                                                  ? const Color(0xFFCD7F32).withOpacity(0.15) // Bronze
                                                  : Colors.white.withOpacity(0.02),
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
                                  const SizedBox(width: 16),

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
    );
  }
}
