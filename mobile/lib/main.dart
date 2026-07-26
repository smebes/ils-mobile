import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';
import 'content_repository.dart';
import 'progress_store.dart';
import 'screens/home_screen.dart';
import 'widgets.dart';

final contentRepo = ContentRepository();
final progressStore = ProgressStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  ErrorWidget.builder = (details) {
    debugPrint('ErrorWidget: ${details.exceptionAsString()}');
    // Kırık ikon flaşı yok — SoftMediaPlaceholder ile aynı dil.
    return const SoftMediaPlaceholder(height: 72, width: 72);
  };
  try {
    await progressStore.init();
  } catch (e) {
    debugPrint('ProgressStore init failed: $e');
  }
  runApp(const SprachApp());
}

class SprachApp extends StatelessWidget {
  const SprachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progressStore,
      builder: (context, _) {
        return MaterialApp(
          title: 'SprachApp',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: progressStore.uiLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeScreen(),
        );
      },
    );
  }
}
