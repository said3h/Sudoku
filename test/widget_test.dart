import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('Home screen loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.text('SUDOKU'), findsOneWidget);
    expect(find.text('PREMIUM'), findsOneWidget);
    expect(find.text('Nueva Partida'), findsOneWidget);
  });
}
