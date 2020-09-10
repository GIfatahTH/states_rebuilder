# flutter_default_counter_app

> Don't forget to run `flutter create .` from the terminal in the project directory to create platform-specific files.

In this example, we will build the default counter app using global functional injection

This simple example aims to understand what ReactiveModel means and how it renders a pure dart object to reactive and how observers subscribe to it and how the observable reactive model notifies observers to rebuild.

> You can get more information from this tutorial :[Global function injection from A to Z](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection)


After adding the latest version of `states_rebuilder` to dependencies in the `pubspec.yaml`, we first define a global counter final variable:
 
```dart
final Injected<int> counter = RM.inject<int>(() => 0);
```
`counter` is a global variable but the state of the `counter` is not. It can be easily mocked and tested.

In the main.dart file, we have: 
```dart
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
      //Assign navigatorKey so we can route and show Dialogs and snackBars without context
      navigatorKey: RM.navigate.navigatorKey,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

To be able to navigate between pages, show dialogs, menus, bottom sheets and snackBars form outside the UI we have assigned the `navigatorKey` of the `MaterialApp` to the states_rebuilder `RM.navigate.navigatorKey`.

> For more details on how to navigate and show  dialogs without BuildContext, please check [here](https://github.com/GIfatahTH/states_rebuilder/wiki/side_effects_without_buildContext)

```dart
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

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
            //subscribe to counter injected model
            counter.rebuilder(
              () => Text(
                '${counter.state}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            //We can use StateBuilder instead
            // StateBuilder(
            //   observe: () => counter.getRM,
            //   builder: (context, counter) => Text(
            //     '${counter.state}',
            //     style: Theme.of(context).textTheme.headline5,
            //   ),
            // )
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            counter.setState(
              (counter) => counter + 1,
              //onSetState callback is invoked after counter emits a notification and before rebuild
              //context to be used to shw snackBar

              onSetState: (context) {
                //show snackBar
                //any current snackBar is hidden.

                //This call of snackBar is independent of BuildContext
                //Can be called any where
                RM.scaffoldShow.snackBar(
                  SnackBar(
                    content: Text('${counter.state}'),
                  ),
                );
              },
              //onRebuildState is called after rebuilding the observer widget
              onRebuildState: (context) {
                //
              },
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
```

## Subscription:

To subscribe to the injected counter model, we used:

```dart
counter.rebuilder(
    () => Text(
      '${counter.state}',
      style: Theme.of(context).textTheme.headline5,
    ),
  ),
```
Which is a short hand of :

```dart
StateBuilder(
  observe: () => counter.getRM,
  builder: (context, counter) => Text(
    '${counter.state}',
    style: Theme.of(context).textTheme.headline5,
  ),
)
```
> `StateBuilder` has more options. Use rebuilder unless you need any of the other `StateBuilder` options

* Here is the API of `rebuilder` method:
```dart
counter.builder(
  () => MyWidget(),
  initState: (){
    // When the widget is first inserted into the widget tree.
  },
  dispose: (){
    // When the widget is removed the widget tree.
  },
  key : Key('MyKey'),
)
```
* Here is the API of `StateBuilder` method:

```dart
StateBuilder<T>(
  onSetState: (BuildContext context, ReactiveModel<T> exposedModel){
  /*
  Side effects to be executed after sending notification and before rebuilding the observers. Side effects are navigating, opening the drawer, showing snackBar,...  
  
  It is similar to 'onSetState' parameter of the 'setState' method. The difference is that the `onSetState` of the 'setState' method is called once after executing the 'setState'. But this 'onSetState' is executed each time a notification is sent from one of the observable models this 'StateBuilder' is subscribing.
  
  You can use another nested setState here.
  */
  },
  onRebuildState: (BuildContext context, ReactiveModel<T> exposedModel){
  // The same as in onSetState but called after the end rebuild process.
  },
  initState: (BuildContext context, ReactiveModel<T> exposedModel){
  // Function to execute in initState of the state.
  },
  dispose: (BuildContext context, ReactiveModel<T> exposedModel){
  // Function to execute in dispose of the state.
  },
  didChangeDependencies: (BuildContext context, ReactiveModel<T> exposedModel){
  // Function to be executed  when a dependency of state changes.
  },
  didUpdateWidget: (BuildContext context, ReactiveModel<T> exposedModel, StateBuilder oldWidget){
  // Called whenever the widget configuration changes.
  },
  afterInitialBuild: (BuildContext context, ReactiveModel<T> exposedModel){
  // Called after the widget is first inserted in the widget tree.
  },
  afterRebuild: (BuildContext context, ReactiveModel<T> exposedModel){
  /*
  Called after each rebuild of the widget.

  The difference between onRebuildState and afterRebuild is that the latter is called each time the widget rebuilds, regardless of the origin of the rebuild. 
  Whereas onRebuildState is called only after rebuilds after notifications from the models to which the widget is subscribed.
  */
  },
  // If true all model will be disposed when the widget is removed from the widget tree
  disposeModels: true,

  // an observer model to which this widget will subscribe.
  observe : ()=> model1
  // like observe but for observing more than one model
  observeMany : [()=>model1, ()=>model2]

  shouldRebuild: (ReactiveModel<T> exposedModel){
    //Returns bool. if true the widget will rebuild if notified.
    
    //By default StateBuilder will rebuild only if the notifying model has data.
    return exposedModel.hasData.
  }

  // Tag to be used to filer notification from observable classes.
  // It can be any type of data, but when it is a List, 
  // this widget will be saved with many tags that are the items in the list.
  tag: dynamic

  //Similar to the concept of global key in Flutter, with ReactiveModel key you
  //can control the observer widget associated with it from outside.
  ///[see here for more details](changelog/v-1.15.0.md)
  rmKey : RMKey();

   watch: (ReactiveModel<T> exposedModel) {
    //Specify the parts of the state to be monitored so that the notification is not sent unless this part changes
  },


  builder: (BuildContext context, ReactiveModel<T> exposedModel){
    /// [BuildContext] can be used as the default tag of this widget.

    /// The model is the first instance (model1) in the list of the [models] parameter.
    /// If the parameter [models] is not provided then the model will be a new reactive instance.
  },
  builderWithChild: (BuildContext context, ReactiveModel<T> model, Widget child){
    ///Same as [builder], but can take a child widget exposedModel the part of the widget tree that we do not want to rebuild.
    /// If both [builder] and [builderWithChild] are defined, it will throw.

  },

  //The child widget that is used in [builderWithChild].
  child: MyWidget(),

)
```

> You can also subscribe using `counter.whenRebuilder` and `counter.whenRebuilderOr`, with are equivalent to `WhenRebuilder` and `WhenRebuilderOr` respectively.
## notification:

To notify observer widgets (we have one; `counter.rebuilder` widget) we call use the `state` getter and setter.

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counter.state++;;
},
tooltip: 'Increment',
child: Icon(Icons.add),
),
```

If you want more options such executing side effects before rebuild or after it use setState.

```dart
onPressed: () {
    //set the state of the counter and notify observer widgets to rebuild.
    counter.setState(
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
*  `onSetState` : a callback to be executed after `counter` emits a notification and before rebuilding observable widgets.

*  `onRebuildState` : a callback to be executed after `counter` emits a notification and after rebuilding observable widgets.

> Both `onSetState` and `onRebuildState` will be fired only if the rebuild is caused by `counter` notification.

`onSetState` (there are also `onData` and `onError`) and `onRebuildState` are the appropriate palaces to execute side effects such as calling model methods to fetch data or show snack bar or alert dialogs ...

In this example we are showing a snack bar containing the current value of the counter:

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counter.setState(
    (int currentState) => currentState+ 1,
    //BuildContext to be use to show a snackBar
    context: context,
    onSetState: (context) {

      //show snackBar
      //any current snackBar is hidden
      //This call of snackBar is independent of BuildContext
      //Can be called any where
      RM.scaffoldShow.snackBar(
        SnackBar(
          content: Text('${counter.state}'),
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
    counter.setState(
    (currentState) {
        //simulate an error at random
        if (Random().nextBool()) {
        throw Exception('A Counter Error');
        }
        return currentState + 1;
    },
    onError: (context, dynamic error) {
        //Show an alert dialog
        //It is independent from the context
        //It can be called anywhere
        RM.navigate.toDialog(
          AlertDialog(
            content: Text('${error.message}'),
          ),
        );
        );
    },
    onData: (context, int data) {
      //show snackBar
      //any current snackBar is hidden
      //This call of snackBar is independent of BuildContext
      //Can be called any where
      RM.scaffoldShow.snackBar(
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

You can rarely find an app without executing non-blocking asynchronous tasks. Been forced to face them, we have to manage them so that the user of that app is visually informed that something is executing behind the scenes.

Take this case :

```dart
floatingActionButton: FloatingActionButton(
onPressed: () {
    counter.setState(
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

To subscribe to counter model we can use counter.whenRebuilder to handle all possible asynchronous state the app may have:

```dart
counter.whenRebuilder(
    onIdle: () => Text('Tap on the FAB to increment the counter'),
    onWaiting: () => CircularProgressIndicator(),
    onError: (error) => Text(counter.error.message),
    onData: () => Text(
    '$data',
    style: Theme.of(context).textTheme.headline5,
),

By defaults states_rebuilder tracks for state:
* *idle* : Before executing any method;
* *waiting* :  while executing and asynchronous method:
* *error* : if the asynchronous method ends with error;
* *data* : if the asynchronous method resolves with data.


### Test:

### simple_counter_test:
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
