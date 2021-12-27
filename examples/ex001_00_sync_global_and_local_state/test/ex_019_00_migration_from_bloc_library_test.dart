import 'package:ex001_00_sync_global_and_local_state/ex_019_00_migration_from_bloc_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test timer state',
    (tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('00:10'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsNothing);
      expect(find.byIcon(Icons.pause), findsNothing);
      // Start
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(find.text('00:10'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:09'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:08'), findsOneWidget);
      // Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(find.text('00:08'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:08'), findsOneWidget);
      // Play
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(find.text('00:08'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:07'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:02'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:01'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
      // Replay
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pump();
      expect(find.text('00:10'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsNothing);
      expect(find.byIcon(Icons.pause), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:10'), findsOneWidget);
      // Start
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      expect(find.text('00:10'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:09'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:08'), findsOneWidget);
      // Replay
      await tester.tap(find.byIcon(Icons.replay));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsNothing);
      expect(find.byIcon(Icons.pause), findsNothing);
      expect(find.text('00:10'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:10'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:10'), findsOneWidget);
    },
  );
}
