import 'package:flutter/material.dart';
import 'theme.dart';
import 'content_repository.dart';
import 'progress_store.dart';
import 'screens/home_screen.dart';

final contentRepo = ContentRepository();
final progressStore = ProgressStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await progressStore.init();
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
