import 'package:countdown_timer/main_using_on_set_state_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('timer app', (tester) async {
    await tester.pumpWidget(MaterialApp(home: App()));
    //ready state
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    //tap on start btn
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    //running state
    expect(find.text('00:58'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);

    //tap on repeat btn
    await tester.tap(find.byIcon(Icons.repeat));
    await tester.pump();
    //running state
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('00:58'), findsOneWidget);

    //tap on pause btn
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    //pause state
    expect(find.text('00:58'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('00:58'), findsOneWidget);

    //tap on replay btn
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    //running state
    expect(find.text('00:58'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('00:56'), findsOneWidget);

    //tap on pause btn
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    //tap on stop btn
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();
    //ready state
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('01:00'), findsOneWidget);

    //tap on start btn
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('00:58'), findsOneWidget);

    await tester.pump(Duration(seconds: 55));
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));

    //running state
    expect(find.text('00:01'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    //ready state
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('01:00'), findsOneWidget);
  });
}
