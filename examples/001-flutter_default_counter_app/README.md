# flutter_default_counter_app

In this example, we will build the default counter app using states_rebuilder for managing the state.

This simple example aims to understand what ReactiveModel means and how it renders a pure dart object to reactive and how observers subscribe to it and how the observable reactive model notifies observers to rebuild.

# Simple counter.

> Update: With Functional injection, the life becomes easier (see further examples for more information). 

After adding the latest version of `states_rebuilder` to dependencies in the `pubspec.yaml`, in the  `main.dart` file we have
 
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

//The MyApp widget is the same as the default flutter counter
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

```dart
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  //creating a ReactiveModel key from the integer value of 0.
  final RMKey<int> counterRMKey = RMKey<int>(0);

  @override
  Widget build(BuildContext context) {789
  32+4
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StateBuilder<int>(
                //Create a local ReactiveModel and subscribing to it using StateBuilder
                observe: () => RM.create(0),
                //link this StateBuilder with key
                rmKey: counterRMKey,
                builder: (context, counterRM) {
                  //The builder exposes the BuildContext and the created instance of ReactiveModel
                  print('build : is building');
                  return Text(
                    //get the current state of the counter
                    '${counterRM.state}',
                    style: Theme.of(context).textTheme.headline5,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //counterRMKey is used to control the counter ReactiveModel from outside the widget where it is created
          //set the state of the counter and notify observer widgets to rebuild.
          counterRMKey.state++;
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```
In `states_rebuilder` world :
* There are local `ReactiveModel` and global `ReactiveModel`. This is an example of local `ReactiveModel`.
* In `states_rebuilder` you first, create a `ReactiveModel`, subscribe to it and let it emit notification to subscribed widgets

> Local ReactiveModel is simply a ReactiveModel where creation , subscription and notification are all done in one widget level in the widget tree.

## Creation and subscription:

`ReactiveModel` is created in the `observe` (or `observeMany`) parameter of one of the four observer widgets offered by states_rebuilder.
```dart
//StateBuilder is one of four observer widgets, (the others are WhenRebuilder, WhenRebuilderOR and OnSetStateListener)
StateBuilder<int>(
    //Create a local ReactiveModel and subscribing to it using StateBuilder
    observe: () => RM.create(0),
    //link this StateBuilder with key
    rmKey: counterRMKey,
    builder: (context, counterRM) {
      //The builder exposes the BuildContext and the created instance of ReactiveModel
      return Text(
        //get the current state of the counter from the exposed counter ReactiveModel.
        '${counterRM.state}',
        style: Theme.of(context).textTheme.headline5,
      );
  }),
```

* To set the state of the counter and notify listeners from inside the `builder` method of the `StateBuilder` widget, we use the exposed ReactiveModel in the `builder` parameter.

* To set the state of the counter and notify listeners from outside the `builder` method we use `ReactiveModel` key.

* In a similar fashion as used in Flutter, ReactiveModel keys are used to control a ReactiveModel from outside the widget wheres is created, ReactiveModel key inherited all the state and behavior of the ReactiveModel it is associated with.

> Before update 1.15.0 you can created local ReactiveModels outside the any observer, this no longer supported.


>with states_rebuilder one widget can subscribe to many ReactiveModel using the parameter `observeMany` so if any of them emits a notification, the builder callback is called again to update its content.


## notification:

To notify observer widgets (we have one; `StateBuilder` widget) we call use the `state` getter and setter.

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counterRM.state++;;
},
tooltip: 'Increment',
child: Icon(Icons.add),
),
```

If you want more options such executing side effects before rebuild or after it use setState.

```dart
onPressed: () {
    //set the state of the counter and notify observer widgets to rebuild.
    counterRM.setState(
    (int currentState) => currentState + 1,
    onSetState: (context) {
        print('onSetState : before rebuild');
    },
    onRebuildState: (context) {
        print('onRebuildState : after rebuild');
    },
  );
},
```
We added two optional parameters:
*  `onSetState` : a callback to be executed after `counterRM` emits a notification and before rebuilding observable widgets.

*  `onRebuildState` : a callback to be executed after `counterRM` emits a notification and after rebuilding observable widgets.

> Both `onSetState` and `onRebuildState` will be fired only if the rebuild is caused by `counterRM` notification.

`onSetState` (there are also `onData` and `onError`) and `onRebuildState` are the appropriate palaces to execute side effects such as calling model methods to fetch data or show snack bar or alert dialogs ...

In this example we are showing a snack bar containing the current value of the counter:

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counterRM.setState(
    (int currentState) => currentState+ 1,
    onSetState: (context) {

        Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(
            content: Text('${counterRM.state}'),
            ),
        );
    },
  );
},
```

As I mentioned above there are other equivalents of `onSetState` : 
* `onError`: it will be called if the execution method throws,
* `onDate`: It will be called after the data are available;

Take this case :

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counterRM.setState(
    (currentState) {
        //simulate an error at random
        if (Random().nextBool()) {
        throw Exception('A Counter Error');
        }
        return currentState + 1;
    },
    onError: (context, dynamic error) {
        //Show an alert dialog
        showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
            content: Text('${error.message}'),
            );
        },
        );
    },
    onData: (context, int data) {
        //show a snackBar
        Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(
            content: Text('$data'),
            ),
        );
    },
  );
},
tooltip: 'Increment',
child: Icon(Icons.add),
),
```

As you can see, form a simple `ReactiveModel.create(0)` we can 
* make widgets subscribe to it, 
* make them been notified to rebuild, 
* we can execute side effects before rebuild of after rebuild
* We can handle errors without manually catching them.

And there is more!

You can rarely find an app without executing non-blocking asynchronous tasks. Been forced to face them, we have to manage them so that the user of that app is visually informed that something is executing behind the scenes.

Take this case :

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counterRM.setState(
    (counter) async {
        //simulate a delay of 1 second
        await Future.delayed(Duration(seconds: 1));
        //simulate a random error
        if (Random().nextBool()) {
        throw Exception('A Counter Error');
        }
        return counter + 1;
    },
    //set catchError to true 
    catchError: true,
    );
},
tooltip: 'Increment',
child: Icon(Icons.add),
),
```
Here we are simulating an asynchronous task which can fail. We explicitly set catchError to true to not brake the app.

We remove `onError` and `onData` callbacks because we want for this demo example to display informative widgets for the different asynchronous status.

in the `StatesRebuilder` we change to be as follows:

```dart
StateBuilder(
    observe: () => ReactiveModel.create(0),
    builder: (context, counterRM) {
    //Idle state
    if (counterRM.isIdle) {
        return Text('Tap on the FAB to increment the counter');
    }
    //waiting state
    if (counterRM.isWaiting) {
        return CircularProgressIndicator();
    }
    //error state
    if (counterRM.hasError) {
        return Text(counterRM.error.message);
    }
    //data is available.
    // counterRM.hasData == true
    return Text(
        //get the current value of the counter
        '${counterRM.state}',
        style: Theme.of(context).textTheme.headline5,
    );
  },
),
```
By defaults states_rebuilder tracks for state:
* *idle* : Before executing any method;
* *waiting* :  while executing and asynchronous method:
* *error* : if the asynchronous method ends with error;
* *data* : if the asynchronous method resolves with data.

There are two shortcuts (or syntactic sugar) of the above `StateRebuilder` code:
1. using `whenConnectionState` method :
```dart
StateBuilder(
    observe: () => ReactiveModel.create(0),
    builder: (context, counterRM) {
    return counterRM.whenConnectionState(
        onIdle: () => Text('Tap on the FAB to increment the counter'),
        onWaiting: () => CircularProgressIndicator(),
        onError: (error) => Text(counterRM.error.message),
        onData: (data) => Text(
        '${counterRM.state}',
        style: Theme.of(context).textTheme.headline5,
        ),
    );
    },
),
```
2. using `WhenRebuilder` widget:
```dart
WhenRebuilder<int>(
    observe: () => ReactiveModel.create(0),
    onIdle: () => Text('Tap on the FAB to increment the counter'),
    onWaiting: () => CircularProgressIndicator(),
    onError: (error) => Text(counterRM.error.message),
    onData: (data) => Text(
    '$data',
    style: Theme.of(context).textTheme.headline5,
),
```
By the end of this first tutorial: 
*  you understand and feel the power of `ReactiveModel` concept.
*  We have made a primitive integer value of zero reactive, widgets can subscribe to it to be notified form the `ReactiveModel`. 
* `setState` is used to mutate the value and trigger a notification to observer widget. 
* There are a bunch of callback to be used to execute side effects (`onSetState`, `onRebuildState`, `onError`, `onData`). 
* Widgets can subscribe to the `ReactiveModel` via `StateBuilder` and `WhenRebuilder` widgets.

finally, alongside with the concept of `ReactiveModel`, it remains three other concepts to reveal the full power of states_rebuilder:
1. The concept of new reactive models where you can create for the same model (zero in our example) as many reactive models as you want.
2. the idea of tag and filter notification with tags and
3. the watch parameter which helps to prevent the rebuild unless the watched parameters change.


# Test:

## simple_counter_test:
```dart
void main() {
  testWidgets('should increment counter and show snackbar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyHomePage(
        title: 'simple counter',
      ),
    ));

    expect(find.text('0'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    //first tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //find two: one in the body of the scaffold and the other in the SnackBar
    expect(find.text('1'), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);

    //second tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('2'), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
```

## simple_counter_with_error.dart and async_counter_app.dart 

Can not be tested because the business logic is mixed with the UI logic
The `Random().nextBool()` can not be neither expected nor mocked.

This is an example of bad code. In the next tutorials we will introduce `Injector` and our code will be easily tested.

