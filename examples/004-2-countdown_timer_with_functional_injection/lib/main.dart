import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MaterialApp(home: App()));

enum TimerStatus { ready, running, paused }

final Injected<int> timer = RM.injectStream<int>(
  () => Stream.periodic(Duration(seconds: 1), (num) => num + 1),
  initialValue: 0,
  onInitialized: (_) {
    timer.subscription.pause();
    timerStatus.state = TimerStatus.ready;
  },
);

final timerStatus = RM.inject<TimerStatus>(
  () => TimerStatus.ready,
  onData: (timerStatus) {
    switch (timerStatus) {
      case TimerStatus.running:
        timer.subscription.resume();
        break;
      case TimerStatus.ready:
      case TimerStatus.paused:
      default:
        if (!timer.subscription.isPaused) {
          //To avoid pausing more than once. (doc: If the subscription is paused more than once, an equal number of resumes must be performed to resume the stream.)
          timer.subscription.pause();
        }
        break;
    }
  },
);

// the initial timer value
final initialTimer = 60;

final duration = RM.injectComputed<int>(
  asyncDependsOn: [timer],
  computeAsync: (_) async* {
    int d = initialTimer - timer.state;
    if (d < 1) {
      await timer.refresh();
    }
    yield d;
  },
  initialState: initialTimer,
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: duration.rebuilder(
              () => TimerDigit(
                duration.state ?? initialTimer,
              ),
            ),
          ),
          Expanded(
            child: timerStatus.rebuilder(
              () {
                if (timerStatus.state == TimerStatus.ready) {
                  return ReadyStatus();
                }
                if (timerStatus.state == TimerStatus.running) {
                  return RunningStatus();
                }
                return PausedStatus();
              },
            ),
          )
        ],
      ),
    );
  }
}

class PausedStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatus.state = TimerStatus.running;
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.stop),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            timer.refresh();
          },
        ),
      ],
    );
  }
}

class RunningStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.pause),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatus.state = TimerStatus.paused;
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.repeat),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            timer.refresh();
            timerStatus.state = TimerStatus.running;
          },
        ),
      ],
    );
  }
}

class ReadyStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.play_arrow),
      heroTag: UniqueKey().toString(),
      onPressed: () {
        timerStatus.state = TimerStatus.running;
      },
    );
  }
}

class TimerDigit extends StatelessWidget {
  final int duration;
  TimerDigit(this.duration);
  String get minutesStr =>
      ((duration / 60) % 60).floor().toString().padLeft(2, '0');
  String get secondsStr => (duration % 60).floor().toString().padLeft(2, '0');
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Center(
        child: Text(
          '$minutesStr:$secondsStr',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
