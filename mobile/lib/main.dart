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
  // Kompakt tut — eski tam ekran ErrorWidget tıklamaları yutuyordu.
  ErrorWidget.builder = (details) {
    debugPrint('ErrorWidget: ${details.exceptionAsString()}');
    return const SizedBox(
      height: 72,
      width: 72,
      child: ColoredBox(
        color: Color(0xFFFAF3E7),
        child: Icon(Icons.broken_image_outlined, color: Color(0xFF264653)),
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
