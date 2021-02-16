import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MaterialApp(home: App()));

enum TimerStatus {
  //timer in stopped in initial state
  ready,
  //timer is ticking
  running,
  //timer is paused
  paused,
}

class CountDownTimer {
  // the initial timer value
  final int initialTimer;
  CountDownTimer(this.initialTimer);
  //inject a stream to represent our timer.
  Injected<int>? _duration;
  Injected<int> get duration => _duration ??= RM.injectStream<int>(
        () => Stream.periodic(Duration(seconds: 1), (num) => num),
        middleSnapState: (middleState) {
          ////UnComment to see state transition print log
          // middleState.print();

          if (middleState.nextSnap.isWaiting) {
            //stream is waiting means that is is firs start.
            //we pause it and display the initial timer
            duration.subscription?.pause();
            return middleState.nextSnap.copyToHasData(initialTimer);
          }
          final timer = middleState.nextSnap.data!;
          int d = initialTimer - timer - 1;

          if (d < 1) {
            //When duration is 0, refresh the time.
            //refresh the timer means:
            //- cancel the current subscription
            //- create brand new subscription
            //- recall onInitialized (see above) which pauses the subscription
            stop();
            return middleState.nextSnap.copyToHasData(initialTimer);
          }
          return middleState.nextSnap.copyToHasData(d);
        },
      );

  //Inject the timer status
  Injected<TimerStatus>? _timerStatus;
  Injected<TimerStatus> get timerStatus =>
      _timerStatus ??= RM.inject<TimerStatus>(
        () => TimerStatus.ready,
        middleSnapState: (snap) {
          ////UnComment to see state transition print log
          // snap.print();
        },
      );

  void start() {
    timerStatus.state = TimerStatus.running;
    duration.subscription?.resume();
  }

  void restart() {
    duration.refresh();
    start();
  }

  void pause() {
    timerStatus.state = TimerStatus.paused;
    duration.subscription?.pause();
  }

  void stop() {
    //call refresh, will cancel the current subscription and create
    //a new one and stop at ready state
    duration.refresh();
    timerStatus.state = TimerStatus.ready;
  }
}

final timer = CountDownTimer(60);

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
            //subscription to duration, each time a new duration is yield,
            //this rebuilder will rebuild.
            child: On(
              () => TimerDigit(
                timer.duration.state,
              ),
            ).listenTo(timer.duration),
          ),
          Expanded(
            //subscription to timerStatus
            child: timer.timerStatus.rebuilder(
              () {
                if (timer.timerStatus.state == TimerStatus.ready) {
                  return ReadyStatus();
                }
                if (timer.timerStatus.state == TimerStatus.running) {
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
            //From this pausedStatus, we can run the time again
            timer.start();
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.stop),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            //from the paused status,We can also, stop the timer.
            timer.stop();
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
            //From running state, we can pause the timer
            timer.pause();
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.repeat),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            //From running state, we can restart the timer
            timer.restart();
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
      onPressed: () => timer.start(),
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
