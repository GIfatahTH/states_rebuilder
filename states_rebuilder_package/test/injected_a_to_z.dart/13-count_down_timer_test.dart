import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum TimerStatus { none, ready, running, paused }

final Injected<int> timer = RM.injectStream<int>(
  () => Stream.periodic(Duration(seconds: 1), (num) => num + 1),
  initialState: 0,
  // isLazy: false,
  onInitialized: (_, __) {
    timerStatus.state = TimerStatus.ready;
  },
  debugPrintWhenNotifiedPreMessage: 'timer',
);

final timerStatus = RM.inject<TimerStatus>(
  () => TimerStatus.none,
  onData: (timerStatus) {
    switch (timerStatus) {
      case TimerStatus.running:
        timer.subscription?.resume();
        break;
      case TimerStatus.ready:
      case TimerStatus.paused:
      default:
        if (timer.subscription?.isPaused == false) {
          //To avoid pausing more than once. (doc: If the subscription is paused more than once, an equal number of resumes must be performed to resume the stream.)
          timer.subscription?.pause();
        }
        break;
    }
  },
  debugPrintWhenNotifiedPreMessage: 'timerStatus',
);

// the initial timer value
final initialTimer = 60;

final duration = RM.inject<int>(
  () {
    int d = initialTimer - timer.state;
    if (d < 1) {
      //at the end of the countdown reset and stop the timer
      timer.refresh();
      timerStatus.state = TimerStatus.ready;
      return initialTimer;
    }
    return d;
  },
  dependsOn: DependsOn({timer}),
  initialState: initialTimer,
  debugPrintWhenNotifiedPreMessage: 'duration',
);

class TimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: On(
        () => Text('${duration.state}'),
      ).listenTo(duration),
    );
  }
}

void _pause() {
  timerStatus.state = TimerStatus.paused;
}

void _resume() {
  timerStatus.state = TimerStatus.running;
}

void _restart() {
  timerStatus.state = TimerStatus.paused;
  timer.refresh();
  timerStatus.state = TimerStatus.running;
}

void _reset() {
  timer.refresh();
  timerStatus.state = TimerStatus.ready;
}

void main() {
  testWidgets('initial build', (tester) async {
    await tester.pumpWidget(TimerApp());
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
    expect(timerStatus.state, TimerStatus.ready);
  });

  testWidgets('Start timer', (tester) async {
    await tester.pumpWidget(TimerApp());

    _resume();

    await tester.pump();

    expect(timerStatus.state, TimerStatus.running);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('59'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('58'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('57'), findsOneWidget);
  });

  testWidgets('Pause timer', (tester) async {
    await tester.pumpWidget(TimerApp());
    _resume();

    await tester.pump(Duration(seconds: 3));
    expect(find.text('57'), findsOneWidget);

    //
    _pause();
    await tester.pump();
    expect(timerStatus.state, TimerStatus.paused);

    await tester.pump(Duration(seconds: 3));
    expect(find.text('57'), findsOneWidget);
  });

  testWidgets('Pause and resume timer', (tester) async {
    await tester.pumpWidget(TimerApp());
    _resume();
    await tester.pump(Duration(seconds: 3));
    //
    _pause();
    await tester.pump();
    expect(timerStatus.state, TimerStatus.paused);
    expect(find.text('57'), findsOneWidget);

    //
    _resume();
    await tester.pump(Duration(seconds: 1));
    expect(find.text('56'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('55'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('54'), findsOneWidget);
  });

  testWidgets('Restart timer while running', (tester) async {
    await tester.pumpWidget(TimerApp());
    _resume();
    await tester.pump(Duration(seconds: 3));
    expect(find.text('57'), findsOneWidget);

    //
    _restart();
    await tester.pump();
    // await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('59'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('58'), findsOneWidget);
  });

  testWidgets('Reset timer while stopped', (tester) async {
    await tester.pumpWidget(TimerApp());
    _resume();
    await tester.pump(Duration(seconds: 3));
    expect(find.text('57'), findsOneWidget);
    _pause();
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    expect(find.text('57'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('57'), findsOneWidget);
    //
    _reset();
    await tester.pump();
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
  });

  testWidgets('Auto reset timer after done', (tester) async {
    await tester.pumpWidget(TimerApp());
    _resume();
    await tester.pump();
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('59'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('58'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 56));
    expect(find.text('2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('60'), findsOneWidget);
  });
}
