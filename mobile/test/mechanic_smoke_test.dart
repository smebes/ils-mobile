import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprachapp/models.dart';
import 'package:sprachapp/screens/exercise_widgets.dart';
import 'package:sprachapp/screens/flashcard_widget.dart';

import 'test_helpers.dart';

Exercise _quiz() => Exercise(
      id: 't_quiz',
      lektionId: 1,
      mechanic: Mechanic.quiz,
      grammarTopic: 'test',
      payload: {
        'instruction': 'Wähle die richtige Antwort.',
        'question': 'Wie heißt du?',
        'options': [
          {'id': 'a', 'text': 'Ich heiße Anna.'},
          {'id': 'b', 'text': 'Ich komme aus Berlin.'},
          {'id': 'c', 'text': 'Guten Tag!'},
        ],
      },
      solution: {
        'answer': 'a',
        'explanation': 'Name-Frage.',
      },
    );

Exercise _fillChip() => Exercise(
      id: 't_fill',
      lektionId: 1,
      mechanic: Mechanic.fillBlank,
      grammarTopic: 'test',
      payload: {
        'instruction': 'Ergänze.',
        'sentence': 'Ich ___ Anna.',
        'blanks': [
          {
            'id': 'b1',
            'options': ['heiße', 'komme', 'wohne'],
          },
        ],
      },
      solution: {
        'b1': {'answer': 'heiße', 'accept': []},
      },
    );

Exercise _listening() => Exercise(
      id: 't_listen',
      lektionId: 1,
      mechanic: Mechanic.listening,
      grammarTopic: 'test',
      payload: {
        'instruction': 'Höre und antworte.',
        'audio': {'normal': <String>[], 'slow': <String>[]},
        'lines': [
          {'text': 'Guten Tag'},
        ],
        'questions': [
          {
            'id': 'q1',
            'q': 'Was hörst du?',
            'options': [
              {'id': 'o1', 'text': 'Guten Tag'},
              {'id': 'o2', 'text': 'Tschüss'},
            ],
          },
        ],
      },
      solution: {'q1': 'o1'},
    );

Exercise _matching() => Exercise(
      id: 't_match',
      lektionId: 1,
      mechanic: Mechanic.matching,
      grammarTopic: 'test',
      payload: {
        'instruction': 'Ordne zu.',
        'left': [
          {'id': 'l1', 'text': 'Hallo'},
          {'id': 'l2', 'text': 'Tschüss'},
        ],
        'right': [
          {'id': 'r1', 'text': 'Hello'},
          {'id': 'r2', 'text': 'Bye'},
        ],
      },
      solution: {'l1': 'r1', 'l2': 'r2'},
    );

Widget _host(Widget child) => Scaffold(
      body: SafeArea(
        child: SizedBox.expand(child: child),
      ),
    );

void main() {
  testWidgets('S2 smoke: Quiz seç → Check → Continue', (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);
    var done = false;
    await tester.pumpWidget(
      testApp(
        home: _host(
          QuizWidget(
            exercise: _quiz(),
            onComplete: (_) => done = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Ich heiße Anna.'));
    await tester.pump();
    await tapCheckContinue(tester);

    expect(done, isTrue);
    probe.expectClean();
  });

  testWidgets('S2 smoke: Fill-blank chip → Check → Continue', (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);
    var done = false;
    await tester.pumpWidget(
      testApp(
        home: _host(
          FillBlankWidget(
            exercise: _fillChip(),
            onComplete: (_) => done = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('heiße'));
    await tester.pump();
    await tapCheckContinue(tester);

    expect(done, isTrue);
    probe.expectClean();
  });

  testWidgets('S2 smoke: Listening cevap → Check → Continue (ses yok)',
      (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);
    var done = false;
    await tester.pumpWidget(
      testApp(
        home: _host(
          ListeningWidget(
            exercise: _listening(),
            onComplete: (_) => done = true,
          ),
        ),
      ),
    );
    await tester.pump();

    // Ses çalmadan seç — donma regresyonu için kritik yol.
    await tester.tap(find.text('Guten Tag').last);
    await tester.pump();
    await tapCheckContinue(tester);

    expect(done, isTrue);
    probe.expectClean();
  });

  testWidgets('S2 smoke: Matching eşle → Check → Continue', (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);
    var done = false;
    await tester.pumpWidget(
      testApp(
        home: _host(
          MatchingWidget(
            exercise: _matching(),
            onComplete: (_) => done = true,
          ),
        ),
      ),
    );
    await tester.pump();

    // Sıra shuffle'dan bağımsız: sol → sağ çiftleri elle bağla.
    await tester.tap(find.text('Hallo'));
    await tester.pump();
    await tester.tap(find.text('Hello'));
    await tester.pump();
    await tester.tap(find.text('Tschüss'));
    await tester.pump();
    await tester.tap(find.text('Bye'));
    await tester.pump();

    final checkBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Check'),
    );
    expect(checkBtn.onPressed, isNotNull);
    await tapCheckContinue(tester);

    expect(done, isTrue);
    probe.expectClean();
  });

  testWidgets('S2 smoke: Flashcard Continue (eksik görsel soft placeholder)',
      (tester) async {
    final probe = ErrorProbe()..install();
    await prepareSurface(tester);
    var done = false;
    final vocab = VocabItem(
      wort: 'Hallo',
      uebersetzungTr: 'Merhaba',
      image: 'assets/vocab/missing_for_test_xyz.svg',
    );
    await tester.pumpWidget(
      testApp(
        home: _host(
          FlashcardWidget(
            vocab: vocab,
            onNext: () => done = true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    expect(find.byKey(const ValueKey('soft_media_error')), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(done, isTrue);
    probe.expectClean();
  });
}
