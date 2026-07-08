import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprachapp/theme.dart';

void main() {
  test('artikel renk kodu doğru', () {
    expect(AppColors.artikel('der'), AppColors.der);
    expect(AppColors.artikel('die'), AppColors.die);
    expect(AppColors.artikel('das'), AppColors.das);
    expect(AppColors.artikel(null), AppColors.navy);
  });

  testWidgets('tema kurulur', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      home: const Scaffold(body: Text('SprachApp')),
    ));
    expect(find.text('SprachApp'), findsOneWidget);
  });
}
