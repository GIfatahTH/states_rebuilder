# `states_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)

<p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/Logo-Black.png" width="600" alt=''/>
</p>

A Flutter state management combined with a dependency injection solution to get the best experience with state management. 

- Performance
  - Predictable and controllable state mutation
  - Immutable / Mutable states support
  - Strictly rebuild control
  - Auto clean state when not used

- Code Clean
  - Zero Boilerplate
  - No annotation & code-generation
  - Separation of UI & business logic
  - Achieve business logic in pure Dart.

- User Friendly
  - Built-in dependency injection system
  - `SetState` in StatelessWidget.
  - Hot-pluggable Stream / Futures
  - Easily Undo / Redo
  - Elegant error handling and refreshing
  - Navigate, show dialogs without `BuildContext`
  - Easily persist the state and retrieve it back
  - Override the state for a particular widget tree branch (widget-wise state)

- Production-time-saving
  - Easily CREATE, READ, UPDATE, and DELETE (CRUD) from rest-API or database.
  - Easy user authentication and authorization.
  - Easily app themes management.
  - Simple internalization and localization.

- Maintainable
  - Easy to test, mock the dependencies
  - state tracker middleware
  - Built-in debugging print function
  - Capable for complex apps

<p align="center" >
    <image src="../assets/Poster-Simple.png" width="1280"  alt=''/>
</p>

# Table of Contents <!-- omit in toc --> 
- [Getting Started with States_rebuilder](#getting-started-with-states_rebuilder)
- [Breaking Changes](#breaking-changes)
- [A Quick Tour of states_rebuilder API](#A-Quick-Tour-of-states_rebuilder-API)
  - [Business logic](#business-logic)
  - [UI logic](#ui-logic)
- [Examples:](#examples)
  <!-- - [Basics:](#basics)
  - [Advanced:](#advanced)
    - [Firebase Series:](#firebase-series)
    - [Firestore Series in Todo App:](#firestore-series-in-todo-app) -->

# Getting Started with States_rebuilder
1. Add the latest version to your package's pubspec.yaml file.

2. Import it in any Dart code:
```dart
import 'package:states_rebuilder/states_rebuilder.dart';
```

3. Basic use case:
```dart
// 🗄️Plain Data Class
class Model {
  int counter;

  Model(this.counter);
}  

// 🤔Business Logic - Service Layer
extension ModelX on Model {
  increment() => this.counter++;  
}

// 🚀Global Functional Injection 
// This state will be auto-disposed when no longer used, and also testable and mockable.
final model = RM.inject<Model>(
  () => Model(0), 
  undoStackLength: 8,
  //Called after new state calculation and just before state mutation
  middleSnapState: (MiddleSnapState middleSnap){
    //Log all state transition.
    print(middleSnap.currentSnap);
    print(middleSnap.nextSnap);

    middleSnap.print()//Build-in logger

    //Can return another state
  }
);

// 👀UI  
class CounterApp extends StatelessWidget {
  const CounterApp();
  
  @override
  Widget build(BuildContext context) {
    return Column (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            ElevatedButton(
                child: const Text('🏎️ Counter ++'),
                onPressed: () => model.setState(
                    (s) => s.increment(),
                ),
            ),
            RaisedButton(
                child: const Text('⏱️ Undo'),
                onPressed: () => model.undoState(),
            ),
            On(
              () => Text('🏁Result: ${model.state.counter}'),
            ).listenTo(model),
        ],
    );
  }  
}
```

# Breaking Changes 

### Since 4.0: &nbsp; [Here](https://github.com/GIfatahTH/states_rebuilder/blob/null_safety/states_rebuilder_package/changelog/v-4.0.0.md) 

### Since 3.0: &nbsp; [Here](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-3.0.0.md) 

### Since 2.0: &nbsp; [Here](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-2.0.0.md) 


# A Quick Tour of states_rebuilder API

## Business logic

>The business logic classes are independent from any external library. They are independent even from `states_rebuilder` itself.


The specificity of `states_rebuilder` is that it has practically no boilerplate. It has no boilerplate to the point that you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold for example `onLoading`, `onLoaded`, `onError` states. `states_rebuilder` automatically manages these asynchronous statuses and exposes the `isIdle`,` isWaiting`, `hasError` and` hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic.

>With `states_rebuilder`, you write business logic without bearing in mind how the user interface would interact with it.

This is a typical simple business logic class:
```dart
class Foo { //don't extend any other library specific class
  int mutableState = 0; // the state can be mutable
  //Or
  final int immutableState; // Or it can be immutable (no difference)
  Foo(this.immutableState);

  Future<int> fetchSomeThing async(){
    //No need for any kind of async state tracking variables
    return repository.fetchSomeThing();
    //No need for any kind of notification
  }

  Stream<int> streamSomeThing async*(){
    //Methods can return stream, future, or simple sync objects,
    //states_rebuilder treats them equally
  }
}
```
<!-- <p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/null_safety/assets/01-states_rebuilder__singletons_new.png" width="600" alt='cheat cheet'/>
</p> -->

<p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/null_safety/assets/01-states_rebuilder__singletons_new.png" width="600" alt='cheat cheet'/>
</p>

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
  // middleSnapState as a middleWare place
  // Used to track and log state lifecycle and transitions.
  // It can also be used to return another state created from 
  // the current state and the next state.
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
//For simple injection you can use `inj()` extension:
final foo = Foo().inj<Foo>();
final isBool = false.inj();
final string = 'str'.inj();
final count = 0.inj();
```

`Injected` interface is a wrapper class that encloses the state we want to inject. The state can be mutable or immutable.

Injected state can be instantiated globally or as a member of classes. They can be instantiated inside the build method without losing the state after rebuilds.

>To inject a state, you use `RM.inject`, `RM.injectFuture`, `RM.injectStream` or `RM.injectFlavor`.

**The injected state even if it is injected globally it has a lifecycle**. It is created when first used and destroyed when no longer used. Between the creation and the destruction of the state, it can be listened to and mutated to notify its registered listeners.

**The state of an injected model is null safe**, that is it can not be null. For this reason, the initial state will be inferred by the library, and in case it is not, it must be defined explicitly. The initial state of primitives is inferred as follows: (**int: 0, double, 0.0, String:'', and bool: false**). For other non-primitive objects, the initial state will be the first created instance.

**When the state is disposed of, its list of listeners is cleared**, and if the state is waiting for a Future or subscribed to a Stream, it will cancel them to free resources.

**Injected state can depend on other Injected states** and recalculate its state and notify its listeners whenever any of its of the Inject model that it depends on emits a notification.

  [🗎 See more detailed information about the RM.injected API](https://github.com/GIfatahTH/states_rebuilder/wiki/rm_injected_api).


To mutate the state and notify listener:
```dart
//Inside any callback: 
foo.state= newFoo;
//Or for more options

foo.setState(
  (s) => s.fetchSomeThing(),
  onSetState: On.waiting(()=> showSnackBar() ),
  debounceDelay : 400,
)

//if state is bool
foo.toggle();
```




<!-- <p align="center">
    <image src="https://github.com/GIfatahTH/states_rebuilder/raw/master/assets/01-states_rebuilder_state_wheel.png" width="400" alt=''/>
</p> -->

The state when mutated emits a notification to its registered listeners. The emitted notification has a boolean flag to describe is status :
  - `isIdle` : the state is first created and no notification is emitted yet.
  - `isWaiting`: the state is waiting for an async task to end.
  - `hasError`: the state mutation has ended with an error.
  - `hasData`: the state mutation has ended with valid data.

states_rebuilder offers callbacks to handle the state status change. The state status callbacks are conveniently defined using the `On` class with its named constructor alternatives: 
```dart
// Called when notified regardless of state status of the notification
On(()=> print('on'));
// Called when notified with data status
On.data(()=> print('data'));
// Called when notified with waiting status
On.waiting(()=> print('waiting'));
// Called when notified with error status
On.error((err, refresh)=> print('error'));
// Exhaustively handle all four status
On.all(
  onIdle: ()=> print('Idle'), // If is Idle
  onWaiting: ()=> print('Waiting'), // If is waiting
  onError: (err, refresh)=> print('Error'), // If has error 
  onData:  ()=> print('Data'), // If has Data
)
// Optionally handle the four status
On.or(
  onWaiting: ()=> print('Waiting'),
  onError: (err, refresh)=> print('Error'),
  onData:  ()=> print('Data'),
  or: () =>  print('or')
)

//Used to listen to a future.
On.future<F>(
    onWaiting: ()=> Text('Waiting..'),
    onError: (error, refresher) => Text('Error'),//Future can be reinvoked
    onData: (data)=> MyWidget(),
).future(()=> anyKindOfFuture);

//This widget subscribes to the `stateAsync` of the injected model.
//This is a one-time subscription of the `onWaiting` and `onError` and 
//ongoing subscription of `onData`
On.future<F>(
    onWaiting: ()=> Text('Waiting..'),//One-time subscription
    //On error, future can be reinvoked
    onError: (error, refresher) => Text('Error'),//One-time subscription
    onData: (data)=> MyWidget(),//Ongoing subscription
).listenTo(model);

///Used with injectedCRUD. It watches the state of the backend service
On.crud(
    onWaiting: ()=> Text('Waiting..'),//The querying is ongoing
    onError: (error, refresh) => Text('Error'),// The querying fails
    onResult: (result)=> MyWidget(),// The querying succeeds
).listenTo(injectedCRUD);

///Used with injectedAuth. It displays the right page depending on 
//the signed user
On.auth(
    onWaiting: ()=> Text('Waiting..'),
    onUnsigned: ()=> AuthPage(),
    onSigned: ()=> HomeUserPage(),
).listenTo(injectedAuth);
```

> All onError callbacks expose a refresher. It can be use to refresh the error; that is recalling the last  function that caused the error.


  [🗎 See more detailed information about the RM.injected API](https://github.com/GIfatahTH/states_rebuilder/wiki/set_state_api).

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



## UI logic

* To listen to an injected state from the User Interface:
  - For general use and full options use:
    ````dart
    On.all(
        onIdle: ()=> Text('Idle'),
        onWaiting: ()=> Text('Waiting'),
        onError: (err, refresh)=> Text('Error'),
        onData:  ()=> Text('Data'),
    ).listenTo(
      foo, //Listen to foo state
      //called once the widget is inserted
      initState: ()=> print('initState'),
      //called once the widget is removed
      dispose: ()=> print('dispose'),
      //called after notification and before rebuild
      onSetState: On.error((err) => print('error')),
      //called after notification and rebuild
      onAfterBuild: On(()=> print('After build')),
    )
    ```
  - Rebuild when model has data only:
    ```dart
    // Equivalent to On.data
    foo.rebuilder(()=> Text('${model.state}')); 
    ```
  - Handle all possible async status:
    ```dart
    // Equivalent to On.all
    foo.whenRebuilder(
        isIdle: ()=> Text('Idle'),
        isWaiting: ()=> Text('Waiting'),
        hasError: ()=> Text('Error'),
        hasData: ()=> Text('Data'),
    )
    ```
  - Listen to a future from `foo` and notify this widget only.
    ```dart
      foo.futureBuilder<T>(
        future: (state, stateAsync)=> state.fetchSomeThing(),
        onWaiting: ()=> Text('Waiting..'),
        onError: (err) => Text('Error'),
        onData: (T data) => Text(data),
      )
    ```
  - Listen to a stream from `foo` and notify this widget only.
    ```dart
      foo.streamBuilder<T>(
        stream: (state, subscription)=> state.streamSomeThing(),
        onWaiting: ()=> Text('Waiting..'),
        onError: (err) => Text('Error'),
        onData: (T data) => Text(data),
        onDone: ()=> Text('Done'),
      )
    ```

* To listen to many injected models and expose a merged state:
  ```dart
    OnCombined.all(
        isWaiting: ()=> Text('Waiting'),//If any is waiting
        hasError: (err, refresh)=> Text('Error'),//If any has error
        isIdle: ()=> Text('Idle'),//If any is Idle
        hasData: (data)=> Text('Data'),//If all have Data
    ).listenTo([model1, model1 ..., modelN]);
  ```
  [🗎 See more detailed information about the widget listeners](https://github.com/GIfatahTH/states_rebuilder/wiki/widget_listener_api).

* To undo and redo immutable state:
  ```dart
  model.undoState();
  model.redoState();
  ```
  [🗎 See more detailed information about undo redo state](https://github.com/GIfatahTH/states_rebuilder/wiki/undo_redo_api).


* To navigate, show dialogs and snackBars without `BuildContext`:
  ```dart
  RM.navigate.to(HomePage());

  RM.navigate.to('/namePage');

  RM.navigate.toDialog(AlertDialog( ... ));

  RM.scaffoldShow.snackbar(SnackBar( ... ));
  ```
  > You can easily change page transition animation, using one of the predefined TransitionBuilder or just define yours.

  [🗎 See more detailed information about side effects without `BuildContext`](https://github.com/GIfatahTH/states_rebuilder/wiki/navigation_dialog_scaffold_without_BuildContext_api).

* To Persist the state and retrieve it when the app restarts,
  ```dart
  final model = RM.inject<MyModel>(
      ()=>MyModel(),
    persist:() => PersistState(
      key: 'modelKey',
      toJson: (MyModel s) => s.toJson(),
      fromJson: (String json) => MyModel.fromJson(json),
      //Optionally, throttle the state persistance
      throttleDelay: 1000,
    ),
  );
  ```
  You can manually persist or delete the state
  ```dart
  model.persistState();
  model.deletePersistState();
  ```
  [🗎 See more detailed information about state persistance](https://github.com/GIfatahTH/states_rebuilder/wiki/state_persistance_api).

* To Create, Read, Update and Delete (CRUD) from backend or DataBase,
  ```dart
  final products = RM.injectCRUD<Product, Param>(
      ()=> MyProductRepository(),//Implements ICRUD<Product, Param>
      readOnInitialization: true,// Optional (Default is false)
  );
  ```

  ```dart
  //READ
  products.crud.read(param: (param)=> NewParam());
  //CREATE
  products.crud.create(NewProduct());
  //UPDATE
  products.crud.update(
    where: (product) => product.id == 1,
    set: (product)=> product.copyWith(...),
  );
  //DELETE
  products.crud.delete(
    where: (product) => product.id == 1,
    isOptimistic: false, // Optional (Default is true)
  );
  ```

  [🗎 See more detailed information about `InjectCRUD`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_crud_api).

* To authenticate and authorize users,
  ```dart
  final user = RM.injectAuth<User, Param>(
      ()=> MyAuthRepository(),//Implements IAuth<User, Param>
      unSignedUser: UnsignedUser(),
      onSigned: (user)=> //Navigate to home page,
      onUnsigned: ()=> //navigate to Auth Page,
      autoSignOut: (user)=> Duration(seconds: user.tokenExpiryDate)
  );
  ```

  ```dart
  //Sign up
  user.auth.signUp((param)=> Param());
  //Sign in
  user.auth.signIn((param)=> Param());
  //Sign out
  user.auth.signOut();
  ```

  [🗎 See more detailed information about `InjectAuth`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_auth_api).


* Widget-wise state (overriding the state):
```dart
final items = [1,2,3];

final item = RM.inject(()=>null);

class App extends StatelessWidget{
  build (context){
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return item.inherited( //inherited uses the InheritedWidget concept
          stateOverride: () => items[index],
          builder: () {

            return const ItemWidget();
            //Inside ItemWidget you can use the buildContext to get 
            //the right state for each widget branch using:
            item.of(context); //the Element owner of context is registered to item model.
            //or
            item(context) //the Element owner of context is not registered to item model.
          }
        );
      },
    );
  }
}
```
  [🗎 See more detailed information about the topic of state widget-wise and InheritedWidget](https://github.com/GIfatahTH/states_rebuilder/wiki/state_widget_wise_api).

* To dynamically switch themes,
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
  //choose the theme
  theme.state = 'solarized'
  //toggle between dark and light mode of the chosen them
  theme.toggle();
  ```

  [🗎 See more detailed information about `InjectedTheme`](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_theme_api).

* To internationalize and localize your app:
  ```dart
  //US english
  class EnUS {
    final helloWorld = 'Hello world';
  }
  //Spanish
  class EsEs implements EnUs{
    final helloWorld = 'Hola Mondo';
  }
  ```
  ```dart
  final i18n = RM.injectI18N<EnUS>(
      {
        Local('en', 'US'): ()=> EnUS();//can be async
        Local('es', 'ES'): ()=> EsES();
      };
      persistKey: '__lang__', //local persistance of language 
  );
  ```
  In the UI:
  ```dart
  Text(i18n.of(context).helloWorld);
  ```

  ```dart
  //choose the language
  i18n.locale = Local('es', 'Es');
  //Or choose the system language
  i18n.locale = SystemLocale();
  ```

  [🗎 See more detailed information about InjectedI18N](https://github.com/GIfatahTH/states_rebuilder/wiki/injected_i18n_api).

* To mock it in test:
  ```dart
    // You can even mock the mocked implementation
    model.injectMock(()=> MyMockModel());
  ```
  Similar to `RM.inject` there are:
  ```dart
  RM.injectFuture  // For Future, 
  RM.injectStream, // For Stream,
  RM.injectFlavor  // For flavor and development environment
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

* [**The simplest counter app**](examples/ex_001_2_flutter_default_counter_app_with_functional_injection): Default flutter counter app refactored using `states_rebuilder`. 

* [**Login form validation**](examples/ex_002_2_form_validation_with_reactive_model_with_functional_injection): Simple form login validation. The basic `Injected` concepts are put into practice to make form validation one of the easiest tasks in the world. The concept of exposed model is explained here.

* [**CountDown timer**](examples/ex_004_2_countdown_timer_with_functional_injection). This is a timer that ticks from 60 and down to 0. It can be paused, resumed or restarted.

* [**Theming and internationalization**](examples/ex_005_theme_switching). This is a demonstration how to handle theme switching and app internationalization using `RM.injectedTheme `and `RM.injectedI18N`.

* [**CRUD query**](examples/ex_006_1_crud_app). This is an example of a backend service fetching data app. The app performs CRUD operation using `RM.injectCRUD`.

* [**Infinite scroll listView**](examples/ex_006_2_infinite_scroll_list). This is another example of CRUD operation using `RM.injectCRUD`. More items will be fetched when the list reaches its bottom.


</br>

## Advanced:
Here, you will take your programming skills up a notch, deep dive in Architecture 🧐:

* [**User posts and comments**](examples/ex_007_2_clean_architecture_dane_mackier_app_with_fi):  The app communicates with the JSONPlaceholder API, gets a User profile from the login using the ID entered. Fetches and shows the Posts on the home view and shows post details with an additional fetch to show the comments.

<!-- * [**GitHub use search app**](examples/ex_011_github_search_app) The app will search for github users matching the input query. The query will be debounced by 500 milliseconds. -->
<!--  -->
### Firebase Series:

* [**Firebase login** ](examples/ex_008_clean_architecture_firebase_login)The app uses firebase for sign in. The user can sign in anonymously, with google account, with apple account or with email and password.
<!-- 
* [**Firebase Realtime Database**](examples/ex_010_clean_architecture_multi_counter_realtime_firebase) The app add, update, delete a list of counters from firebase realtime database. The app is built with two flavors one for production using firebase and the other for test using fake data base. -->

### Firestore Series in Todo App:

[TODOS MVC app](https://github.com/GIfatahTH/states_rebuilder/blob/master/examples/ex_009_1_4_ca_todo_mvc_with_state_persistence_and_user_auth) The same examples as above adding the possibility for a user to sin up and log in. A user will only see their own todos. The log in will be made with a token which, once expired, the user will be automatically disconnected.

<!-- ## <p align='center'>`Immutable State`</p> omit in toc  -->

<!-- * [**Todo MVC with immutable state and firebase cloud service**](examples/ex_009_1_2_ca_todo_mvc_cloud_firestore_immutable_with_fi) : This is an implementation of the TodoMVC using states_rebuild, firebase cloud service as backend and firebase auth service for user authentication. This is a good example of immutable state management.
## <p align='center'>`Mutable State`</p> <!-- omit in toc --> 

<!-- * [**Todo MVC with mutable state and sharedPreferences for persistence**](examples/ex_009_2_2_ca_todo_mvc_mutable_with_fi) : This is the same Todos app but using mutable state and sharedPreferences to locally persist todos. In this demo app, you will see an example of asynchronous dependency injection.


## <p align='center'>`Code in BLOC Style`</p> <!-- omit in toc --> 

* [**Todo MVC following flutter_bloc library approach **](examples/ex_009_3_2_todo_mvc_the_flutter_bloc_way_with_fi)  This is the same Todos App built following the same approach as in flutter_bloc library. --> -->


</br>
Note that all of the above examples are tested. With `states_rebuilder`, testing your business logic is the simplest part of your coding time as it is made up of simple dart classes. On the other hand, testing widgets is no less easy, because with `states_rebuilder` you can isolate the widget under test and mock its dependencies.**



