# async_counter_app_with_injector

In this example, we will go towards more realistic situations. Let's define the counter store:

```dart
class CounterStore {
  CounterStore(this.count);
  int count;

  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}
```

This represents the business logic of our app.

The UI part:

```dart
class MyApp extends StatelessWidget {
  final counterRM = ReactiveModel.create(CounterStore(0));
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _MyScaffold(
        counterRM: counterRM,
      ),
    );
  }
}
```



```dart
class _MyScaffold extends StatelessWidget {
  final ReactiveModel<CounterStore> counterRM;

  const _MyScaffold({Key key, this.counterRM}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      title: 'Flutter Demo Home Page',
      counterRM: counterRM,
    );
  }
}
```
`_MyScaffold` can be removed here, but I added if for the purpose of this tutorial. `_MyScaffold` do not use `counterRM`, it only passes it to the `MyHomePage` widget constructor. This kind of situation is often founded in real cases.

The `MyHomePage` looks like this:

```dart
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title, this.counterRM}) : super(key: key);

  final String title;
  final ReactiveModel<CounterStore> counterRM;

  @override
  Widget build(BuildContext context) {
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
            //Subscribing to the counterRM using StateBuilder
            WhenRebuilder<CounterStore>(
              models: [counterRM],
              onIdle: () => Text('Tap on the FAB to increment the counter'),
              onWaiting: () => CircularProgressIndicator(),
              onError: (error) => Text(counterRM.error.message),
              onData: (data) => Text(
                '${data.count}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //set the state of the counter and notify observer widgets to rebuild.
          counterRM.setState((s) => s.increment());
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```
If you followed the last tutorials you can easily understand the code. The only new thing here is that I used `setState` instead of `setValue`. Because here in our case, We do not want to create an other instance of `CounterStore`, but we want to mutate the state of `CounterStore` while keeping the same instance of it.

> `setValue` is more suitable for immutable objects while `setState` is better used with mutable objects.

> setValue is equivalent to setState with setValue parameter set to true.

for example.
```dart
counterRM.setValue(()=>2);

//it is equivalent to write:
counterRM.setState(
    (_)=>2,
    setValue:true,
)
```
# `Injector` for dependency injection:

As you may have noticed, `_MyScaffold` do not use `counterRM`, actually it is used by `MyHomePage` and `_MyScaffold` only pass it to the constructor of `MyHomePage`.

To deal with this kind of situation, you have to relay on dependency injection framework. In flutter you can use :
* `InheritedWidget`;
* `Provider` package: based on the InheritedWidget. It is widget aware and depend on the availability of the `BuildContext`.
* `get_it` package: Based on the IoC pattern. It is unaware of the widget life cycle and it is independent of the availability of the context.

`Injector` stands in between: it is aware of the widget life cycle so that you can do some logic in the `initState` hook and dispose resources in the `dispose` hook. At the same time it is independent from the availability of the `BuildContext`.

Let's refactor our example to use the `Injector` widget:

```dart
class MyApp extends StatelessWidget {
  //Remove this line
  //final counterRM = ReactiveModel.create(CounterStore(0));
  @override
  Widget build(BuildContext context) {
    return Injector(
        inject: [Inject(() => CounterStore(0))],
        builder: (context) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: _MyScaffold(),
          );
        });
  }
}
```
We wrapped the `MaterialApp` widget with Injector and inject the `CounterStore`. No need to explicitly create a `ReactiveModel` of the `CounterStore`.

>Injector lazily register two singletons of the injected model. The first is the singleton of the model itself and the second is the ReactiveModel of the registered row singleton.

At any time and at any child widget of the Injector : 
* To get the row singleton of the model use
```dart
final CounterStore counterStore = Injector.get<CounterStore>();
```
* To get the ReactiveModel singleton of the model use
```dart
final ReactiveModel<CounterStore> counterStoreRM = Injector.getAsReactive<CounterStore>();
//or 
final ReactiveModel<CounterStore> counterStoreRM = ReactiveModel<CounterStore>();
//or 
final ReactiveModel<CounterStore> counterStoreRM = RM.get<CounterStore>();

```

Now `_MyScaffold` becomes a simple useless widget:

```dart
class _MyScaffold extends StatelessWidget {
  //Remove this line
  // final ReactiveModel<CounterStore> counterRM;
  // const _MyScaffold({Key key, this.counterRM}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'Flutter Demo Home Page');
  }
}
```

and `MyHomePage` widget becomes:

```dart

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  final ReactiveModel<CounterStore> counterRM = RM.get<CounterStore>();
   //
   //
   [the same code as above]
}
```

With `Injector` you can:
* inject pure dart classes;
* inject primitive values and enumerations;
* inject futures and Streams;
* inject classes and register them with the Interface that they implement;
* inject multiple classes each for a flavor (devolvement environment) and register them with the Interface that they implement.

For more information see the official documentation.

Let's take an example of the last point: flavor in flutter:

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

The UI part:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          //Navigating to the same MyHomePage()
                          return MyHomePage();
                        },
                      ),
                    );
                  },
                ),
                RaisedButton(
                  child: Text('Increment by Two flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    Injector.env = Flavor.IncrByTwo;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          //Navigating to the same MyHomePage()
                          return MyHomePage();
                        },
                      ),
                    );
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

  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Named constructor Inject.interface is used to resister with flavors
        Inject.interface(
          {
            Flavor.IncrByOne: () => IncrByOneConfig(),
            Flavor.IncrByTwo: () => IncrByTwoConfig(),
          },
        ),
        Inject.interface(
          {
            Flavor.IncrByOne: () => CounterStoreByOne(0),
            Flavor.IncrByTwo: () => CounterStoreByTwo(0),
          },
        ),
      ],
      //initState is called when the Injector is inserted in the widget tree
      initState: () => print('initState'),
      //dispose is called when the Injector is removed from the widget tree
      dispose: () => print('dispose'),
      
      builder: (context) {

        //getting the counterRM from the interface. The exact implementation is defined by Injector.env
        final counterRM =RM.get<ICounterStore>();

        //getting the config without reactivity
        final config = Injector.get<IConfig>();

        return Theme(
          data: ThemeData(primarySwatch: config.color),
          child: Scaffold(
            appBar: AppBar(
              title: Text(config.appName),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  //Subscribing to the counterRM using StateBuilder
                  WhenRebuilder<ICounterStore>(
                    observe: ()=>counterRM,
                    onIdle: () =>
                        Text('Tap on the FAB to increment the counter'),
                    onWaiting: () => CircularProgressIndicator(),
                    onError: (error) => Text(counterRM.error.message),
                    onData: (data) => Text(
                      '${data.count}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                //set the state of the counter and notify observer widgets to rebuild.
                counterRM.setState((s) => s.increment());
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
```


# test

## counter_without_injector.dart

counter_without_injector.dart can not be tested  because ``MyApp`` class depends directly on `CounterStore` : 
```dart
class MyApp extends StatelessWidget {
  final counterRM = ReactiveModel.create(CounterStore(0));
  ....
  ....
}
```

So `CounterStore` can not be mocked and its behavior can not be expected.
One obvious solution is to inject the `CounterStore` dependency through the constructor, but this is what we do not want to do now. We want to use `Injector`.

## counter_with_injector.dart

```dart
void main() {
  Widget myApp;

  setUp(() {
    //set enableTestModel to true so that injector will inject the fake class and ignore there real class
    Injector.enableTestMode = true;
    myApp = Injector(
      //Injecting the fake class but register it with the real class type
      //fake class must extends the real class
      inject: [Inject<CounterStore>(() => FakeCounterStore(0))],
      builder: (_) => MyApp(),
    );
    //whenever Inject.get<CounterStore>() or Inject.getAsReactive<CounterStore>() are called
    // inside MyApp they will return the fake instance
  });

  testWidgets('async counter without error', (tester) async {
    await tester.pumpWidget(myApp);
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

    //on data state, we expect to see the value of 1 ( 0 incremented to 1).
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('async counter with error', (tester) async {
    await tester.pumpWidget(myApp);

    //Fake class behavior is predictable. we set shouldThrow to true to expect en error
    (Injector.get<CounterStore>() as FakeCounterStore).shouldThrow = true;

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
}

//fake class must extends the real class
class FakeCounterStore extends CounterStore {
  FakeCounterStore(int count) : super(count);

  
  bool shouldThrow = false;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));

    //use shouldThrow instead of random() in real class to control the behavior of the fake class
    if (shouldThrow) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}
```













