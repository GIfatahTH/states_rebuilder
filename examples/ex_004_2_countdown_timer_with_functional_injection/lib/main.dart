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

//inject a stream to represent our timer.
final Injected<int> timer = RM.injectStream<int>(
  () => Stream.periodic(Duration(seconds: 1), (num) => num + 1),
  initialValue: 0,
  onInitialized: (_) {
    //As stream automatically starts emitting on creation, we have to stop it
    timer.subscription.pause();
    //reset the timerStatus back to ready.
    timerStatus.state = TimerStatus.ready;

    //this onInitialized will be called again we we call 'timer.refresh().
  },
);

//Inject the timer status
final timerStatus = RM.inject<TimerStatus>(
  () => TimerStatus.ready,
  onData: (timerStatus) {
    //Each time the timerStatus state is mutate with success, we switch
    switch (timerStatus) {
      case TimerStatus.running:
        //if the new state is running, we resume the stream subscription
        timer.subscription.resume();
        break;
      case TimerStatus.ready:
      case TimerStatus.paused:
      //for both ready and paused we pause the subscription
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

//timer stream emits data from 0,1,2 and so one without stopping.
//Here we compute the duration 60,59,58, ... and stop at 0.
final duration = RM.injectComputed<int>(
  //as we want to refresh the timer when duration is 0, and await until
  //the stream is canceled and new stream is created, we use asyncDependsOn
  asyncDependsOn: [timer],
  computeAsync: (_) async* {
    int d = initialTimer - timer.state;
    if (d < 1) {
      //When duration is 0, refresh the time.
      //refresh the timer means:
      //- cancel the current subscription
      //- create brand new subscription
      //- recall onInitialized (see above) with pause the subscription and
      //set timerStatus to ready.
      await timer.refresh();
    }
    //yield the duration
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
            //subscription to duration, each time a new duration is yield,
            //this rebuilder will rebuild.
            child: duration.rebuilder(
              () => TimerDigit(
                duration.state ?? initialTimer,
              ),
            ),
          ),
          Expanded(
            //subscription to timerStatus
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
            //From this pausedStatus, we can run the time again
            timerStatus.state = TimerStatus.running;
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.stop),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            //from the paused status,We can also, stop the timer.
            //
            //call refresh, will cancel the current subscription and create
            //a new one and stop at ready state
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
            //From running state, we can pause the timer
            timerStatus.state = TimerStatus.paused;
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.repeat),
          heroTag: UniqueKey().toString(),
          onPressed: () async {
            //From running state, we can restart the timer
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
