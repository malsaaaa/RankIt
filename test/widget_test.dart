import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rankeit/main.dart';
import 'package:rankeit/providers/auth_provider.dart';
import 'package:rankeit/providers/ranking_provider.dart';

class MockAuthProvider extends AuthProvider {
  @override
  Future<void> restoreSession() async {
    // Return instantly to avoid triggering real storage or network calls in tests
    return;
  }
}

void main() {
  testWidgets('RankeIt app smoke test', (WidgetTester tester) async {
    // Build our app using MockAuthProvider to boot cleanly
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
          ChangeNotifierProvider(create: (_) => RankingProvider()),
        ],
        child: const RankeItApp(),
      ),
    );

    // Rebuild the tree after the microtasks/futures run
    await tester.pump();

    // Verify that the title 'RankeIt' is present on the login page.
    expect(find.text('RankeIt'), findsOneWidget);
  });
}
