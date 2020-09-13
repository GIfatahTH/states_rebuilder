# countdown_timer

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.

In this example, we will build a countdown timer.

![countDown timer](https://github.com/GIfatahTH/repo_images/blob/master/006-countdown_timer.gif).

The countdown timer has three status:
1. ready status: The initial time is displayed with a play button. 
2. running status: The time is ticking down each second with two buttons to pause and replay the timer.
3. paused status: The timer is paused with two buttons to resume and stop the timer



The first step is to define an enumeration to define that status of the timer:

```dart
enum TimerStatus {
  //timer in stopped in initial state
  ready,
  //timer is ticking
  running,
  //timer is paused
  paused,
}
```

## injection

```dart
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
```
# The user interface part:

```dart
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
```
## Test

```dart
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
```