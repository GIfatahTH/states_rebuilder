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
  final initialTimer;
  CountDownTimer(this.initialTimer);

  //inject a stream to represent our timer.
  final Injected<int> _timer = RM.injectStream<int>(
    () => Stream.periodic(Duration(seconds: 1), (num) => num + 1),
    initialState: 0,
    onInitialized: (_, subscription) {
      //As stream automatically starts emitting on creation, we have to stop it
      subscription.pause();
      //reset the timerStatus back to ready.
      // timerStatus.state = TimerStatus.ready;

      //this onInitialized will be called again we we call 'timer.refresh().
    },
  );

  //Inject the timer status
  Injected<TimerStatus>? _timerStatus;
  Injected<TimerStatus> get timerStatus =>
      _timerStatus ??= RM.inject<TimerStatus>(
        () => TimerStatus.ready,
        onData: (timerStatus) {
          //Each time the timerStatus state is mutate with success, we switch
          switch (timerStatus) {
            case TimerStatus.running:
              //if the new state is running, we resume the stream subscription
              _timer.subscription?.resume();
              break;
            case TimerStatus.ready:
            case TimerStatus.paused:
            //for both ready and paused we pause the subscription
            default:
              if (_timer.subscription?.isPaused == false) {
                //To avoid pausing more than once. (doc: If the subscription is paused more than once, an equal number of resumes must be performed to resume the stream.)
                _timer.subscription?.pause();
              }
              break;
          }
        },
      );

  //timer stream emits data from 0,1,2 and so one without stopping.
  //Here we compute the duration 60,59,58, ... and stop at 0.
  Injected<int>? _duration;
  Injected<int> get duration => _duration ??= RM.inject<int>(
        () {
          int d = initialTimer - _timer.state;
          if (d < 1) {
            //When duration is 0, refresh the time.
            //refresh the timer means:
            //- cancel the current subscription
            //- create brand new subscription
            //- recall onInitialized (see above) with pause the subscription and
            //set timerStatus to ready.
            stop();
            return initialTimer;
          }
          return d;
        },
        //as we want to refresh the timer when duration is 0, and await until
        //the stream is canceled and new stream is created, we use asyncDependsOn
        dependsOn: DependsOn({_timer}),
        initialState: initialTimer,
        // debugPrintWhenNotifiedPreMessage: 'duration',
      );
  void start() {
    timerStatus.state = TimerStatus.running;
  }

  void restart() {
    _timer.refresh();
  }

  void pause() {
    timerStatus.state = TimerStatus.paused;
  }

  void stop() {
    //call refresh, will cancel the current subscription and create
    //a new one and stop at ready state
    _timer.refresh();
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
