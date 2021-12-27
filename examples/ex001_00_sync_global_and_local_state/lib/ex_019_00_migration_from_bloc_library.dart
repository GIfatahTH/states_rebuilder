import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// This is an example of event driven design (BloC library way)
// See the original implementation using bloc library
// https://github.com/felangel/bloc/tree/master/examples/flutter_timer
//
// state classes in Bloc library => Named constructor here
// events in Bloc library => methods here

class Ticker {
  const Ticker();

  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}

enum TimerStatus { none, isInitial, isPaused, isRunning, isCompleted }

@immutable
class TimerState {
  final int duration;
  final TimerStatus timerStatus;
  bool get isInitial => timerStatus == TimerStatus.isInitial;
  bool get isPaused => timerStatus == TimerStatus.isPaused;
  bool get isRunning => timerStatus == TimerStatus.isRunning;
  bool get isCompleted => timerStatus == TimerStatus.isCompleted;
  // Helper method that will be used in the UI to make sure we will not forget
  // any state status
  Widget when({
    required Widget Function(int duration) initial,
    required Widget Function(int duration) paused,
    required Widget Function(int duration) running,
    required Widget Function() completed,
  }) {
    if (isInitial) {
      return initial(duration);
    }
    if (isPaused) {
      return paused(duration);
    }
    if (isRunning) {
      return running(duration);
    }
    return completed();
  }

  const TimerState._({
    this.duration = 0,
    this.timerStatus = TimerStatus.none,
  });

  // Equivalent to TimerInitial class in bloc library
  factory TimerState.initial(int duration) => TimerState._(
        timerStatus: TimerStatus.isInitial,
        duration: duration,
      );
  // Equivalent to TimerRunPause class in bloc library
  factory TimerState.paused(int duration) => TimerState._(
        timerStatus: TimerStatus.isPaused,
        duration: duration,
      );
  // Equivalent to TimerRunInProgress class in bloc library
  factory TimerState.running(int duration) => TimerState._(
        timerStatus: TimerStatus.isRunning,
        duration: duration,
      );
  // Equivalent to TimerRunComplete class in bloc library
  factory TimerState.completed() => const TimerState._(
        timerStatus: TimerStatus.isCompleted,
      );
}

class TimerBloc {
  final Ticker _ticker;
  static const int _initialDuration = 10;
  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker}) : _ticker = ticker;

  // Equivalent to the TimerStat in TimerBloc<TimerEvent, TimerStat> in bloc library
  late final _timerStateRM = RM.inject<TimerState>(
    () => TimerState.initial(_initialDuration),
    sideEffects: SideEffects(
      dispose: () => _tickerSubscription?.cancel(),
    ),
  );

  int get duration => _timerStateRM.state.duration;
  TimerState get timerState => _timerStateRM.state;
  // Events are methods
  // Equivalent to the TimerStarted event in bloc library
  void start() {
    _timerStateRM.state = TimerState.running(duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen(
          (duration) => _tick(duration),
        );
  }

  // Equivalent to the TimerPaused event in bloc library
  void pause() {
    if (_timerStateRM.state.isRunning) {
      _tickerSubscription?.pause();
      _timerStateRM.state = TimerState.paused(duration);
    }
  }

  // Equivalent to the TimerResumed event in bloc library
  void resume() {
    if (_timerStateRM.state.isPaused) {
      _tickerSubscription?.resume();
      _timerStateRM.state = TimerState.running(duration);
    }
  }

  // Equivalent to the TimerReset event in bloc library
  void reset() {
    _tickerSubscription?.cancel();
    _timerStateRM.state = TimerState.initial(_initialDuration);
  }

  // Equivalent to the TimerTicked event in bloc library
  void _tick(int duration) {
    if (duration > 0) {
      _timerStateRM.state = TimerState.running(duration);
    } else {
      _timerStateRM.state = TimerState.completed();
    }
  }
}

final timerBloc = TimerBloc(ticker: const Ticker());

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(109, 234, 255, 1),
        colorScheme: const ColorScheme.light(
          secondary: Color.fromRGBO(72, 74, 126, 1),
        ),
      ),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const TimerView();
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerText extends ReactiveStatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = timerBloc.duration;
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}

class Actions extends ReactiveStatelessWidget {
  const Actions({Key? key}) : super(key: key);

  @override
  bool shouldRebuildWidget(SnapState oldSnap, SnapState currentSnap) {
    final oldTimerState = oldSnap.state as TimerState;
    final currentTimerState = currentSnap.state as TimerState;
    return oldTimerState.timerStatus != currentTimerState.timerStatus;
  }

  @override
  Widget build(BuildContext context) {
    return timerBloc.timerState.when(
      initial: (_) => FloatingActionButton(
        child: const Icon(Icons.play_arrow),
        onPressed: timerBloc.start,
      ),
      paused: (_) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.play_arrow),
            onPressed: timerBloc.resume,
          ),
          FloatingActionButton(
            child: const Icon(Icons.replay),
            onPressed: timerBloc.reset,
          ),
        ],
      ),
      running: (_) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.pause),
            onPressed: timerBloc.pause,
          ),
          FloatingActionButton(
            child: const Icon(Icons.replay),
            onPressed: timerBloc.reset,
          ),
        ],
      ),
      completed: () => FloatingActionButton(
        child: const Icon(Icons.replay),
        onPressed: timerBloc.reset,
      ),
    );
    // final timerState = timerBloc.timerState;
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: [
    //     if (timerState.isInitial) ...[
    //       FloatingActionButton(
    //         child: const Icon(Icons.play_arrow),
    //         onPressed: timerBloc.start,
    //       ),
    //     ],
    //     if (timerState.isRunning) ...[
    //       FloatingActionButton(
    //         child: const Icon(Icons.pause),
    //         onPressed: timerBloc.pause,
    //       ),
    //       FloatingActionButton(
    //         child: const Icon(Icons.replay),
    //         onPressed: timerBloc.reset,
    //       ),
    //     ],
    //     if (timerState.isPaused) ...[
    //       FloatingActionButton(
    //         child: const Icon(Icons.play_arrow),
    //         onPressed: timerBloc.resume,
    //       ),
    //       FloatingActionButton(
    //         child: const Icon(Icons.replay),
    //         onPressed: timerBloc.reset,
    //       ),
    //     ],
    //     if (timerState.isCompleted) ...[
    //       FloatingActionButton(
    //         child: const Icon(Icons.replay),
    //         onPressed: timerBloc.reset,
    //       ),
    //     ]
    //   ],
    // );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
    );
  }
}
