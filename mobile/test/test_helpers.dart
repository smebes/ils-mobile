import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprachapp/l10n/app_localizations.dart';
import 'package:sprachapp/theme.dart';

/// Ortak test sarmalayıcı: tema + EN l10n.
Widget testApp({required Widget home, Size surface = const Size(800, 900)}) {
  return MaterialApp(
    theme: buildTheme(),
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Future<void> prepareSurface(WidgetTester tester,
    {Size size = const Size(800, 900)}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Layout / FlutterError yakalayıcı — donma regresyonu için.
class ErrorProbe {
  FlutterErrorDetails? first;
  void install() {
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      first ??= details;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);
  }

  void expectClean() {
    expect(first, isNull, reason: first?.exceptionAsString());
  }
}

/// Check → Continue akışını kısa pump ile (sürekli animasyon yok say).
Future<void> tapCheckContinue(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Check'));
  await tester.pump();
  await tester.tap(find.text('Check'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  expect(find.text('Continue'), findsOneWidget);
  await tester.ensureVisible(find.text('Continue'));
  await tester.pump();
  await tester.tap(find.text('Continue'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}
