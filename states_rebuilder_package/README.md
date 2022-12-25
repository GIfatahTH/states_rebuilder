
<h1> States_rebuilder </h1>

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
![actions workflow](https://github.com/GIfatahTH/states_rebuilder/actions/workflows/config.yml/badge.svg)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)

<p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/Logo-Black.png" width="570" alt=''/>
</p>

<div align="center">

| Code Clean                                                          | Performance                             |
| ------------------------------------------------------------------- | --------------------------------------- |
| • Separation of UI & business logic                                 | ◦ Support for immutable / mutable state |
| • Coding business logic in pure Dart                                | ◦ Predictable and controllable          |
| • Zero Boilerplate without code-generation &nbsp;&nbsp;&nbsp;&nbsp; | ◦ Strictly rebuild control              |

</div>

<div align="center">

| User-friendly                                 | Effective Production                    |
| --------------------------------------------- | --------------------------------------- |
| ◦ Elegant and lightweight syntax              | • Super easy for CRUD development       |
| ◦ `SetState` & `Animation` in StatelessWidget | • User authentication and authorization |
| ◦ Navigation without `BuildContext`           | • App themes, multi-langs management    |
| ◦ Built-in dependency injection system        | • Easy to test, mock the dependencies   |

</div>

<h1> Table of Contents </h1>

- [Getting Started with States_rebuilder](#getting-started-with-states_rebuilder)
- [Breaking Changes](#breaking-changes)
- [A Quick Tour of states_rebuilder APIs](#a-quick-tour-of-states_rebuilder-apis)
  - [Business logic and state injection](#business-logic-and-state-injection)
  - [State change and notification](#state-change-and-notification)
  - [State subscription and Reactive Builders](#state-subscription-and-reactive-builders)
    - [OnReactive widget and ReactiveStatelessWidget](#onreactive-widget-and-reactivestatelesswidget)
    - [OnBuilder widget](#onbuilder-widget)
  - [Global and local state](#global-and-local-state)
    - [Global state](#global-state)
    - [Local state (Scoped state)](#local-state-scoped-state)
  - [State persistence](#state-persistence)
  - [Undo and redo immutable state](#undo-and-redo-immutable-state)
  - [Route management](#route-management)
  - [Create, Read, Update and Delete items from backend service](#create-read-update-and-delete-items-from-backend-service)
  - [Authentication and authorization](#authentication-and-authorization)
  - [Dynamic theme switching](#dynamic-theme-switching)
  - [App internationalization and localization](#app-internationalization-and-localization)
  - [Animation in StatelessWidget](#animation-in-statelesswidget)
    - [Implicit and explicit animation](#implicit-and-explicit-animation)
  - [Working with TextFields and Form validation](#working-with-textfields-and-form-validation)
  - [Working with scrollable view](#working-with-scrollable-view)
  - [Working with page and tab views](#working-with-page-and-tab-views)
  - [Test and injected state mocking](#test-and-injected-state-mocking)
- [Examples](#examples)
  - [State management concepts](#state-management-concepts)
  - [Navigation](#navigation)
  - [Devolvement booster](#devolvement-booster)
  

> Although states_rebuilder is a feature-rich library, the maintenance cost is very low, and the size of the library is small. this is because states_rebuilder does not draw a single pixel on the screen and the way the internal code is structured makes adding new functionality a straightforward process with fewer lines of code.

</br>

# Getting Started with States_rebuilder

1. Install this package:

- With Flutter:

```yaml
 flutter pub add states_rebuilder
```

- Or: add into your pubspec.yaml:

```yaml
  dependencies:
    states_rebuilder: ... 
```

1. Import it in any Dart code:

```dart
import 'package:states_rebuilder/states_rebuilder.dart';
```

2. Basic use case:

```dart
/* -------------  🗄️ Plain Data Class ------------- */
class Counter {
  final int value;
  Counter(this.value);
  
  @override
  String toString() => 'Counter($value)';
}

/* --------------  🤔 Business Logic -------------- */
//🚀 These states are immutable
@immutable
class ViewModel {
  // Inject a reactive state of type int.
  // Works for all primitives, List, Map and Set
  final counter1 = 0.inj();

  // For non primitives and for more options
  final counter2 = RM.inject<Counter>(
    () => Counter(0),
    // State will be redone and undone
    undoStackLength: 8,
    // Build-in logger
    debugPrintWhenNotifiedPreMessage: 'counter2',
  );

  //A getter that uses the state of the injected counters
  int get sum => counter1.state + counter2.state.value;

  incrementCounter1() {
    counter1.state++;
  }

  incrementCounter2() {
    counter2.state = Counter(counter2.state.value + 1);
  }
}

/* ------------------- 👍 Setup ------------------- */
/// 🚀 As [ViewModel] is immutable and final, it is safe to globally instantiate it.
// The state of counter1 and counter2 will be auto-disposed when no longer in use.
// NOTE: They are testable and mockable.

// States inject like this have global scope and can be reached from anywhere.
final viewModel = ViewModel();
// To create many independent instances of viewModel and inject them into the widget 
// tree using the concept of InheritedWidget, see the section on global and local 
// state below.

/* --------------------  👀 UI -------------------- */
///🚀 Just use [ReactiveStatelessWidget] widget instead of StatelessWidget.
// CounterApp will automatically register in any state consumed in its widget child 
// branch, regardless of its depth, provided the widget is not lazily loaded as 
// in the builder method of the ListView.builder widget. 

// BTW, if you're looking for optimization for rebuild by target widget, 
// check out [OnReactive] or [OnBuilder].
class CounterApp extends ReactiveStatelessWidget {
  const CounterApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Counter1View(), // Not const to make it rebuildable
            const Counter2View(), // Notice the use of const modifier (good approach)
            Text('🏁 Result: ${viewModel.sum}'), // Will be updated when sum changes
          ],
        ),
      ),
    );
  }
}

// Child 1 - Plain StatelessWidget
class Counter1View extends StatelessWidget {
  const Counter1View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: const Text('🏎️ Counter1 ++'),
          onPressed: () => viewModel.incrementCounter1(),
        ),
        // Listen to the state from parent
        Text('Counter1 value: ${viewModel.counter1.state}'),
      ],
    );
  }
}

// Child 2 - User ReactiveStatelessWidget because Counter2View 
// is instantiated with const modifier
class Counter2View extends ReactiveStatelessWidget {
  const Counter2View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: const Text('🏎️ Counter2 ++'),
          onPressed: () => viewModel.incrementCounter2(),
        ),
        ElevatedButton(
          child: const Text('⏱️ Undo'),
          onPressed: () => viewModel.counter2.undoState(),
        ),
        Text('Counter2 value: ${viewModel.counter2.state.value}'),
      ],
    );
  }
}
```

# Breaking Changes

| Breaking Version | Support             | Link                                                                                                           |
| ---------------- | ------------------- | -------------------------------------------------------------------------------------------------------------- |
| **5.0**          | ✅  Least version    | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-5.0.0.md) |
| **4.0**          | Legacy (2021-09-30) | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-4.0.0.md) |
| **3.0**          | Legacy (2020-09-04) | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-3.0.0.md) |
| **2.0**          | Legacy (2020-06-02) | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-2.0.0.md) |

> Use of modern version is recommended for getting maximum performance & development experience with **flutter 2.0**.

</br>

# A Quick Tour of states_rebuilder APIs

## Business logic and state injection


The specificity of `states_rebuilder` is that it has practically no boilerplate. It has no boilerplate to the point where you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold for example `onLoading`, `onLoaded`, `onError` states. `states_rebuilder` automatically manages these asynchronous statuses and exposes the `isIdle`,`isWaiting`, `hasError` and`hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic. In addition you have the full control on which state status to ignore.

>With `states_rebuilder`, you write business logic without bearing in mind how the user interface would interact with it.
</br>

This is a typical simple business logic class:

```dart
class Foo { // Don't extend any other library specific class
  int mutableState = 0; // The state can be mutable 
  final int immutableState; // Or it can be immutable (no difference)
  Foo(this.immutableState);

  Future<int> fetchSomeThing async(){
    // No need for any kind of async state tracking variables
    return repository.fetchSomeThing();
    // No need for any kind of notification
  }

  Stream<int> streamSomeThing async*(){
    // Methods can return stream, future, or simple sync objects,
    // states_rebuilder treats them equally
  }
}
```

To make the `Foo` object reactive, we simply inject it using global functional injection:

```dart
final Injected<Foo> foo = RM.inject<Foo>(
  ()=> Foo(),
  onInitialized : (Foo state) => print('Initialized'),
  // Default callbacks for side effects.
  sideEffects: SideEffects(
    onSetState: (snap){
      snap.onAll(
        onIdle: () => print('Is idle'),
        onWaiting: () => print('Is waiting'),
        onError: (error) => print('Has error'),
        onData: (Foo data) => print('Has data'),
      );
    },
    // It is disposed when no longer needed
    dispose: ()=>  print('Disposed'),
  ),
  // To persist the state
  persist:() => PersistState(
      key: '__FooKey__',
      toJson: (Foo s) => s.toJson(),
      fromJson: (String json) => Foo.fromJson(json),
      // Optionally, throttle the state persistance
      throttleDelay: 1000,
  ),

  // stateInterceptor as a middleWare place
  // It can also be used to return another state created 
  // from the current state and the next state.
  stateInterceptor: (currentSnap, nextSnap) {
    // Example of simple email validation
    if (nextSnap.hasData) {
      if (!nextSnap.data.contains('@')) {
        return nextSnap.copyToHasError(
          Exception('Enter a valid Email'),
        );
      }
    }
  },
);

// A handy syntax, injection you can use `.inj()` extension:
final foo = Foo().inj();
final isBool = false.inj();
final string = 'str'.inj();
final count = 0.inj();
final trueOrNull = null.inj<bool?>();
```

`Injected` interface is a wrapper class that encloses the state we want to inject. The state can be mutable or immutable.

Injected state can be instantiated globally or as a member of classes. They can be instantiated inside the build method without losing the state after rebuilds.

>To inject a state, you use `RM.inject`, `RM.injectFuture`, `RM.injectStream` or `RM.injectFlavor`.

**The injected state even if it is injected globally, it has a lifecycle**. It is created when first used and destroyed when no longer used. Between the creation and the destruction of the state, it can be listened to and mutated to notify its registered listeners.

**When the state is disposed of, its list of listeners is cleared**, and if the state is waiting for a Future or subscribed to a Stream, it will cancel them to free resources.

**Injected state can depend on other Injected states** and recalculate its state and notify its listeners whenever any of its Inject model that it depends on emits a notification.

  [🔍 See more detailed information about the RM.injected API](https://github.com/GIfatahTH/states_rebuilder/wiki/rm_injected_api).

## State change and notification

To mutate the state and notify to listener(s):

```dart
// Set state synchronously 
foo.state = newFoo;

// Set state asynchronously 
foo.stateAsync = repository.fetchSomeThing();

// For more options
foo.setState(
  (s) => s.fetchSomeThing(),
  // Run `side-effect` during setState
  sideEffects: SideEffects.onWaiting(()=> showSnackBar()),
  stateInterceptor: (currentSnap, nextSnap){
    // 
  }
  debounceDelay : 400,
);

// For boolean type state
foo.toggle();
```

The state when mutated emits a notification to its registered listeners. The emitted notification has a boolean flag to describe is status :

- `isIdle` : the state was first created and no notification has been emitted yet.
- `isWaiting`: the state is waiting for an async task to end.
- `hasError`: the state mutation has ended with an error.
- `hasData`: the state mutation has ended with valid data.
- `isActive`: the state had data at least one time.

Typically when executing any async task the state changes form `isWaiting` to `hasData` or `hasError`. In some use cases we are interested on skipping some of the stages. This can be done using `stateInterceptor` parameter.

```dart
// For more options
foo.setState(
  (s) => s.fetchSomeThing(),
  // stateInterceptor is called after new state calculation and just 
  // before state mutation. It exposes the current and the next snapState.
  stateInterceptor: (currentSnap, nextSnap){
    // Ignoring the waiting stage.
    if(nextSnap.isWaiting) return currentSnap;
  }
);
```

  [🔍 See more detailed information about  setState API](https://github.com/GIfatahTH/states_rebuilder/wiki/set_state_api).

You can notify listeners without changing the state using :

```dart
foo.notify();
```

You can also refresh the state to its initial state and reinvoke the creation function then notify listeners using:

```dart
foo.refresh();
```

`refresh` is useful to re-execute async data fetching to get the updated data from a server. Typical use is the refresh a ListView display.

If the state is persisted, calling `refresh` will delete the persisted state and replace it with the newly created one.

Calling `refresh` will cancel any pending async task from the state before refreshing.

 [🔍 See more detailed information about the refresh API](https://github.com/GIfatahTH/states_rebuilder/wiki/refresh_api).

## State subscription and Reactive Builders

There are <font color=#008000>**two ways**</font> to for get your widget rebuilds by state:

| Widget Builders                         | Style                         | Link                                                          |
| --------------------------------------- | ----------------------------- | ------------------------------------------------------------- |
| `OnReactive`, `ReactiveStatelessWidget` | 👩🏻‍💻 By default                  | [Finish him!](#onreactive-widget-and-reactivestatelesswidget) |
| `OnBuilder`                             | 👨🏻‍🚒 Strictly rebuilds by target | [Get Over Here!](#onbuilder-widget)                           |

</br>

### OnReactive widget and ReactiveStatelessWidget

To listen to an injected state and rebuild a part of the widget tree, just wrap that part of the widget tree inside `OnReactive` widget:

```dart
final counter1 = RM.inject<int>(()=> 0) // Equivalent to 0.inj();
final counter2 = 0.inj();          // Or: using extension style

int get sum => counter1.state + counter2.state;

// In the widget tree:
Column(
    children: [
        OnReactive( // Will listen to counter1
            ()=> Text('${counter1.state}');
        ),
        OnReactive( // Will listen to counter2
            ()=> Text('${counter2.state}');
        ),
        OnReactive( // Will listen to both counter1 and counter2
            ()=> Text('$sum');
        )
    ]
)
```

Inside `OnReactive` you can call any of the available state status flags (`isWaiting`, `hasError`, `hasData`, ...) or just simply use `onAll` and `onOrElse` methods:

```dart
// Option 1: I do it by myself! 😤
OnReactive(
    ()=> {
        if(myModel.isWaiting){
            return WaitingWidget();
        }
        if(myModel.hasError){
            return ErrorWidget();
        }
        return DataWidget();
    }
)
// Option 2: use onAll method:   (defined all status)
OnReactive(
    ()=> myModel.onAll(
            onWaiting: ()=> WaitingWidget(),
            onError: (err, refreshErr)=> ErrorWidget(),
            onData: (data)=> DataWidget(),
        );
)

// Option 3: use onOrElse method: (expected or undefined status)
OnReactive(
    ()=> myModel.onOrElse(
            onData: (data)=> DataWidget(),
            orElse: ()=> IndicatorWidget(),
        );
)
```

Similar to `OnReactive` widget there is the abstract widget **`ReactiveStatelessWidget`**. When the `ReactiveStatelessWidget` is used instead of `StatelessWidget`, the widget becomes reactive and implicitly tracks its listeners <font color=#008000>**no matter how deep**</font> in the widget tree they are provided that the widget <font color=#c70000>**is not loaded lazily**</font> such as inside the `builder` method of the `ListView.builder` widget:

```dart
class MyWidget extends ReactiveStatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Text('${counter1.state}'),
          Text('${counter2.state}'),
          Text('$sum'),
      ]
    );
  }
}
```

**LIMITATION**: 

`ReactiveStatelessWidget` and` OnReactive` cannot update `const` widgets, widgets inside the` builder` of `ListView.builder` and widgets inside` Slivers`.
```dart
OnReactive(
  ()=> Column(
     children: [
       // const will not update
       const _Widget(), 
       Expanded(
         child: ListView.builder(
           itemCount: 1,
           itemBuilder: (context, index) {
             // Inside builder will not register to OnReactive
             // To make it reactive wrap it with OnReactive
             return _Widget(); 
           },
         ),
       ),
       Expanded(
         child: CustomScrollView(
           slivers: [
             SliverAppBar(
               // Inside SliverAppBar will not register to OnReactive
              // To make it reactive wrap it with OnReactive
               title: _Widget(), 
             ),
             SliverList(
               delegate: SliverChildListDelegate(
                 [
                   // Inside SliverList will not register to OnReactive
                   // To make it reactive wrap it with OnReactive
                   _Widget(), 
                 ],
               ),
             ),
             SliverGrid(
               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 1,
               ),
               delegate: SliverChildBuilderDelegate(
                   (BuildContext context, int index) {
                     // Inside SliverChildBuilderDelegate will not register to OnReactive
                     // To make it reactive wrap it with OnReactive
                     return _Widget();  
                   },
               ),
             ),
           ],
         ),
       ),
     ],
  ),
);
```

- [🔍 See more detailed information about OnReactive API](https://github.com/GIfatahTH/states_rebuilder/wiki/on_reactive_api).

- [**Here is an example demonstrating the basic ideas**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_001_2_flutter_default_counter_app_with_functional_injection).

</br>

### OnBuilder widget

In most cases `OnReactive` do the job. Nevertheless, if you want to explicitly specify the listeners you want to listen to, use `OnBuilder` widget.

```dart
OnBuilder(
    listenTo: myState,
    // Called whenever myState emits a notification
    builder: () => Text('${counter.state}'),
    sideEffects: SideEffects(
        initState: () => print('initState'),
        onSetState: (snapState) => print('onSetState'),
        onAfterBuild: () => print('onAfterBuild'),
        dispose: () => print('dispose'),
    ),
    shouldRebuild: (oldSnap, newSnap) {
      return true;
    },
    debugPrintWhenRebuild: 'myState',
),
```

If you want to listen to many injected states use `listenToMany` parameter.

In this case `onBuilder` will react to a combined state of all injected states.

```dart
OnBuilder.all(
    listenToMany: [myState1, myState2],
    onWaiting: () => Text('onWaiting'), // Will be invoked if at least one state is waiting
    onError: (err, refreshError) => Text('onError'), // Will be invoked if at least on state has error
    onData: (data) => Text(myState.state.toString()), // Will be invoked if all states have data.
),
```

- [🔍 See more detailed information about OnBuilder API](https://github.com/GIfatahTH/states_rebuilder/wiki/on_builder_api).

</br>

> All onError callbacks expose a refresher. It can be used to refresh the error; that is recalling the last function that caused the error.

If you want to optimize widget rebuild and prevent some part of the child widget tree from unnecessary rebuilding, use `Child`, `Child2`, `Child3` widget.

```dart
Child(
  (child) => OnReactive(
      () => Colum(
          children: [
              Text('model.state'), // This part will rebuild
              child, // This part will not rebuild
          ],
      ),
  ),
  child: WidgetNotToRebuild(),
);
```

You can make your state widget-wise and override it to present different branches of the widget tree.

```dart
final items = [1,2,3];

final item = RM.inject(()=>null);

class App extends StatelessWidget{
  build (context){
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return item.inherited( // Inherited uses the `InheritedWidget` concept
          stateOverride: () => items[index],
          builder: () {

            return const ItemWidget();
            // Inside ItemWidget you can use the buildContext to get 
            // the right state for each widget branch using:

            // This Element owner of context is registered to item model.
            item.of(context);

            // Or: this Element owner of context is not registered to item model.
            item(context); 
          }
        );
      },
    );
  }
}
```

- [🔍 See more detailed information about the topic of state widget-wise and InheritedWidget](https://github.com/GIfatahTH/states_rebuilder/wiki/state_widget_wise_api)

## Global and local state

State can be injected globally or scoped locally.

Scoped locally means that the state's flow is encapsulated withing the widget and its children. If more than one widget is created, each has its own independent state.

### Global state

  ```dart
  //In the global scope
  final myState = RM.inject(() => MyState())
  ```

  // Or Encapsulate it inside a business logic class (BLOC):

  ```dart
  //For the sake of best practice, one strives to make the class immutable
  @immutable
  class MyBloc {  // or MyViewModel, or MyController
    final _myState1 = RM.inject(() => MyState1())
    final _myState2 = RM.inject(() => MyState2())
    //Other logic that mutate _myState1 and _myState2
  }
  //As MyBloc is immutable, it is safe to instantiate it globally
  final myBloc = MyBloc();
  ```

### Local state (Scoped state)

  If the state or the Bloc are configurable (parametrized), Just declare  them globally and override the state in the widget tree.

  ```dart
  // The state will be initialized in the widget tree.
  final myState = RM.inject(() => throw UnimplementedError())
  // In the widget tree
  myState.inherited(
    stateOverride: () {
      return MyState(parm1,param2);
    },
    builder: (context) {
      // Read the state through the context
      final _myState = myState.of(context);
    }
  )
  ```

  Similar with Blocs

  ```dart
  final myBloc = RM.inject<MyBloc>(() => throw UnimplementedError())
  //In the widget tree
  myState.inherited(
    stateOverride: () {
      return MyBloc(parm1, param2);
    },
    builder: (context) {
      final _myBloc = myBloc.of(context);
    }
  )
  ```

- [🔍 See more detailed about global and local state with examples](https://github.com/GIfatahTH/states_rebuilder/wiki/global_and_local_state)

## State persistence

To Persist the state and retrieve it when the app restarts,

  ```dart
  final model = RM.inject<MyModel>(
      ()=>MyModel(),
    persist:() => PersistState(
      key: 'modelKey',
      toJson: (MyModel s) => s.toJson(),
      fromJson: (String json) => MyModel.fromJson(json),
      // Optionally, throttle the state persistance
      throttleDelay: 1000,
    ),
  );
  ```

  You can manually persist or delete the state

  ```dart
  model.persistState();
  model.deletePersistState();
  ```

- [🔍 See more detailed information about state persistance](https://github.com/GIfatahTH/states_rebuilder/wiki/state_persistance_api).

- [**Here is an example of state persistence**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_001_3_state_persistence).

</br>

## Undo and redo immutable state

Note: you should first set `undoStackLength:` from RM.inject

  ```dart
  model.undoState();
  model.redoState();
  ```

  [🔍 See more detailed information about undo redo state](https://github.com/GIfatahTH/states_rebuilder/wiki/undo_redo_api).

- [**Here is an example on how to undo and redo the state**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_001_4_undo_redo_state).

</br>

## Route management

**IMPORTANT**
Navigation is extract to its own package: [navigation_builder](https://pub.dev/packages/navigation_builder). it has the same api with minor changes.

Now `states_rebuilder` use `navigation_builder` without any breaking changes compared to previous versions.

To use Navigator version 2,
 ```dart
   final InjectedNavigator myNavigator = RM.injectNavigator(
     // Define your routes map
     routes: {
       '/': (RouteData data) => Home(),
        // redirect all paths that starts with '/home' to '/' path
       '/home/*': (RouteData data) => data.redirectTo('/'),
       '/page1': (RouteData data) => Page1(),
       '/page1/page11': (RouteData data) => Page11(),
       '/page2/:id': (RouteData data) {
         // Extract path parameters from dynamic links
         final id = data.pathParams['id'];
         // OR inside Page2 you can use `context.routeData.pathParams['id']`
         return Page2(id: id);
        },
       '/page3/:kind(all|popular|favorite)': (RouteData data) {
         // Use custom regular expression
         final kind = data.pathParams['kind'];
         return Page3(kind: kind);
        },
       '/page4': (RouteData data) {
         // Extract query parameters from links
         // Ex link is `/page4?age=4`
         final age = data.queryParams['age'];
         // OR inside Page4 you can use `context.routeData.queryParams['age']`
         return Page4(age: age);
        },
        // Using sub routes
        '/page5': (RouteData data) => RouteWidget(
              builder: (Widget routerOutlet) {
                return MyParentWidget(
                  child: routerOutlet;
                  // OR inside MyParentWidget you can use `context.routerOutlet`
                )
              },
              routes: {
                '/': (RouteData data) => Page5(),
                '/page51': (RouteData data) => Page51(),
              },
            ),
     },
     //
     // Called after a location is resolved and just before navigation.
     // It is used for route guarding and global redirection.
     onNavigate: (RouteData data) {
       final toLocation = data.location;
       if (toLocation == '/homePage' && userIsNotSigned) {
         return data.redirectTo('/signInPage');
       }
       if (toLocation == '/signInPage' && userIsSigned) {
         return data.redirectTo('/homePage');
       }
     
       //You can also check query or path parameters
       if (data.queryParams['userId'] == '1') {
         return data.redirectTo('/superUserPage');
       }
     },
     //
     // Called when route is going back.
     // It is used to prevent leaving pages before date is validated
     onNavigateBack: (RouteData data) {
       if(data== null){
         // data is null when the back Button of Android device is hit and the route 
         // stack is empty.

         // returning true we will exit the app.
         // returning false we will stay on the app.
         return false;
       }
       final backFrom = data.location;
       if (backFrom == '/SingInFormPage' && formIsNotSaved) {
         RM.navigate.toDialog(
           AlertDialog(
             content: Text('The form is not saved yet! Do you want to exit?'),
             actions: [
               ElevatedButton(
                 onPressed: () => RM.navigate.forceBack(),
                 child: Text('Yes'),
               ),
               ElevatedButton(
                 onPressed: () => RM.navigate.back(),
                 child: Text('No'),
               ),
             ],
           ),
         );
 
         return false;
       }
     },
   );
 ```

In the widget tree, use `MaterialApp.router` widget: 
  ```dart
  class MyApp extends StatelessWidget {
     const MyApp({Key? key}) : super(key: key);
 
     @override
     Widget build(BuildContext context) {
       return MaterialApp.router(
         routeInformationParser: myNavigator.routeInformationParser,
         routerDelegate: myNavigator.routerDelegate,
       );
     }
   }
  ```

To navigate imperatively:

  ```dart
  myNavigator.to('/page1');
  myNavigator.toDeeply('/page1');
  myNavigator.toReplacement('/page1', argument: 'myArgument');
  myNavigator.toAndRemoveUntil('/page1', queryParam: {'id':'1'});
  myNavigator.back();
  myNavigator.backUntil('/page1');
  ```

To navigate declaratively:

  ```dart
  myNavigator.setRouteStack(
    (pages){
      // exposes a copy of the current route stack
      return [...newPagesList];
    }
  )
  ```

To navigate to pageless routes, show dialogs and snackBars without `BuildContext`:

  ```dart
  myNavigator.toPageless(HomePage());
  RM.navigate.toDialog(AlertDialog( ... ));
  RM.scaffoldShow.snackbar(SnackBar( ... ));
  ```


  > You can easily change page transition animation, using one of the predefined TransitionBuilder or just define yours.


- [🔍 See more detailed information about router](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_navigator_api).

</br>

## Create, Read, Update and Delete items from backend service

- To Create, Read, Update and Delete (CRUD) from backend or DataBase,

  ```dart
  final products = RM.injectCRUD<Product, Param>(
      ()=> MyProductRepository(), // Implements ICRUD<Product, Param>
      readOnInitialization: true, // Optional (Default is false)
  );
  ```

  ```dart
  // READ
  products.crud.read(param: (param)=> NewParam());
  // CREATE
  products.crud.create(NewProduct());
  // UPDATE
  products.crud.update(
    where: (product) => product.id == 1,
    set: (product)=> product.copyWith(...),
  );
  // DELETE
  products.crud.delete(
    where: (product) => product.id == 1,
    isOptimistic: false, // Optional (Default is true)
  );
  ```

  - [🔍 See more detailed information about `InjectCRUD`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_crud_api).

  - [**Here is a working example of a CRUD app**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex005_00_crud_operations).

## Authentication and authorization

To authenticate and authorize users,

  ```dart
  final user = RM.injectAuth<User?, Param>(
      ()=> MyAuthRepository(),// Implements IAuth<User?, Param>
      autoRefreshTokenOrSignOut: (user)=> Duration(seconds: user.tokenExpiryDate)
  );
  ```

  ```dart
  // in the widget tree
  OnAuthBuilder(
    listenTo: user,
    onUnsigned: ()=> LoginPage(),
    onSigned: ()=> UserHomePage(),
  )
  // later on: 
  // Sign up
  user.auth.signUp((param)=> Param());
  // Sign in
  user.auth.signIn((param)=> Param());
  // Sign out
  user.auth.signOut();
  ```

- [🔍 See more detailed information about `InjectAuth`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_auth_api).

- [**Here is a typical auth app**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex006_00_authentication_and_authorization).

## Dynamic theme switching

To dynamically switch themes,

  ```dart
  final theme = RM.injectTheme<String>(
      lightThemes : {
        'simple': ThemeData.light( ... ),
        'solarized': ThemeData.light( ...),
      },
      darkThemes: {
        'simple': ThemeData.dark( ... ),
        'solarized': ThemeData.dark( ...),
      };
      themeMode: ThemeMode.system;
      persistKey: '__theme__',
  );
  ```

  ```dart
  // Choose the theme
  theme.state = 'solarized'
  // Toggle between dark and light mode of the chosen them
  theme.toggle();
  ```

- [🔍 See more detailed information about `InjectedTheme`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_theme_api).

- [**Here is an example on dynamic theming**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_005_theme_switching).

## App internationalization and localization

To internationalize and localize your app:

  ```dart
  // U.S. English
  class EnUS {
    final helloWorld = 'Hello world';
  }
  // Spanish
  class EsEs implements EnUs{
    final helloWorld = 'Hola Mondo';
  }
  ```

  > You can use `json` or `arb` file for language translations.

  ```dart
  final i18n = RM.injectI18N<EnUS>(
      {
        Local('en', 'US'): ()=> EnUS(); // Can be async
        Local('es', 'ES'): ()=> EsES();
      };
      persistKey: '__lang__', // Local persistance of language 
  );
  ```

  In the UI:

  ```dart
  Text(i18n.of(context).helloWorld);
  ```

  ```dart
  // Choose the language
  i18n.locale = Local('es', 'Es');
  // Or: choose the system language
  i18n.locale = SystemLocale();
  ```

- [🔍 See more detailed information about InjectedI18N](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_i18n_api).

- [**Here is an example on app internationalization**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_005_theme_switching).

- [**Here is an example on app internationalization using ARB files**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_005_1_internationalization_using_arb).

</br>

## Animation in StatelessWidget

### Implicit and explicit animation

  ```dart
  final animation = RM.injectAnimation(
    duration: const Duration(seconds: 1),
    curve: Curves.linear,
  );
  ```

  In the UI:
  For Implicit animation

  ```dart
  Center(
    child: OnAnimationBuilder(
        listenTo: animation,
        builder: (animate) => Container(
            // Animate is a callable class
            width: animate.call(selected ? 200.0 : 100.0),
            height: animate(selected ? 100.0 : 200.0, 'height'),
            color: animate(selected ? Colors.red : Colors.blue),
            alignment: animate(selected ? Alignment.center : AlignmentDirectional.topCenter),
            child: const FlutterLogo(size: 75),
        ),
    ),
  ),
  ```

  For explicit animation

  ```dart
  OnAnimationBuilder(
    listenTo: animation,
    builder: (animate) => Transform.rotate(
    angle: animate.formTween(
        (currentValue) => Tween(begin: 0, end: 2 * 3.14),
    )!,
    child: const FlutterLogo(size: 75),
    ),
  ),
  ```

- [🔍 See more detailed information about `InjectedAnimation`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_animation_api).

- [**Here are many show cases of implicit and explicit animation**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_006_3_animation).

</br>

## Working with TextFields and Form validation

To deal with TextFields and Form validation

  ```dart
  final email =  RM.injectTextEditing():

  final password = RM.injectTextEditing(
    validators: [
      (String? value) {
        if (value!.length < 6) {
          return "Password must have at least 6 characters";
        }
        return null;
      },
    ],
  );

    final acceptLicence = RM.injectedFormField(
    validators: [
      (bool? value) {
        if (bool != true) {
          return "You have to accept the licence";
        }
        return null;
      },
    ],
  );

  final form = RM.injectForm(
    autovalidateMode: AutovalidateMode.disable,
    autoFocusOnFirstError: true,
    submit: () async {
      // This is the default submission logic:
      //  1. it may be override when calling form.submit( () async { });
      //  2. it may contains server validation.
      await serverError =  authRepository.signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );
        // After server validation
        if(serverError == 'Invalid-Email'){
          email.error = 'Invalid email';
        }
        if(serverError == 'Weak-Password'){
          email.error = 'Password must have more the 6 characters';
        }
    },
    onSubmitting: () {
      // Called while waiting for form submission,
    },
    onSubmitted: () {
      // Called after form is successfully submitted
      // for example: navigation to user page
    }
  );
  ```

  In the UI:

  ```dart
    OnFormBuilder(
      listenTo: form,
      builder: () => Column(
        children: <Widget>[
            TextField(
                focusNode: email.focusNode,
                controller: email.controller,
                decoration: InputDecoration(
                  errorText: email.error,
                ),
                onSubmitted: (_) {
                  // Request the password node
                  password.focusNode.requestFocus();
                },
            ),
            TextField(
                focusNode: password.focusNode,
                controller: password.controller,
                decoration: new InputDecoration(
                  errorText: password.error,
                ),
                onSubmitted: (_) {
                  // Request the submit button node
                  form.submitFocusNode.requestFocus();
                },
            ),
            OnFormFieldBuilder<bool>(
              listenTo: acceptLicence,
              builder: (value, onChanged){
                return CheckBoxListTile(
                  value: value,
                  onChanged: onChanged,
                  title: Text('Do you accept the licence?'),
                )
              }
            ),
            OnFormSubmissionBuilder(
              listenTo: form,
              onSubmitting: () => CircularProgressIndicator(),
              child : ElevatedButton(
                focusNode: form.submitFocusNode,
                onPressed: (){
                    form.submit();
                },
                child: Text('Submit'),
              ),
            ),     
        ],
      ),
  ),
  ```

- [🔍 See more detailed information about `InjectedTextEditing, InjectedFormField, and InjectedForm`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_text_editing_api).

</br>

## Working with scrollable view

- To work with scrolling list:

  ```dart
  final scroll = RM.injectScrolling(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
    endScrollDelay: 300,
    onScrolling: (scroll){
      if (scroll.hasReachedMinExtent) {
        print('Scrolling vertical list is in its top position');
      }
      if (scroll.hasReachedMaxExtent) {
        print('Scrolling vertical list is in its bottom position');
      }

      if (scroll.hasStartedScrolling) {
        // Called only one time.
        print('User has just start scrolling');
      }
    }
  );
  ```

  In the UI:

  ```dart
  ListView(
      controller: scroll.controller, // Ready to go 🏃‍♀️ 🏃
      children: <Widget>[],
  );
  ```

- [🔍 See more detailed information about `InjectedScrolling`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_scrolling_api).

## Working with page and tab views

- To work with tabs and page views:

  ```dart
    final injectedTab = RM.injectTabPageView(
      initialIndex: 2,
      length: 5,
    );
  ```
  
  In the UI: with the same injectedTab you can control `TabBarView`, `PageView`, `TabBar` and `BottomNavigationBar`.

  ```dart
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: OnTabPageViewBuilder(
                  builder: (index) {
                    return TabBarView(
                      controller: injectedTab.tabController,
                      children: views,
                    );
                  },
                ),
              ),
              Expanded(
                child: OnTabPageViewBuilder(
                  builder: (index) {
                    return PageView(
                      controller: injectedTab.pageController,
                      children: pages,
                    );
                  },
                ),
              )
            ],
          ),
          bottomNavigationBar: OnTabPageViewBuilder(
            listenTo: injectedTab,
            builder: (index) => BottomNavigationBar(
              currentIndex: index,
              onTap: (int index) {
                injectedTab.index = index;
              },
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.blue[100],
              items: tabs
                  .map(
                    (e) => BottomNavigationBarItem(
                      icon: e,
                      label: '$index',
                    ),
                  )
                  .toList(),
            ),
         ),
        ),
      );
  ```

- [🔍 See more detailed information about `InjectedTabPageView`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_tab_page_view_api).

- [**Here are many show cases of tabs and pages**](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/others/ex_006_4_page_and_tab_views).

## Test and injected state mocking

All Injected state can be mocked for test.
To mock it in test:

  ```dart
    model.injectMock(()=> MyMockModel());
    model.injectFutureMock(()=> MyMockModel());
    products.injectCRUDMock(()=> MockRepository())
    user.injectAuthMock(()=> MockAuthRepository())
  ```

And many more features.

</br>

# Examples


With these series of examples you'll learn the core concepts of state_rebuilder using simple simple and incremental examples.

## State management concepts
Get the foundation of state management from very basic to more advanced concepts
* [Sync global and local state management;](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state)
* [Async global and local state management;](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state)
* [Dependent state management](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex003_00_dependent_state_management).

## Navigation
* [Navigation using intuitive facade of Navigator 2 API](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex004_00_navigation)

## Devolvement booster

Based on state management principles and some good programing principles and abstraction techniques, I created dedication injected state to automatize the most repetitive tasks a developer do.

* [Create, Read, Update and delete (CRUD) from a list of items](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex005_00_crud_operations); 
* [Authentication and authorization](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex006_00_authentication_and_authorization);
* [App theme management](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex007_00_app_theme_management);
* [App localization and internationalization](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex008_00_app_i18n_i10n);
* [Animation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex009_00_animation);
* [Form fields and form validation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex010_00_form_fields);
* Working with scrolling list views;
* Pages and tab views;

## Question & Suggestion
* Each example is a seed for a tutorial. It would be very encouraging if you wrote one.
* Please feel free to post an issue or PR, as always, your feedback makes this library become better and better.