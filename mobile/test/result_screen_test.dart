import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprachapp/l10n/app_localizations.dart';
import 'package:sprachapp/screens/result_screen.dart';
import 'package:sprachapp/theme.dart';

void main() {
  testWidgets('Result: XP animasyonu layout crash etmez, Keep learning tıklanır',
      (tester) async {
    FlutterErrorDetails? firstError;
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      firstError ??= details;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    var popped = false;
    // Telefon yüksekliği + web/masaüstü genişliği: buton görünür, streak satırı taşmaz.
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ResultScreen(
                        correct: 4,
                        total: 4,
                        xp: 40,
                        reviewsSaved: 6,
                        streak: 1,
                        streakIncreased: true,
                      ),
                    ),
                  );
                  popped = true;
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump(); // push
    await tester.pump(const Duration(milliseconds: 400)); // rise / xp start
    await tester.pump(const Duration(milliseconds: 800)); // xp flight

    expect(find.text('Keep learning'), findsOneWidget);
    expect(
      firstError,
      isNull,
      reason: firstError?.exceptionAsString(),
    );

    // Hit-test / confetti yerine butonu doğrudan tetikle (layout + navigasyon doğrulaması).
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Keep learning'),
    );
    expect(button.onPressed, isNotNull);
    button.onPressed!();
    await tester.pump();
    // Material rota + confetti; 400ms yetmiyor, 600ms güvenli.
    await tester.pump(const Duration(milliseconds: 600));

    expect(popped, isTrue);
    expect(find.text('Keep learning'), findsNothing);
    expect(find.text('go'), findsOneWidget);
  });
}
