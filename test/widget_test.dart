import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rankerating/main.dart';
import 'package:rankerating/providers/auth_provider.dart';
import 'package:rankerating/providers/ranking_provider.dart';

void main() {
  testWidgets('RankeRating app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => RankingProvider()),
        ],
        child: const RankeRatingApp(),
      ),
    );

    // Verify that the title 'RankeRating' is present on the login page.
    expect(find.text('RankeRating'), findsOneWidget);
  });
}
