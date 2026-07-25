import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprachapp/main.dart';
import 'package:sprachapp/screens/home_screen.dart';
import 'package:sprachapp/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await progressStore.init();
  });

  testWidgets('Home L1 render olur — Guten Tag görünür', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.textContaining('HEUTE LERNEN').evaluate().isNotEmpty) break;
    }

    expect(find.textContaining('Guten Tag'), findsWidgets);
    expect(find.textContaining('HEUTE LERNEN'), findsOneWidget);
    expect(find.textContaining('Lektion 1'), findsWidgets);
  });
}
