import 'package:flutter/material.dart';
import 'theme.dart';
import 'content_repository.dart';
import 'progress_store.dart';
import 'screens/home_screen.dart';

final contentRepo = ContentRepository();
final progressStore = ProgressStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  ErrorWidget.builder = (details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'UI-Fehler:\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
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
    return MaterialApp(
      title: 'SprachApp',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
