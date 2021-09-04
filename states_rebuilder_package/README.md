

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
- [A Quick Tour of states_rebuilder API](#a-quick-tour-of-states_rebuilder-api)
  - [Business logic and state injection](#business-logic-and-state-injection)
  - [State change and notification](#state-change-and-notification)
  - [State subscription and Reactive Builders](#state-subscription-and-reactive-builders)
    - [OnReactive Builder](#onreactive-builder)
    - [OnBuilder Builder](#onbuilder-builder)
  - [State persistence](#state-persistence)
  - [Undo and redo immutable state](#undo-and-redo-immutable-state)
  - [Route management](#route-management)
  - [Create, Read, Update and Delete items from backend service](#create-read-update-and-delete-items-from-backend-service)
  - [Authentication and authorization](#authentication-and-authorization)
  - [Dynamic theme switching](#dynamic-theme-switching)
  - [App internationalization](#app-internationalization)
  - [Animation in StatelessWidget:](#animation-in-statelesswidget)
    - [Implicit and explicit animation](#implicit-and-explicit-animation)
  - [Working with TextFields and Form validation](#working-with-textfields-and-form-validation)
  - [Working with scrollable view](#working-with-scrollable-view)
  - [Working with page and tab views](#working-with-page-and-tab-views)
  - [Test and injected state mocking](#test-and-injected-state-mocking)
- [Examples:](#examples)
  - [Basics:](#basics)
  - [Advanced:](#advanced)
    - [Firebase Series:](#firebase-series)
    - [Firestore Series in Todo App:](#firestore-series-in-todo-app)

  <!-- - [Basics:](#basics)
  - [Advanced:](#advanced)
    - [Firebase Series:](#firebase-series)
    - [Firestore Series in Todo App:](#firestore-series-in-todo-app) -->

</br>

# Getting Started with States_rebuilder
1. Install this package:
* With Flutter:
```
 $ flutter pub add states_rebuilder
```
* Or: add into your pubspec.yaml:
```yaml 
  dependencies:
    states_rebuilder: ... 
```

1. Import it in any Dart code:
```dart
import 'package:states_rebuilder/states_rebuilder.dart';
```

3. Basic use case:
```dart
/* -------------  🗄️ Plain Data Class ------------- */
class Counter {
  final int value;
  Counter(this.value);
  @override
  String toString() {
    return 'Counter($value)';
  }
}

/* --------------  🤔 Business Logic -------------- */
//🚀 It is immutable
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
/// NOTE: As [ViewModel] is immutable and final, it is safe to globally instantiate it.

//🚀 The state of counter1 and counter2 will be auto-disposed when no longer in use.
// They are testable and mockable.
final viewModel = ViewModel();


/* --------------------  👀 UI -------------------- */
///🚀 Just use [ReactiveStatelessWidget] widget instead of StatelessWidget.

// CounterApp will automatically register in any state consumed in its widget child 
// branch, regardless of its depth, provided the widget is not lazily loaded as 
// in the builder method of the ListView.builder widget. 
class CounterApp extends ReactiveStatelessWidget {
  const CounterApp();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Counter1View(),
        const Counter2View(),
        Text('🏁 Result: ${viewModel.sum}'), // Will be updated when sum changes
      ],
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

// Child 2 - Plain StatelessWidget
class Counter2View extends StatelessWidget {
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
| **4.0**          | ✅  Least version    | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-4.0.0.md) |
| **3.0**          | Legacy (2020-09-04) | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-3.0.0.md) |
| **2.0**          | Legacy (2020-06-02) | [Doc](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-2.0.0.md) |

* Use of modern version is recommended for getting maximum performance & development experience with **flutter 2.0**.

</br>

# A Quick Tour of states_rebuilder API

## Business logic and state injection

>Business logic classes are independent from any external library. They are independent even from `states_rebuilder` itself.


The specificity of `states_rebuilder` is that it has practically no boilerplate. It has no boilerplate to the point where you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold for example `onLoading`, `onLoaded`, `onError` states. `states_rebuilder` automatically manages these asynchronous statuses and exposes the `isIdle`,` isWaiting`, `hasError` and` hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic.

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
<!-- <p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/01-states_rebuilder__singletons_new.png" width="600" alt='cheat cheet'/>
</p> -->


To make the `Foo` object reactive, we simply inject it using global functional injection:

```dart
final Injected<Foo> foo = RM.inject<Foo>(
  ()=> Foo(),
  onInitialized : (Foo state) => print('Initialized'),
  // Default callbacks for side effects.
  onSetState: On.all(
    onIdle: () => print('Is idle'),
    onWaiting: () => print('Is waiting'),
    onError: (error) => print('Has error'),
    onData: (Foo data) => print('Has data'),
  ),
  // It is disposed when no longer needed
  onDisposed: (Foo state) => print('Disposed'),
  // To persist the state
  persist:() => PersistState(
      key: '__FooKey__',
      toJson: (Foo s) => s.toJson(),
      fromJson: (String json) => Foo.fromJson(json),
      // Optionally, throttle the state persistance
      throttleDelay: 1000,
  ),

  // middleSnapState as a middleWare place used to 
  // track and log state lifecycle and transitions.
  // It can also be used to return another state created 
  // from the current state and the next state.
  middleSnapState: (middleSnap) {
     middleSnap.print(); //Build-in logger
    
    // Example of simple email validation
    if (middleSnap.nextSnap.hasData) {
      if (!middleSnap.nextSnap.data.contains('@')) {
        return middleSnap.nextSnap.copyToHasError(
          Exception('Enter a valid Email'),
        );
      }
    }
  },
);
// For simple injection you can use `inj()` extension:
final foo = Foo().inj<Foo>();
final isBool = false.inj();
final string = 'str'.inj();
final count = 0.inj();
```

`Injected` interface is a wrapper class that encloses the state we want to inject. The state can be mutable or immutable.

Injected state can be instantiated globally or as a member of classes. They can be instantiated inside the build method without losing the state after rebuilds.

>To inject a state, you use `RM.inject`, `RM.injectFuture`, `RM.injectStream` or `RM.injectFlavor`.

**The injected state even if it is injected globally, it has a lifecycle**. It is created when first used and destroyed when no longer used. Between the creation and the destruction of the state, it can be listened to and mutated to notify its registered listeners.

**When the state is disposed of, its list of listeners is cleared**, and if the state is waiting for a Future or subscribed to a Stream, it will cancel them to free resources.

**Injected state can depend on other Injected states** and recalculate its state and notify its listeners whenever any of its Inject model that it depends on emits a notification.

  [🗎 See more detailed information about the RM.injected API](https://github.com/GIfatahTH/states_rebuilder/wiki/rm_injected_api).

## State change and notification

To mutate the state and notify to listener(s):
```dart
// Set state inside any callback: 
foo.state = newFoo;

// For more options
foo.setState(
  (s) => s.fetchSomeThing(),
  // Run `side-effect` during setState
  onSetState: On.waiting(()=> showSnackBar()),
  debounceDelay : 400,
);

// For boolean type state
foo.toggle();
```

<!-- <p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/01-states_rebuilder_state_wheel.png" width="400" alt=''/>
</p> -->

The state when mutated emits a notification to its registered listeners. The emitted notification has a boolean flag to describe is status :
  - `isIdle` : the state was first created and no notification has been emitted yet.
  - `isWaiting`: the state is waiting for an async task to end.
  - `hasError`: the state mutation has ended with an error.
  - `hasData`: the state mutation has ended with valid data.
  - `isActive`: the state had data at least one time.


  [🗎 See more detailed information about  setState API](https://github.com/GIfatahTH/states_rebuilder/wiki/set_state_api).

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

 [🗎 See more detailed information about the refresh API](https://github.com/GIfatahTH/states_rebuilder/wiki/refresh_api).


## State subscription and Reactive Builders
There are <span style="color:#20a844">**two ways**</span> to for get your widget rebuilds by state:
| Widget Builders | Style                       | Link                                 |
| --------------- | --------------------------- | ------------------------------------ |
| `OnReactive`, `ReactiveStatelessWidget`    | 👩🏻‍💻 By default                | [Finish him!](#onreactive-builder)   |
| `OnBuilder`     | 👨🏻‍🚒 Strictly to target widget | [Get Over Here!](#onbuilder-builder) |

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

Similar to `OnReactive` widget there is the abstract widget **`ReactiveStatelessWidget`**. When the `ReactiveStatelessWidget` is used instead of `StatelessWidget`, the widget becomes reactive and implicitly tracks its listeners <span style="color:#20a844">**no matter how deep**</span> in the widget tree they are provided that the widget <span style="color:#c70000">**is not loaded lazily**</span> such as inside the `builder` method of the `ListView.builder` widget:

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

  * [🗎 See more detailed information about OnReactive API](https://github.com/GIfatahTH/states_rebuilder/wiki/on_reactive_api).

  * [**Here is an example demonstrating the basic ideas**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_001_2_flutter_default_counter_app_with_functional_injection). 

</br>

###  OnBuilder Builder

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

  * [🗎 See more detailed information about OnBuilder API](https://github.com/GIfatahTH/states_rebuilder/wiki/on_builder_api).

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
  * [🗎 See more detailed information about the topic of state widget-wise and InheritedWidget](https://github.com/GIfatahTH/states_rebuilder/wiki/state_widget_wise_api)

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
  * [🗎 See more detailed information about state persistance](https://github.com/GIfatahTH/states_rebuilder/wiki/state_persistance_api).

  * [**Here is an example of state persistence**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_001_3_state_persistence).

</br>

## Undo and redo immutable state

Note: you should first set `undoStackLength:` from RM.inject
  ```dart
  model.undoState();
  model.redoState();
  ```
  [🗎 See more detailed information about undo redo state](https://github.com/GIfatahTH/states_rebuilder/wiki/undo_redo_api).

  * [**Here is an example on how to undo and redo the state**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_001_4_undo_redo_state).

</br>

## Route management

To navigate, show dialogs and snackBars without `BuildContext`:
  ```dart
  RM.navigate.to(HomePage());

  RM.navigate.to('/namePage');

  RM.navigate.toDialog(AlertDialog( ... ));

  RM.scaffoldShow.snackbar(SnackBar( ... ));
  ```
  > You can easily change page transition animation, using one of the predefined TransitionBuilder or just define yours.

  You can use dynamic segments with named routing

  ```dart
    return MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        onGenerateRoute: RM.navigate.onGenerateRoute({
          '/': (_) => LoginPage(),
          '/posts': (_) => RouteWidget(
                routes: {
                  '/:author': (RouteData data) {
                      final queryParams = data.queryParams;
                      final pathParams = data.pathParams;
                      final arguments = data.arguments;
                      
                      // Or:
                      // Inside a child widget of AuthorWidget :
                      //
                      // context.routeQueryParams;
                      // context.routePathParams;
                      // context.routeArguments;
                      
                      return  AuthorWidget();

                  },
                  '/postDetails': (_) => PostDetailsWidget(),
                },
              ),
          '/settings': (_) => SettingsPage(),
        }),
      );
  ```

  In the UI:
  ```dart
    RM.navigate.to('/'); // => renders LoginPage()
    RM.navigate.to('/posts'); // => 404 error
    RM.navigate.to('/posts/foo'); // => renders AuthorWidget(), with pathParams = {'author' : 'foo' }
    RM.navigate.to('/posts/postDetails'); // => renders PostDetailsWidget(),

    // If you are in AuthorWidget you can use relative path (name without the back slash at the beginning)
    RM.navigate.to('postDetails'); // => renders PostDetailsWidget(),
    RM.navigate.to('postDetails', queryParams : {'postId': '1'}); // => renders PostDetailsWidget(),
  ```
    
  * [🗎 See more detailed information about router](https://github.com/GIfatahTH/states_rebuilder/wiki/navigation_dialog_scaffold_without_BuildContext_api).

</br>

## Create, Read, Update and Delete items from backend service

* To Create, Read, Update and Delete (CRUD) from backend or DataBase,
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

  * [🗎 See more detailed information about `InjectCRUD`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_crud_api).

  * [**Here is a working example of a CRUD app**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_006_1_crud_app).

## Authentication and authorization

To authenticate and authorize users,
  ```dart
  final user = RM.injectAuth<User, Param>(
      ()=> MyAuthRepository(),// Implements IAuth<User, Param>
      unSignedUser: UnsignedUser(), // If null-safety it's `null`
      onSigned: (user)=> // Navigate to home page,
      onUnsigned: ()=> // Navigate to Auth Page,
      autoSignOut: (user)=> Duration(seconds: user.tokenExpiryDate)
  );
  ```

  ```dart
  // Sign up
  user.auth.signUp((param)=> Param());
  // Sign in
  user.auth.signIn((param)=> Param());
  // Sign out
  user.auth.signOut();
  ```

  * [🗎 See more detailed information about `InjectAuth`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_auth_api).

  * [**Here is a typical auth app**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_008_clean_architecture_firebase_login).

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

  * [🗎 See more detailed information about `InjectedTheme`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_theme_api).

  * [**Here is an example on dynamic theming**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_005_theme_switching).

## App internationalization

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

  * [🗎 See more detailed information about InjectedI18N](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_i18n_api).

  * [**Here is an example on app internationalization**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_005_theme_switching).

</br>

## Animation in StatelessWidget:
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

  * [🗎 See more detailed information about `InjectedAnimation`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_animation_api).

  * [**Here are many show cases of implicit and explicit animation**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_006_3_animation).

</br>

## Working with TextFields and Form validation

To deal with TextFields and Form validation
  ```dart
  final email =  RM.injectTextEditing():

  final password = RM.injectTextEditing(
    validator: (String? value) {
      if (value!.length < 6) {
        return "Password must have at least 6 characters";
      }
      return null;
    },
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
  * [🗎 See more detailed information about `InjectedTextEditing and InjectedForm`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_text_editing_api).

</br>

## Working with scrollable view

  * To work with scrolling list:
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

  * [🗎 See more detailed information about `InjectedScrolling`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_scrolling_api).


## Working with page and tab views
  <!-- //TODO to be added -->


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

# Examples:

<!-- * [**States_rebuilder from A to Z using global functional injection**](https://github.com/GIfatahTH/states_rebuilder/wiki/00-functional_injection) -->

<!-- * Here are three **must-read examples** that detail the concepts of states_rebuilder with global functional injection and highlight where states_rebuilder shines compared to existing state management solutions.

  1. [Example 1](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_000_hello_world). Hello world app. It gives you the most important feature simply by say hello world.
  2. [Example 2](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_009_1_3_ca_todo_mvc_with_state_persistence). TODO MVC example based on the [Flutter architecture examples](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md) extended to account for dynamic theming and app localization. The state will be persisted locally using Hive, SharedPreferences, and Sqflite.
  3. [Example 3](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_009_1_4_ca_todo_mvc_with_state_persistence_and_user_auth) The same examples as above adding the possibility for a user to sin up and log in. A user will only see their own todos. The log in will be made with a token which, once expired, the user will be automatically disconnected. -->

## Basics:
Since you are new to `states_rebuilder`, this is the right place for you to explore. The order below is tailor-made for you 😃:

* [**Hello world app**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_000_hello_world): Hello world app. It gives you the most important feature simply by say hello world. You will understand the concept of global function injection and how to make a pure dart class reactive. You will see how an injected state can depends on other injected state to be refreshed when the other injected state emits notification.

* [**The simplest counter app**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_001_2_flutter_default_counter_app_with_functional_injection): Default flutter counter app refactored using `states_rebuilder`. 

* [**Login form validation**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_002_2_form_validation_with_reactive_model_with_functional_injection): Simple form login validation. The basic `Injected` concepts are put into practice to make form validation one of the easiest tasks in the world. The concept of exposed model is explained here.

* [**CountDown timer**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_004_2_countdown_timer_with_functional_injection). This is a timer that ticks from 60 and down to 0. It can be paused, resumed or restarted.

* [**Theming and internationalization**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_005_theme_switching). This is a demonstration how to handle theme switching and app internationalization using `RM.injectedTheme `and `RM.injectedI18N`.

* [**CRUD query**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_006_1_crud_app). This is an example of a backend service fetching data app. The app performs CRUD operation using `RM.injectCRUD`.

* [**Infinite scroll listView**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_006_2_infinite_scroll_list). This is another example of CRUD operation using `RM.injectCRUD`. More items will be fetched when the list reaches its bottom.


</br>

## Advanced:
Here, you will take your programming skills up a notch, deep dive in Architecture 🧐:

* [**User posts and comments**](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_007_2_clean_architecture_dane_mackier_app_with_fi):  The app communicates with the JSONPlaceholder API, gets a User profile from the login using the ID entered. Fetches and shows the Posts on the home view and shows post details with an additional fetch to show the comments.

<!-- * [**GitHub use search app**](examples/ex_011_github_search_app) The app will search for github users matching the input query. The query will be debounced by 500 milliseconds. -->
<!--  -->
### Firebase Series:

* [**Firebase login** ](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_008_clean_architecture_firebase_login)The app uses firebase for sign in. The user can sign in anonymously, with google account, with apple account or with email and password.
<!-- 
* [**Firebase Realtime Database**](examples/ex_010_clean_architecture_multi_counter_realtime_firebase) The app add, update, delete a list of counters from firebase realtime database. The app is built with two flavors one for production using firebase and the other for test using fake data base. -->

### Firestore Series in Todo App:

[TODOS MVC app](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_009_1_4_ca_todo_mvc_with_state_persistence_and_user_auth) The same examples as above adding the possibility for a user to sin up and log in. A user will only see their own todos. The log in will be made with a token which, once expired, the user will be automatically disconnected.

<!-- ## <p align='center'>`Immutable State`</p> omit in toc  -->

<!-- * [**Todo MVC with immutable state and firebase cloud service**](examples/ex_009_1_2_ca_todo_mvc_cloud_firestore_immutable_with_fi) : This is an implementation of the TodoMVC using states_rebuild, firebase cloud service as backend and firebase auth service for user authentication. This is a good example of immutable state management.
## <p align='center'>`Mutable State`</p> <!-- omit in toc --> 

<!-- * [**Todo MVC with mutable state and sharedPreferences for persistence**](examples/ex_009_2_2_ca_todo_mvc_mutable_with_fi) : This is the same Todos app but using mutable state and sharedPreferences to locally persist todos. In this demo app, you will see an example of asynchronous dependency injection.


## <p align='center'>`Code in BLOC Style`</p> <!-- omit in toc --> 
<!-- 
* [**Todo MVC following flutter_bloc library approach **](examples/ex_009_3_2_todo_mvc_the_flutter_bloc_way_with_fi)  This is the same Todos App built following the same approach as in flutter_bloc library. --> --> -->


</br>
Note that all of the above examples are tested. With `states_rebuilder`, testing your business logic is the simplest part of your coding time as it is made up of simple dart classes. On the other hand, testing widgets is no less easy, because with `states_rebuilder` you can isolate the widget under test and mock its dependencies.**