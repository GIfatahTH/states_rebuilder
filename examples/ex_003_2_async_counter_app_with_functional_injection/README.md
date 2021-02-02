# async_counter_app_with_injector

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.

In this example, we will go towards more realistic situations. Let's define the counter store:

> You can get more information from this tutorial :[Global function injection from A to Z](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection)


Imagine we want our app to have two flavors:
- the first that increments by one and have a primarySwatch color of blue.
- the second that increments by two and have a primarySwatch color of orange.

First let's define an enum for flavors:

```dart
enum Flavor { IncrByOne, IncrByTwo }
```

Then let's define an interface for app configuration and its two implementations:

```dart
abstract class IConfig {
  String get appName;
  MaterialColor get color;
}

class IncrByOneConfig implements IConfig {
  @override
  String get appName => 'Increment By one Flavor';

  @override
  MaterialColor get color => Colors.blue;
}

class IncrByTwoConfig implements IConfig {
  @override
  String get appName => 'Increment By two Flavor';

  @override
  MaterialColor get color => Colors.orange;
}
```

The same for the CounterStore, lets define an interface with its two implementations:

```dart
abstract class ICounterStore {
  int count;
  void increment();
}

class CounterStoreByOne implements ICounterStore {
  CounterStoreByOne(this.count);

  @override
  int count;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}

class CounterStoreByTwo implements ICounterStore {
  CounterStoreByTwo(this.count);

  @override
  int count;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count += 2;
  }
}
```

## Injection

```dart
//Use injectFlavor which takes a map of our flavours.
final config = RM.injectFlavor(
  {
    Flavor.IncrByOne: () => IncrByOneConfig(),
    Flavor.IncrByTwo: () => IncrByTwoConfig(),
  },
);

final counterStore = RM.injectFlavor(
  {
    Flavor.IncrByOne: () => CounterStoreByOne(0),
    Flavor.IncrByTwo: () => CounterStoreByTwo(0),
  },
  //As config model have any observer, it can not be disposed automatically,
  //we have to Dispose it Manually.
  //For this example here is the appropriate place
  onDisposed: (_) => config.dispose(),
);
```

## The UI:

```dart

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //set navigatorKey
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Increment by one flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    Injector.env = Flavor.IncrByOne;
                    //Navigating to the same MyHomePage()
                    RM.navigate.to(MyHomePage());
                  },
                ),
                RaisedButton(
                  child: Text('Increment by Two flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    Injector.env = Flavor.IncrByTwo;
                    RM.navigate.to(MyHomePage());
                  },
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

```

The MyApp widget has two buttons to navigate to the MyHomePage with different flavors. The static variable `Injector.env` holds the chosen environment flavor.

```dart
class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: config.state.color),
      child: Scaffold(
        appBar: AppBar(
          title: Text(config.state.appName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              //Subscribing to the counterRM using StateBuilder
              On.all(
                onIdle: () => Text('Tap on the FAB to increment the counter'),
                onWaiting: () => CircularProgressIndicator(),
                onError: (error) => Text(counterStore.error.message),
                onData: () => Text(
                  '${counterStore.state.count}',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ).listenTo(counterStore),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //set the state of the counter and notify observer widgets to rebuild.
            counterStore.setState((s) => s.increment());
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

```


## test

Here is the easiness of testing with global function injection.

```dart

void main() {
  //Here we override both the flavors by FakeCounterStore.
  //
  //the config is not overridden because its behavior is predictable.
  counterStore.injectMock(() => FakeCounterStore(0));

  testWidgets('async counter without error (IncrByOne flavor)', (tester) async {
    await tester.pumpWidget(MyApp());
    //
    //We choose the flavor
    Injector.env = Flavor.IncrByOne;
    //As our navigation is BuildContext free, from here we navigate to MyHomePage
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
    //
    //We expect the app to display (Increment By one Flavor)
    expect(config.state.appName, 'Increment By one Flavor');
    expect(find.text('Increment By one Flavor'), findsOneWidget);

    //on Idle state, we expect to see the welcoming text
    expect(
      find.text('Tap on the FAB to increment the counter'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //on Waiting state, we expect to see a CircularProgressIndicator
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    await tester.pump(Duration(seconds: 1));

    //on data state, we expect to see the value of 1.
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('async counter with error', (tester) async {
    //Fake class behavior is predictable. we set shouldThrow to true to expect en error
    counterStore.injectMock(() => FakeCounterStore(0)..shouldThrow = true);

    await tester.pumpWidget(MyApp());
    //
    Injector.env = Flavor.IncrByOne;
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
    //on Idle state
    expect(
      find.text('Tap on the FAB to increment the counter'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //on Waiting state
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    await tester.pump(Duration(seconds: 1));

    //on error state, we expect to see the error message
    expect(find.text('A Counter Error'), findsOneWidget);
  });

  testWidgets('async counter without error (IncrByTwo flavor)', (tester) async {
    await tester.pumpWidget(MyApp());
    //
    //Here we choose IncrByTwo flavor
    Injector.env = Flavor.IncrByTwo;
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
    //
    //We expect the app to display (Increment By one Flavor)
    expect(config.state.appName, 'Increment By two Flavor');
    expect(find.text('Increment By two Flavor'), findsOneWidget);
    //
    //on Idle state, we expect to see the welcoming text
    expect(
      find.text('Tap on the FAB to increment the counter'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //on Waiting state, we expect to see a CircularProgressIndicator
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    await tester.pump(Duration(seconds: 1));

    //on data state, we expect to see the value of 1. (should be 2 but we
    //override it to be 1)
    expect(find.text('1'), findsOneWidget);
  });
}

//fake class must extends the real class
class FakeCounterStore extends ICounterStore {
  FakeCounterStore(this.count);
  int count;
  bool shouldThrow = false;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));

    //use shouldThrow instead of random in real class to control the behavior of the fake class
    if (shouldThrow) {
      throw Exception('A Counter Error');
    }
    count++;
  }

  @override
  String toString() {
    return 'FakeCounterStore($count)';
  }
}

```













