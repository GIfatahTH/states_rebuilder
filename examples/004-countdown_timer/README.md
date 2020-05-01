# countdown_timer

In this example, we will build a countdown timer.

![countDown timer](https://github.com/GIfatahTH/repo_images/blob/master/006-countdown_timer.gif).

The countdown timer has three status:
1. ready status: The initial time is displayed with a play button. 
2. running status: The time is ticking down each second with two buttons to pause and replay the timer.
3. paused status: The timer is paused with two buttons to resume and stop the timer


# Business logic part:

The first step is to define an enumeration to define that status of the timer:

```dart
enum TimerStatus { ready, running, paused }
```

# The user interface part:

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: Injector(
        //NOTE1: Injecting the TimerStatus.ready value
        inject: [Inject<TimerStatus>(() => TimerStatus.ready)],
        builder: (context) {
          return TimerView();
        },
      ),
    );
  }
}
```

As always, the first thing to think about is to inject your model in the widget tree [NOTE1], In our case we have a simple enum.

The injected value `TimerStatus.ready` will be consumed using `RM.get<TimerStatus>()`. And As you might have expected you get a `ReactiveModel<TimerStatus>` observable model that you can subscribe to it and mutate its state and notify observer widgets.

>>With states_rebuilder you can turn even primitive values to reactive observable model that widgets can subscribe to them.


```dart
class TimerView extends StatelessWidget {
  // the initial timer value
  final initialTimer = 60;

  @override
  Widget build(BuildContext context) {
    //NOTE1 : Getting the registered reactive singleton of the TimerStatus
    //NOTE1 : The context is defined so that it will be subscribed to the TimerStatus.
    final timerStatusRM = RM.get<TimerStatus>(context: context);
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
          initialValue: initialTimer,
        ),
      ],
      builder: (_) {
        //NOTE5 : Getting the registered reactive singleton of the stream using the 'int' type.
        final timerStream = RM.get<int>();
        return StateBuilder(
          // NOTE6 : Subscribe this StateBuilder to the timerStream reactive singleton
          observe : () => timerStream,
          //NOTE7 : defining the onSetState callback to be called when this StateBuilder is notified and before the trigger of the rebuilding process.
          onSetState: (_, __) {
            //NOTE8: Decrement the duration each time the stream emits a value
            duration = initialTimer - timerStream.snapshot.data - 1;
            //NOTE8 : Check if duration reaches zero and set the timerStatusRM to be equal to TimerStatus.ready
            if (duration <= 0) {
              //NOTE8: Mutating the state of TimerStatus using setState
              timerStatusRM.setValue(()=>TimerStatus.ready);
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
                      observe : () => timerStatusRM,
                      //NOTE11 : Give it a tag so that we can control its notification
                      tag: 'timer',
                      builder: (context, _) {
                        //NOTE12 : Display the ReadyStatus widget if the timerStatusRM is in the ready status
                        if (timerStatusRM.value == TimerStatus.ready) {
                          return ReadyStatus();
                        }
                        //NOTE13 : Display the RunningStatus widget if the timerStatusRM is in the running status
                        if (timerStatusRM.value == TimerStatus.running) {
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
```

First of all, we get the registered reactive singleton of the `TimerStatus` using `RM.get` method with the context defined. The widget of the defined context is subscribed to the `TimerStatus` [NOTE1].

The next step is to inject the stream using `Inject.stream` [NOTE4] and set its initial value. 

Noticed that we set the key parameter of the `Injector` widget used to inject the stream to be `UniqueKey()` [NOTE3]. This is a concept related to Flutter. 

`Injector` is a statefulWidget, this means that when it is first created its state life starts by calling its `initState` method, then the `build` method which is called each time the `State.setState` method is called or if any of its parent rebuilds. When `Injector` is removed from the widget tree, the `dispose` method is invoked. (There are some other intermediate life cycle methods not related to our case. For more information see this [article](https://flutterbyexample.com/stateful-widget-lifecycle/).

By setting the key parameter of the `Injector` to `UniqueKey()`, The `Injector` state will be disposed and created again if any of its parent widget rebuilds. This is useful for us because states_rebuilder creates the injected stream in the `ìntState` and close and dispose of it in the `dispose` method. 

In our case, when the registered reactive singleton of the `TimerStatus` triggers a notification without tags filter. the build method of `TimerView` will be called. At this stage, because we define the key to be unique, the injected stream is stopped and dispose, and a new stream is created and starts emitting a new set of values. (This is what will be used in the repay button).

Now that we have injected the stream using `Inject.stream`, we get the registered reactive singleton of the stream using `RM.get` method [NOTE5]. You use the type `int` to get the registered stream because it is injected with this type [NOTE4]. 

We have the option to inject the stream using a custom name, something like this :

```dart
Injector(
    key: UniqueKey(),
    inject: [
    Inject<int>.stream(
       () => Stream.periodic(Duration(seconds: 1), (num) => num),
        initialValue: initialTimer,
        name : 'customStreamName',
    ),
    ],
)
```

to get the reactive singleton :

```dart
final timerStream = RM.get<int>(name: 'customStreamName');
```

## Update (v. 1.14.3)
Using UniqueKey has an undesired side effect; Each time Flutter calls the build method,for any raison, the `Injector` will be disposed and inserted back to the widget.
In version 1.14.3 I added the `reinjectOn` parameter so that only if rebuild is issued from `timerStatusRM`, the stream is canceled and an new subscription will be established.

```dart
@override
  Widget build(BuildContext context) {
    final timerStatusRM = RM.get<TimerStatus>(context: context);
    int duration;
    return Injector(
      inject: [
        Inject<int>.stream(
          () => Stream.periodic(Duration(seconds: 1), (num) => num),
          initialValue: initialTimer,
        ),
      ],
      //reinjectOn takes a list of reactive models. If any of them emits a notification, the injected model will be disposed and re-injected.
      reinjectOn: [timerStatusRM],
      builder: (_) {
        //
        //
      }
```


After getting the reactive singleton of the stream we subscribe to it using `StateBuilder` [NOTE6].

The stream emits each second a series of integer numbers starting from 0 then 1, 2, 3, 4 ... and so on.

But we want the timer to start from an initial value and count down until it reaches zero. Something like this (60, 59, 58, ... until 0).

The appropriate place to do such a transformation is in the `onSetState` callback [NOTE7].

```dart
onSetState: (_, __) {
  //NOTE8: Decrement the duration each time the stream emits a value
  duration = initialTimer - timerStream.snapshot.data - 1;
  //NOTE8 : Check if duration reaches zero and set the timerStatusRM to be equal to TimerStatus.ready
  if (duration <= 0) {
    //NOTE8: Mutating the state of TimerStatus using setState
    
    timerStatusRM.setValue(()=>TimerStatus.ready);
  }
},
```

The `onSetState` callback is called each time the stream emits a value and before building the widget. After decrementing the duration we check if it reaches zero and set the `timerStatusRM.value` to be `TimerStatus.ready` and send a notification to all subscribe widget. In our case, The `TimerView` widget is subscribed to the `TimerStatus` so it will be notified to rebuild. At this stage, because we define the key to be unique, the injected stream is stopped and dispose, and a new stream is created and starts emitting a new set of values [NOTE3, NOTE4].

the `duration` value is passed to the `TimerDigit` widget to display a formated value (minutes : seconds) : [NOTE9]

```dart
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
To display the control buttons, we wrap them in `StateBuilder` that subscribe to `timerStatusRM` reactive singleton with a tag of 'timer': [NOTE10 , NOTE11].

The reactive singleton `timerStatusRM` has two Widgets subscribed to it:
* `TimerView` subscribed using the `BuildContext` [NOTE1];
* `StateBuilder` subscribed with a tag [NOTE10].

Whenever `timerStatusRM` sends notification without tag both widgets will rebuild. And as discussed above, the `Injector` of the stream has a unique key [NOTE3] so the stream is closed and a new stream is created. We used this in [NOTE8] when the timer reaches zero. (Another use is in the replay action)

In contrast, when `timerStatusRM` sends a notification with 'timer' tag only the StateBuilder subscribed with this tag will rebuild and the stream is not closed. (Used in the pause and resume actions).

The last thing is to display corresponding buttons for each `TimerStatus` :

1. **Ready status** : In [NOTE12] we check if the `TimerStatus` is ready and display the `ReadyStatus` widget.

`ReadyStatus` looks like this :

```dart
class ReadyStatus extends StatelessWidget {
  // stopping the stream using the `subscription` getter of `timerStream` reactive singleton.
  final ReactiveModel<int> timerStream = RM.get<int>()
    ..subscription.pause();
  final timerStatusRM = RM.get<TimerStatus>();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.play_arrow),
      heroTag: UniqueKey().toString(),
      onPressed: () {
        timerStatusRM.setValue(
          ()=> TimerStatus.running,
          filterTags: ['timer'],
          onSetState: (context) {
            timerStream.subscription.resume();
          },
        );
      },
    );
  }
}
```

It a `FloatingActionButton` with play arrow icon. When the FAB is pressed, we set `timerStatusRM` to `TimerStatus.running` and notify listener with 'timer' tag. In `onSetState` callback we resume the stream.

2.  **Running status** :  In [NOTE13] we check if the `timerStatusRM` is running and display the `RunningStatus` widget: 

```dart
class RunningStatus extends StatelessWidget {
  final ReactiveModel<int> timerStream = RM.get<int>();
  final timerStatusRM = RM.get<TimerStatus>();

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
              ()=> TimerStatus.paused,
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
            //paused and rerun the timer.
            timerStatusRM.setValue(()=>TimerStatus.paused);
            timerStatusRM.setValue(()=>TimerStatus.running);
          },
        ),
      ],
    );
  }
}
```

It consists of two FAB, one for pause and the other for repeat (replay) : 
* If the pause FAB is pressed, we set `timerStatusRM` to `TimerStatus.paused` and notify listener with 'timer' tag. In `onSetState` callback we pause the stream.
* If the repeat FAB is pressed, we set `timerStatusRM` to `TimerStatus.running` and notify listeners without tag so that the stream is closed and a brand new stream is created.

3. **Paused status** :  In [NOTE14] the `timerStatusRM` is `TimerStatus.paused` because it is not ready nor running, so we will display the `PausedStatus` widget: 

```dart
class PausedStatus extends StatelessWidget {
  final ReactiveModel<int> timerStream = RM.get<int>();
  final timerStatusRM = RM.get<TimerStatus>();

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
              ()=> TimerStatus.running,
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
            timerStatusRM.setValue(()=>TimerStatus.ready);
          },
        ),
      ],
    );
  }
}
```

It consists of two FAB, one for resume and the other for stop : 
* If the pause FAB is resume, we set `timerStatusRM` to `TimerStatus.running` and notify listener with 'timer' tag. In `onSetState` callback we resume the stream.
* If the stop FAB is pressed, we set `timerStatusRM` to `TimerStatus.ready` and notify listeners without tag so that the stream is closed and a brand new stream is created.

# Using `OnSetStateListener`

The approach we have followed, we use `onSetState` callback to execute side effect locally. By locally I mean that each `setValue` handles its own `onSetState`.

We can handle side effects globally using `OnSetStateListener`.

Let's refactor our timer to use `OnSetStateListener`.

```dart
// this remains unchanged
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: Injector(
        inject: [Inject(() => TimerStatus.ready)],
        builder: (context) => TimerView(),
      ),
    );
  }
}
```

```dart
class TimerView extends StatelessWidget {
  // the initial timer value
  final int initialTimer = 10;

  @override
  Widget build(BuildContext context) {
    //NOTE1 : Getting the registered reactive singleton of the TimerStatus
    //NOTE1 : The context is defined so that it will be subscribed to the TimerStatus.
    final timerStatusRM = RM.get<TimerStatus>(context: context);
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
          initialValue: initialTimer,
        ),
      ],
      builder: (_) {
        //NOTE5 : Getting the registered reactive singleton of the stream using the 'int' type.
        final timerStream = RM.get<int>();
        //Here we add OnSetSTateListener to mange globally side effects
        return OnSetStateListener(
          observeMany: [ ()=> timerStatusRM,()=> timerStream],
          tag: 'timer',
          //set to true to execute onSetState in the initState
          shouldOnInitState: true,
          onSetState: (_, model) {
            if (model.value is TimerStatus) {
              print(timerStatusRM.value);
              switch (timerStatusRM.value) {
                case TimerStatus.ready:
                  timerStream.subscription.pause();
                  break;
                case TimerStatus.running:
                  timerStream.subscription.resume();
                  break;
                case TimerStatus.paused:
                  timerStream.subscription.pause();
                  break;
                default:
              }
            }
            if (model.value is int) {
              print(model.value);
              //NOTE8: Decrement the duration each time the stream emits a value
              duration = initialTimer - timerStream.snapshot.data - 1;

              //NOTE8 : Check if duration reaches zero and set the timerStatusRM to be equal to TimerStatus.ready
              if (duration <= 0) {
                //NOTE8: Mutating the state of TimerStatus using value setter
                timerStatusRM.value = TimerStatus.ready;
              }
            }
          },
          child: Center(
            child: Row(
              children: <Widget>[
                Expanded(
                  //NOTE9: Widget to display a formatted string of the duration.
                  child: StateBuilder(
                      observe : () => timerStream,
                      builder: (_, __) {
                        return TimerDigit(
                          duration ?? initialTimer,
                        );
                      }),
                ),
                Expanded(
                  //NOTE10 : define another StateBuilder
                  child: StateBuilder(
                    //NOTE10: subscribe this StateBuilder to the timerStatusRM
                    observe : () =>  timerStatusRM,
                    //NOTE11 : Give it a tag so that we can control its notification
                    tag: 'timer',
                    builder: (context, _) {
                      //NOTE12 : Display the ReadyStatus widget if the timerStatusRM is in the ready status
                      if (timerStatusRM.value == TimerStatus.ready) {
                        return ReadyStatus();
                      }
                      //NOTE13 : Display the RunningStatus widget if the timerStatusRM is in the running status
                      if (timerStatusRM.value == TimerStatus.running) {
                        return RunningStatus();
                      }
                      //NOTE14 : Display the PausedStatus widget if the timerStatusRM is in the paused status
                      return PausedStatus();
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
```

Let's extract the code that we are interested in:
```dart
return OnSetStateListener(
  observeMany: [()=> timerStatusRM,()=> timerStream],
  tag: 'timer',
  shouldOnInitState: true,
  onSetState: (_, model) {
    //model holds the instance of the reactive model that is emitting the notification
    if (model.value is TimerStatus) {
      switch (timerStatusRM.value) {
        case TimerStatus.ready:
          timerStream.subscription.pause();
          break;
        case TimerStatus.running:
          timerStream.subscription.resume();
          break;
        case TimerStatus.paused:
          timerStream.subscription.pause();
          break;
        default:
      }
    }
    if (model.value is int) {
      duration = initialTimer - timerStream.snapshot.data - 1;
      if (duration <= 0) {
        timerStatusRM.value =  TimerStatus.ready;
      }
    }
  },
  child: Center(
    // the remainder of the code.
  } 

```

`OnSetStateListener` is registered to two reactive models `timerStatusRM`, `timerStream`. the `onSetState` callback will be invoked each time any of the reactive models emits a notification. 

Because notification is filtered by tag, we set `OnSetStateListener` to listen to notification emitted with 'timer' tag.

By default `onSetState`, `onWaiting`, `onError`, and `onData` are fired only if any of the `timerStatusRM` and `timerStream` emits a notification. They are not fired in the `initState`. The optional bool parameter `shouldOnInitState` when set to true the above callback will be invoked in the `initState` hook of the `StatefulWidget`.

Because `OnSetStateListener` is used with dynamic tag, the exposed model will be dynamic (see [Login form validation](examples/002-form_validation_with_reactive_model)).

Then we check for the exposed model, if it is `TimerStatus` we will switch for its status and pause or resume the stream subscription accordingly.

If the expose model is `int` (that means the stream), we updated the `duration` variable and switch the `TimerStatus` status to ready if `duration` is zero.

The remainder of the code is the same as the first case, except `onSetState` callback are removed from `setValue` methods.

# test

See the test main_test.dart in test folder.
