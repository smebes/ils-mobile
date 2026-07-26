import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprachapp/main.dart';
import 'package:sprachapp/screens/home_screen.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    await progressStore.init();
  });

  testWidgets('Home L1 render olur — Guten Tag görünür', (tester) async {
    await prepareSurface(tester);
    await tester.pumpWidget(
      testApp(home: const HomeScreen()),
    );

    await tester.pump();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.textContaining('Guten Tag').evaluate().isNotEmpty) break;
    }

    expect(find.textContaining('Guten Tag'), findsWidgets);
  });
}
