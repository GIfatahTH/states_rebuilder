# ex_000_hello_world

Let's say hello world, using functional injection of states_rebuilder.

## Injecting the state:
Declare a final global variable that injects a String state of "Hello world"

```dart
final helloWorld = RM.inject(() => 'Hello world');
```
The injected state has a lifecycle. It is created lazily the first time it is used, and destroyed when no longer used. Throughout the span of its life,Observes can listen to the state, and the state will notify them when changed.

The created state can be easily mocked in test and it will be automatically reset for each test so that the state is not shared between unit tests.

> NB: there are three other types of injection: `RM.injectFuture`, `RM.injectStream`, and `RM.injectFlavor`.

## Reading the state:

In the widget tree or in any other part of your code, we can read the state using the `state` getter

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Hello world Example')),
        body: Center(
          //simply use the global variable helloWorld to get its state.
          child: Text(helloWorld.state),
        ),
      ),
    );
  }
}
```

## Listen to the state and notify listeners:

Injected models can listen to each other and in a similar manner widgets can listen to one or more injected models to rebuild when notified.

Let's change the hello world to say hello to the entered name in a TextField. We will use two injected models `name` and `helloName`

```dart
// create a name state and inject it.
final name = RM.inject(() => '');
//Or using extensions
final name = ''.inj();

final helloName = RM.inject(
  () => 'Hello ${name.state}',
  // helloName depends on the name injected model.
  // Whenever the name state changes the helloName will recalculate its
  // creation function and notify its listeners
  dependsOn: DependsOn({name}),
);
```

Here `helloName` is registered to listen to a set of injected model (here only one injected model). When the `name` injected model emits a notification, the `helloName` will recalculate its state and notify its listeners.

>NB: Injected models emits a notification to their listeners when their state changes. The state is emitted with a flog describing its status (idle, waiting, error, data).


Widgets can listen to an injected model using the `listenTo` method.
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Hello world Example')),
        body: Column(
          children: [
            TextField(
              onChanged: (String value) {
                // state mutation
                name.state = value;
                // After state mutation, notify helloName to recalculate
                // and rebuild
              },
            ),
            Center(
              // listen to helloName injected model
              child: On(
                  // This part will be re-rendered each time the helloName
                  // emits notification of any kind of status (idle, waiting,
                  // error, data).
                  () => Text(helloName.state),
                ).listenTo(helloName),
            ),
          ],
        ),
      ),
    );
  }
}
```
In the `onChange` callback of the `TextField`, we mutate the state of the `name` injected model. This latter will notify the `helloName` injected model to recalculate its state and notify its listener which is a widget defined inside the `On` constructor.

The child of the `listen` method take an `On` Objects which have many named constructors.
* `On` : default constructor, will rebuild any time the injected model emits a notification with any status type.
* `On.data` : Will rebuild only if the injected model emits notification with `hasData` flag equal to true.
* `On.waiting` : Will rebuild only if the injected model emits notification with `isWaiting` flag equal to true.
* `On.error` : Will rebuild only if the injected model emits notification with `hasError` flag equal to true.
* `On.all` : give you call backs to handle all possible four state status.
* `On.or` : give you call backs to optionally handle all possible four state status with default one to handle non defined state status.

## state status and side effects:

As I said, injected models emit notification with a state flag.
* `isIdle`: The model is newly created and it is fresh and virgin.
* `isWaiting`: the model is waiting for an async task to emit data.
* `hasError`: the model has an error.
* `hadData`: the model has a valid data.

Let's imagine that we can obtain more info of the entered name form a repository.

```dart
class NameRepository {
  Future<String> getNameInfo(String name) async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextInt(10) > 6) {
      // Async task are error prone process and exceptions 
      // must be handled for a good user experience.
      throw Exception('Server Error');
    }
    return 'This is the info of $name';
  }
}
```
The next step is to inject the state of the `NameRepository`:

```dart
final repository = RM.inject(() => NameRepository());
```
> Note for test: The behavior of the repository is not predicted because it depends on a random number. In test we define a fake implementation of NameRepository, and injected it using : `repository.injectMock(()=> FakeNameRepository())`; and voila, just pump the widget and test it predictably. (See test folder)

For side effects, we want to display a `SnackBar` containing `CircularProgressIndicator` while we are waiting for the repository to return data, and another `SnackBar` with a message of the error, it the repository fails getting the data.

```dart
// create a name state and inject it.
final name = RM.inject(() => '');

final helloName = RM.inject<String>(
  () => 'Hello, ${name.state}',
  // helloName depends on the name injected model.
  // Whenever the name state changes the helloName will recalculate its
  // creation function and notify its listeners.
  //
  // helloName state status is a combination of its own state and the state
  // of the injected models that it depends on.
  // ex: if name is waiting => helloName is waiting,
  //     if name has error => helloName has error,
  //     if name has data => helloName state will be recalculated
  //
  dependsOn: DependsOn(
    {name},
    // Do not recalculate until 400 ms has been passed without any
    // further notification from name injected model.
    debounceDelay: 400,
  ),
  // Execute side effects while notify the state
  //
  // It take on On objects, it has many named constructor: On.data, On.error,
  // On.waiting, On.all and On.or
  onSetState: On.or(
    onWaiting: () => RM.scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('Waiting ...'),
            Spacer(),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
    onError: (err) => RM.scaffold.showSnackBar(
      SnackBar(content: Text('${err.message}')),
    ),
    //the default case. hide the snackbar
    or: () => RM.scaffold.hideCurrentSnackBar(),
  ),
);
```

Notice that we can display `SnackBars` or and other kind of Dialogs without been force to have a valid `BuildContext`.

This can be done after assign the `navigatorKey` of `MaterialApp` to the `RM.navigate.navigatorKey` of the `states_rebuilder` widget.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // To navigate and show snackBars without the BuildContext, we define
      // the navigator key
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: Text('Hello world Example')),
        body: Column(
          children: [
            TextField(
              onChanged: (String value) {
                // state mutation
                name.setState(
                  (s) => repository.state.getNameInfo(value),
                  //You can debounce from here so that the getNameInfo method
                  //will not be invoked unless 400ms has passed without and other
                  //setState call.

                  // debounceDelay: 400,
                );
                // After state mutation, notify helloName to recalculate
                // and rebuild
              },
            ),
            Spacer(),
            Center(
              child: On.all(
                  // This part will be re-rendered each time the helloName
                  // emits notification of any kind of status (idle, waiting,
                  // error, data).
                  onIdle: () => Text('Enter your name'),
                  onWaiting: () => CircularProgressIndicator(),
                  onError: (err) => Text('${err.message}'),
                  onData: () => Text(helloName.state),
                )listenTo(helloName),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
```
Notice that the state of name injected model is mutated using the `setState` method.

> setState has many options among them is throttling or denouncing state mutation. You can also override the global side effect by defining side effects that will be executed for the call of setState only.

## stream injection and refreshing the state

The injected state can be manually refreshed. By refreshing the state is recalling its creation function and notify its listeners.

Let's take this example using RM.injectStream:

```dart
//Stream that emits the entered name letter by letter
final streamedHelloName = RM.injectStream<String>(
  () async* {
    final letters = name.state.trim().split('');
    var n = '';
    for (var letter in letters) {
      await Future.delayed(Duration(milliseconds: 50));
      // yield the name letter by letter
      yield n += letter;
    }
  },
  onInitialized: (data, subscription) {
    // As the stream will start automatically on creation,
    // we use the onInitialized hook to pause it.
    subscription.pause();
  },
);
```
The stream split the name and emits it letter after letter.

The onInitialized callback, is called after the creation of the stream. It is the right place to pause the autoStarted Stream.

in the UI, we add the following code:

```dart
  RaisedButton(
    child: Text('Start Streaming'),
    onPressed: () {
      // Calling refresh on any injected will re-execute its creation
      // Function and notify its listeners
      streamedHelloName.refresh();
    },
  ),
  SizedBox(height: 20),
  On.data(
      //This will rebuild if the stream emits valid data only
      () => Text('${streamedHelloName.state}'),
    )listenTo(streamedHelloName),
```
## undo and redo state:

To be able to undo and redo state, you have to define the `undoStackLength` of any injected.
```dart
final helloName = RM.inject<String>(
  () => 'Hello, ${name.state}',
  dependsOn: DependsOn(
    {name},
    debounceDelay: 400,
  ),
  //Set the undoStackLength to 5. This will automatically 
  // enable doing and undoing of the  state
  undoStackLength: 5,
);
```

In the UI:

```dart
Row(
  children: [
    On.data(
        () => IconButton(
          icon: Icon(Icons.arrow_left_rounded,
          //check if we can undo the state to enable the 
          //button
          onPressed: helloName.canUndoState
              ? () => helloName.undoState()//undo the state
              : null,
        ),
      ).listenTo(helloName),
    Spacer(),
    Center(
      child: On.all(
          onIdle: () => Text('Enter your name'),
          onWaiting: () => CircularProgressIndicator(),
          onError: (err) => Text('${err.message}'),
          onData: () => Text(helloName.state),
        ).listenTo(helloName),
    ),
    Spacer(),
    On.data(
        () => IconButton(
          icon: Icon(Icons.arrow_right_rounded),
          //check if we can undo the state to enable the 
          //button
          onPressed: helloName.canRedoState
              ? () => helloName.redoState()//redo the state
              : null,
        ),
    ).listenTo(helloName),
  ],
),
```
Note the the state the are add to the undoStack are those that have valid data, that is `hasData` is true. State with error or waiting are ignored.

#Persisting the state.

To persist the state you have first to implement the `IPersistState` interface using a local storage provider of your choice (hive or sharedPreferences).