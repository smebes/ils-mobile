import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprachapp/widgets.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('S4: eksik asset SoftMediaPlaceholder gösterir, kırık ikon yok',
      (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);

    await tester.pumpWidget(
      testApp(
        home: const Scaffold(
          body: Center(
            child: MediaImage(
              'assets/vocab/missing_for_test_xyz.svg',
              height: 160,
              width: 160,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('soft_media_error')), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    expect(find.byIcon(Icons.broken_image), findsNothing);
    probe.expectClean();
  });

  testWidgets('S4: boş path soft placeholder (kırık ikon yok)', (tester) async {
    await prepareSurface(tester);
    await tester.pumpWidget(
      testApp(
        home: const Scaffold(
          body: Center(
            child: MediaImage('', height: 120, width: 120),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('soft_media_error')), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
  });
}
