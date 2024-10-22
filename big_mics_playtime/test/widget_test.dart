// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:big_mics_playtime/main.dart';
import 'package:big_mics_playtime/objects/game_state.dart';

void main() {
  // Test for switching pages and that nav bar works
  testWidgets('Navigation bar switches pages', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Start on Play page
    expect(find.text('Make noise to jump.'), findsOneWidget);
    expect(find.text('Test microphone.'), findsNothing);

    // Tap the Test icon in the nav bar
    await tester.tap(find.byIcon(Icons.mic));
    await tester.pump();

    // Verify that we navigated to the Mic Test page
    expect(find.text('Make noise to jump.'), findsNothing);
    expect(find.text('Test microphone.'), findsOneWidget);

    // Tap the Play icon in the nav bar
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Verify that we navigated back to the Play page
    expect(find.text('Make noise to jump.'), findsOneWidget);
    expect(find.text('Test microphone.'), findsNothing);
  });

  late GameState gameState; // for below test

  setUp(() { // for below test
    gameState = GameState(20, 20);
  });

  testWidgets('Score increases when BigMic clears an obstacle', 
  (WidgetTester tester) async {
    // Initial score should be -1 (game not started)
    // Score will appear as 0 to the user
    expect(gameState.getScore(), -1);
    
    // Simulate BigMic jumping over obstacle
    gameState.jump(5.0);
    
    // Move obstacle past BigMic position
    for (int i = 0; i < 30; i++) {
      gameState.moveObstacles();
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Score should have increased to 1
    expect(gameState.getScore(), 1);

    // Reset game state
    gameState.resetGame();
    expect(gameState.getScore(), -1);
  });

}
