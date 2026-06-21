import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/secrets.dart';
import '../models/item_model.dart';

class GeminiService {
  /// Analyzes a list of ranked items and generates a smart analysis summary.
  /// If the Gemini API key is not set, generates an analytical mock summary locally.
  Future<String> analyzeRankings({
    required String listTitle,
    required String listDescription,
    required List<ItemModel> items,
  }) async {
    final apiKey = Secrets.geminiApiKey;

    if (apiKey == 'YOUR_GEMINI_API_KEY' || apiKey.isEmpty) {
      print("Gemini API Key not configured. Generating high-quality local analysis...");
      return _generateLocalMockAnalysis(listTitle, items);
    }

    if (items.isEmpty) {
      return "There are currently no items in this list to analyze. Add items and start voting!";
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      final itemsSummary = items.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final item = entry.value;
        return "$index. ${item.name} (Score: ${item.score.toStringAsFixed(1)} pts, Votes: ${item.votesCount}) - Description: ${item.description}";
      }).join('\n');

      final prompt = """
You are an expert pop-culture and ranking data analyst for RankeRating, a community aggregation platform.
Analyze the following community ranking leaderboard data:

Topic: "$listTitle"
Description: "$listDescription"

Leaderboard Data (sorted from #1 down):
$itemsSummary

Please write a brief, engaging, and professional analytical summary (maximum 2 paragraphs).
Highlight:
- The #1 rank favorite, and why users likely preferred it.
- Key observations about the margin between top competitors (e.g. close match or landslide victory).
- General insights on community preferences based on the items and descriptions.

Tone should be modern, polished, and exciting. Keep it clean and do not include markdown titles.
""";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        throw Exception("Gemini returned empty text response");
      }
    } catch (e) {
      print("Error calling Gemini API: $e. Falling back to local mock analysis.");
      return _generateLocalMockAnalysis(listTitle, items);
    }
  }

  Future<String> _generateLocalMockAnalysis(String listTitle, List<ItemModel> items) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate AI typing/processing latency
    
    if (items.isEmpty) {
      return "No items have been ranked in '$listTitle' yet. Add items and cast your vote to see AI analysis!";
    }

    final topItem = items.first;
    final runnerUp = items.length > 1 ? items[1] : null;

    final String comparisonText = runnerUp != null
        ? "with **${topItem.name}** leading the pack at **${topItem.score.toStringAsFixed(1)} points**, followed closely by **${runnerUp.name}** at **${runnerUp.score.toStringAsFixed(1)} points**."
        : "with **${topItem.name}** holding the undisputed spot with **${topItem.score.toStringAsFixed(1)} points**.";

    return """Based on the aggregated community ballots for **"$listTitle"**, we are seeing a clear preference trend. The community has positioned **${topItem.name}** at the top, $comparisonText This suggests that voters strongly value its core strengths, which match the primary themes of this ranking category.

Overall, the voting pattern reveals a competitive landscape. While the top spots are heavily contested, the trailing candidates indicate a diverse set of opinions, reflecting that while there is consensus on the category leaders, individual voters still maintain strong niche preferences. As more community members submit their ballots, it will be fascinating to see if the leaderboard remains stable or if a new contender takes the crown!""";
  }
}
