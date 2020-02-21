import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MaterialApp(home: App()));

enum TimerStatus { ready, running, paused }

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: Injector(
        //NOTE1: Injecting the TimerStatus.ready value
        inject: [Inject(() => TimerStatus.ready)],
        builder: (context) {
          return TimerView();
        },
      ),
    );
  }
}

class TimerView extends StatelessWidget {
  // the initial timer value
  final initialTimer = 60;

  @override
  Widget build(BuildContext context) {
    //NOTE1 : Getting the registered reactive singleton of the TimerStatus
    //NOTE1 : The context is defined so that it will be subscribed to the TimerStatus.
    final timerStatusRM = Injector.getAsReactive<TimerStatus>(context: context);
    //NOTE2: Local variable to hold the current timer value.
    int duration;
    return Injector(
      //NOTE3 : Defining the a unique key of the widget.
      key: UniqueKey(),
      inject: [
        //NOTE4: Injecting the stream
        Inject<int>.stream(
          () => Stream.periodic(Duration(seconds: 1), (num) => num),
          //NOTE4 : Defining the initialValue of the stream
          initialValue: 0,
        ),
      ],
      builder: (_) {
        //NOTE5 : Getting the registered reactive singleton of the stream using the 'int' type.
        final timerStream = Injector.getAsReactive<int>();
        return StateBuilder(
          // NOTE6 : Subscribe this StateBuilder to the timerStream reactive singleton
          models: [timerStream],
          //NOTE7 : defining the onSetState callback to be called when this StateBuilder is notified and before the trigger of the rebuilding process.
          onSetState: (_, __) {
            //NOTE8: Decrement the duration each time the stream emits a value
            duration = initialTimer - timerStream.snapshot.data - 1;
            //NOTE8 : Check if duration reaches zero and set the timerStatusRM to be equal to TimerStatus.ready
            if (duration <= 0) {
              //NOTE8: Mutating the state of TimerStatus using setState
              timerStatusRM.setValue(() => TimerStatus.ready);
            }
          },
          builder: (_, __) {
            return Center(
              child: Row(
                children: <Widget>[
                  Expanded(
                    //NOTE9: Widget to display a formatted string of the duration.
                    child: TimerDigit(
                      duration ?? initialTimer,
                    ),
                  ),
                  Expanded(
                    //NOTE10 : define another StateBuilder
                    child: StateBuilder(
                      //NOTE10: subscribe this StateBuilder to the timerStatusRM
                      models: [timerStatusRM],
                      //NOTE11 : Give it a tag so that we can control its notification
                      tag: 'timer',
                      builder: (context, _) {
                        //NOTE12 : Display the ReadyStatus widget if the timerStatusRM is in the ready status
                        if (timerStatusRM.state == TimerStatus.ready) {
                          return ReadyStatus();
                        }
                        //NOTE13 : Display the RunningStatus widget if the timerStatusRM is in the running status
                        if (timerStatusRM.state == TimerStatus.running) {
                          return RunningStatus();
                        }
                        //NOTE14 : Display the PausedStatus widget if the timerStatusRM is in the paused status
                        return PausedStatus();
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PausedStatus extends StatelessWidget {
  final ReactiveModel<int> timerStream = Injector.getAsReactive<int>();
  final timerStatusRM = Injector.getAsReactive<TimerStatus>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatusRM.setValue(
              () => TimerStatus.running,
              filterTags: ['timer'],
              onSetState: (context) {
                timerStream.subscription.resume();
              },
            );
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.stop),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatusRM.setValue(() => TimerStatus.ready);
          },
        ),
      ],
    );
  }
}

class RunningStatus extends StatelessWidget {
  final ReactiveModel<int> timerStream = Injector.getAsReactive<int>();
  final timerStatusRM = Injector.getAsReactive<TimerStatus>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.pause),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatusRM.setValue(
              () => TimerStatus.paused,
              filterTags: ['timer'],
              onSetState: (context) {
                timerStream.subscription.pause();
              },
            );
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.repeat),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerStatusRM.setValue(() => TimerStatus.paused);
            timerStatusRM.setValue(() => TimerStatus.running);
          },
        ),
      ],
    );
  }
}

class ReadyStatus extends StatelessWidget {
  final ReactiveModel<int> timerStream = Injector.getAsReactive<int>()
    ..subscription.pause();
  final timerStatusRM = Injector.getAsReactive<TimerStatus>();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.play_arrow),
      heroTag: UniqueKey().toString(),
      onPressed: () {
        timerStatusRM.setValue(
          () => TimerStatus.running,
          filterTags: ['timer'],
          onSetState: (context) {
            timerStream.subscription.resume();
          },
        );
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
