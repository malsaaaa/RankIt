import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rankeit/main.dart';
import 'package:rankeit/providers/auth_provider.dart';
import 'package:rankeit/providers/ranking_provider.dart';

void main() {
  testWidgets('RankeIt app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => RankingProvider()),
        ],
        child: const RankeItApp(),
      ),
    );

    // Verify that the title 'RankeIt' is present on the login page.
    expect(find.text('RankeIt'), findsOneWidget);
  });
}
