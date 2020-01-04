# `states_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)

A Flutter state management combined with dependency injection solution that allows : 
  * a 100% separation of User Interface (UI) representation from your logic classes
  * an easy control on how your widgets rebuild to reflect the actual state of your application.
Model classes are simple vanilla dart classes without any need for inheritance, notification, streams or annotation and code generation.


`states_rebuilder` is built on the observer pattern for state management and on the service locator pattern for dependency injection.

> **Intent of observer pattern**    
>Define a one-to-many dependency between objects so that when one object changes state (observable object), all its dependents (observer objects) are notified and updated automatically.

>**Intent of service locator pattern**   
>The purpose of the Service Locator pattern is to return the service instances on demand. This is useful for decoupling service consumers from concrete classes. It uses a central container which on request returns the request instance.

`states_rebuilder` combines the observer and service locator patterns to get what is called explicit reactivity and implicit reactivity.

>Contrary to what one might think, implicit reactivity is simpler, more efficient and more powerful than explicit reactivity.

> [List of article about `states_rebuilder`](https://medium.com/@meltft/states-rebuilder-and-animator-articles-4b178a09cdfa?source=friends_link&sk=7bef442f49254bfe7adc2c798395d9b9)

> [Tutorials](https://github.com/GIfatahTH/states-rebuilder-examples)

# 1- Explicit reactivity

In the context of observer pattern, any class that extends `StatesRebuilder` is the observable and `StateBuilder` as well as `StateWithMixinBuilder` widgets are the observers. `StatesRebuilder` notifies the observers using `rebuildStates` method. Observer widgets when notified rebuild themselves to reproduce the actual state.

This an example of a simple counter app without any dependency injection solution. The model is instantiated globally:

NB: model, BloC or service are used interchangeably. Thy refer to any class that hold the business logic of the app.

```dart
import 'package:flutter/material.dart';
import 'package:`states_rebuilder`/`states_rebuilder`.dart';

//The observable class
class Counter extends StatesRebuilder{
  int count = 0;
  increment() {
    count++;
    rebuildStates();
  }
}

//Global instantiation
final Counter counterModel = Counter();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: HomePage(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => counterModel.increment(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: 
      //The observer widget
      StateBuilder(
        //Registering the observer widget in the counterModel observable class.
        models: [counterModel],
        builder: (context, _) {
          return Text('${counterModel.count}');
        },
      ),
    );
  }
}
```
Regardless of the effectiveness of the state management solution, it must rely on a reliable dependency injection system.

`states_rebuilder` uses the service locator pattern, but using it in a way that makes it aware of the widget's lifecycle. This means that models are registered when needed in the `initState` method of a` StatefulWidget` and are unregistered when they are no longer needed in the `dispose` method.
Models once registered are available throughout the widget tree as long as the StatefulWidget that registered them is not disposed. The StatefulWidget used to register and unregister models is the `Injector` widget.

To consume a registered model, you use the static method :
```dart
final T model = Injector.get<T>()

//If the model is registered with custom name :
final T model = Injector.get<T>(name:'customName');
```

The example above becomes:
```dart
//The observable class
class Counter extends StatesRebuilder {
  int count = 0;
  increment() {
    count++;
    //notifying the observers
    rebuildStates();
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      //Register (inject) the model using the 'Inject' class.
      inject: [Inject(() => Counter())],
      builder: (context) {
        //Getting the registered singleton of the 'Counter' type.
        final counterModel = Injector.get<Counter>();
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: HomePage(),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => counterModel.increment(),
            ),
          ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  //Getting the registered singleton outside the build method.
  //This is possible because the context is not used to get registered models.
  //If the type can be inferred by dart, you can omit the generic type.
  final Counter counterModel = Injector.get();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StateBuilder(
        models: [counterModel],
        builder: (context, _) {
          return Text('${counterModel.count}');
        },
      ),
    );
  }
}
```
With `Injector` you can inject multiple dependent or independent models (BloCs, Services) at the same time. Also you can inject stream and future.
```dart
Injector( 
  inject: [
    //The order is not mandatory even for dependent models.
    Inject<ModelA>(() => ModelA()),
    Inject(() => ModelB()),//Generic type in inferred.
    Inject(() => ModelC(Injector.get<ModelA>())),// Directly inject ModelA in ModelC constructor
    Inject(() => ModelC(Injector.get())),// Type in inferred.
    Inject<IModelD>(() => ModelD()),// Register with Interface type.
    //You can inject streams and future and make them accessible to all the widget tree.
    Inject<bool>.future(() => Future(), initialValue:0),// Register a future.
    Inject<int>.stream(() => Stream()),// Register a stream.
    Inject(() => ModelD(),name:"customName"), // Use custom name
  ],
  .
  .
);
```
Models are registered lazily by default. That is, they will not be instantiated until they are first used. To instantiate a particular model at the time of registration, you can set the `isLazy` variable of the class `Inject` to false.

In addition to its injection responsibility, the `Injector` widget gives you a convenient facade to manage the life cycle of the widget as well as the application:

```dart
Injector( 
  initState: (){
    // Function to execute in initState of the state.
  },
  dispose: (){
    // Function to execute in dispose of the state.
  },
  afterInitialBuild: (BuildContext context){
    // Called after the widget is first inserted in the widget tree.
  },
  appLifeCycle: (AppLifecycleState state){
    /*
    Function to track app life cycle state. It takes as parameter the AppLifeCycleState
    In Android (onCreate, onPause, ...) and in IOS (didFinishLaunchingWithOptions, 
    applicationWillEnterForeground ..)
    */
  },
  // If true all model will be disposed when the widget is removed from the widget tree
  disposeModels: true,
  .
  .
);
```

For more information on the Dependency Injection capabilities of the `Injector` see the dependency injection.

The `Injector.get` method searches for the registered singleton using the service locator pattern. For this reason, `BuildContext` is not required. The `BuildContext` is optional and it is useful if you want to subscribe the widget that has the `BuildContext` to the obtained model.

In the `HomePage` class of the example, we can remove `StateBuilder` and use the `BuildContext` to subscribe the the widget. 

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The BuildContext of this widget is subscribed to the Counter class.
    // Whenever the Counter class issues a notification, this widget will be rebuilt.
    final Counter counterModel = Injector.get(context: context);
    return Center(
      child: Text('${counterModel.count}'),
    );
  }
}
```
Once the context is provided, `states_rebuilder` searches up in the widget tree to find the nearest `Injector` widget that has registered an `Inject` of the type provided and register the context (`Inject` class is associated with `InheritedWidget`). So be careful in case the `InheritedWidget` is not available, especially after navigation.

To deal with such situation, you can remove the `context` parameter and use the `StateBuilder` widget, or in case you want to keep using the `context` you can use the `reinject` parameter of the `Injector`.
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => Injector(
      //reinject an already injected model
      reinject: [counterModel],
      builder: (context) {
        return PageTwo();
      },
    ),
  ),
);
```
`states_rebuilder` uses the observer pattern. Notification can be filtered so that only widgets meeting the filtering criteria will be notified to rebuild. Filtration is done through tags. `StateBuilder` can register with one or more tags and `StatesRebuilder` can notify the observer widgets with a specific list of tags, so that only widgets registered with at least one of these tags will rebuild.

```dart
class Counter extends StatesRebuilder {
  int count = 0;
  increment() {
    count++;
    //notifying the observers with 'Tag1'
    rebuildStates(['Tag1']);
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Counter counterModel = Injector.get(context: context);
    return Column(
      children: <Widget>[
        StateBuilder( // This StateBuilder will be notified
          models: [counterModel],
          tag: ['tag1, tag2'],
          builder: (_, __) => Text('${counterModel.count}'),
        ),
        StateBuilder(
          models: [counterModel],
          tag: 'tag2',
          builder: (_, __) => Text('${counterModel.count}'),
        ),
        StateBuilder(
          models: [counterModel],
          tag: MyEnumeration.tag1,// You can use enumeration
          builder: (_, __) => Text('${counterModel.count}'),
        )
      ],
    );
  }
}
```
# 2- Implicit reactivity

What we have seen so far is called explicit reactivity, because our model must extend to `StatesRebuilder` and explicitly notify the observers using the `rebuildStates` methods.

With `states_rebuilder`, you can use pure vanilla dart classes for your logic, and `states_rebuilder` implicitly adds reactivity to your models so widgets can subscribe to your models and models can notify observer widgets.

This is the same example rewritten with implicit reactivity.
```dart
//Pure dart class. No inheritance, no notification, no streams, and no code generation
class Counter {
  int count = 0;
  increment() => count++;
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context) {
        //Use of 'getAsReactive' to get the model.
        //the suffix RM in counterModel means Reactive model.
        final ReactiveModel<Counter> counterModelRM = Injector.getAsReactive<Counter>();
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            body: HomePage(),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              //To mutate the state, use `setState` method.
              //setState notifies observers after state mutation.
              onPressed: () => counterModelRM.setState((state) => state.increment()),
            ),
          ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReactiveModel<Counter> counterModelRM = Injector.getAsReactive<Counter>(context: context);
    return Center(
      //use the `state` getter to get the model state.
      child: Text("${counterModelRM.state.count}"),
    );
  }
}
```
Compared to the case of explicit reactivity, `states_rebuilder` uses the same concepts for implicit reactivity, with the following differences:
* The model is a pure vanilla dart class, regardless of the complexity of the class, even though there are many asynchronous methods with error handling.
* The injected models are consumed using `getAsReactive` method instead of `get` in the explicit case.

```dart
ReactiveModel<T> modelRM = Injector.getAsReactive<T>()
```
The returned type is `ReactiveModel<T>`.  The method `getAsReactive` returns the registered singleton of the model wrapped with reactive environnement:

> `Injector.get<T>()` returns the raw singleton of type `T` of the registered model.    
> `Injector.getAsReactive<T>()` returns the reactive singleton of type `ReactiveModel<T>` of the registered model.  

The reactive environment adds the following getters and methods:

The getters are : 
* **state**: returns the registered raw singleton of the model.
* **connectionState** : It is of type `ConnectionState` (a Flutter defined enumeration). It takes three values:  
      1- `ConnectionState.none`: Before executing any method of the model.  
      2- `ConnectionState.waiting`: While waiting for the end of an asynchronous task.   
      3- `ConnectionState.done`: After running a synchronous method or the end of a pending asynchronous task.  
* **isIdle** : It's of bool type. it is true if `connectionState` is `ConnectionState.none`
* **isWaiting** : It's of bool type. it is true if `connectionState` is `ConnectionState.waiting`
* **hasError**: It's of bool type. it is true if the asynchronous task ends with an error.
* **error**: Is of type dynamic. It holds the thrown error.
* **hasData**: It is of type bool. It is true if the connectionState is done without any error.

The fields are:
* **customStateStatus**: It is of type dynamic. It holds your custom-defined state status. For example, in a timer app, you can define custom states such as 'plying', 'paused, 'finished'.
* **joinSingletonToNewData** : It is of type dynamic. It holds data sent from new reactive instance to the reactive singleton.
* **subscription** : it is of type `StreamSubscription<T>`. It is not null if you inject streams using `Inject.stream` constructor. It is used to control the injected stream.   

The methods are:
* **setState(T state)**: return a `Future<void>`. It takes the state as a parameter that corresponds to the singleton instance of the injected model. It is used to mutate the state and notify listeners after state mutation.
* **whenConnectionState** Exhaustively switch over all the possible statuses of [connectionState]. Used mostly to return [Widget]s. It has four required parameters (`onIdle`, `onWaiting`, `onData` and `onError`).

`setState` is used whenever you want to trigger an event or an action that will mutate the state of the model and ends by issuing a notification to the observers.

```dart
reactiveModel.setState(
  (state) => state.increment(),
  filterTags: ['Tag1', Enumeration.Tag2],
  //set to true, you want to catch error, and not break the app.
  catchError: true 
  watch: (Counter counter) {
    //Specify the parts of the state to be monitored so that the notification is not sent unless this part changes
    return counter.count; //if count value is not changed, no notification will be emitted.
  },
  onSetState: (BuildContext context) {
    /* 
    Side effects to be executed after sending notification and before rebuilding the observers. Side effects are navigating, opening the drawer, showing snackBar , ..

    You can use another nested setState here.
    */
  },
  onRebuildState: (BuildContext context) {
    //The same as in onSetState but called after the end rebuild process.
  },
  onError: (BuildContext context, dynamic error){
    //Callback to be execute if the reactive model throws an error.
    //You do not have to set the parameter catchError to true. By defining onError parameter 
    //states_rebuilder catches the error by default.
  }
  //When a notification is issued, whether to notify all reactive instances of the model
  notifyAllReactiveInstances: true, 
  /*
  If defined, when a new reactive instance issues a notification, it will change the state of the reactive singleton in two ways.
  1- JoinSingleton.withNewReactiveInstances
  2- JoinSingleton.withCombinedReactiveInstances
  */
  joinSingletonWith: JoinSingleton.withNewReactiveInstance,

  //message to be sent to the reactive singleton
  dynamic joinSingletonToNewData,
),
```
It is important to understand that `states_rebuilder` caches two singletons.
* The raw singleton of the registered model, obtained using `Injector.get` method.
* The reactive singleton of the registered model (the raw model decorated with reactive environnement), obtained using `Injector.getAsReactive`.

With `states_rebuilder`, you can create, at any time, a new reactive instance, which is the same raw cashed singleton but decorated with a new reactive environment.

To create a new reactive instance of an injected model use:   
1- `Injector.getAsReactive` with the  parameter `asNewReactiveInstance` equals true

```dart
// get a new reactive instance
ReactiveModel<T> modelRM2 = Injector.getAsReactive<T>(asNewReactiveInstance: true);
```
2- `StateBuilder` with generic type and without `models` property.
```dart
StateBuilder<T>(
  builder:(BuildContext context, ReactiveModel<T> newReactiveModel){
    return YourWidget();
  }
)
```

**Important notes about reactive singleton and new reactive instances:**
* The reactive singleton and all the new reactive instances share the same raw singleton of the model, but each one decorates it with a different environment.
* Unlike the reactive singleton, new reactive instances are not cached so they are not accessible outside the widget in which they were instantiated.
* To make new reactive instances accessible throughout the widget tree, you have to register it with the `Injector` with a custom name: 

```dart
final modelRM =Injector.getAsReactive<Counter>(asNewReactiveInstance: true);

return Injector(
inject: [
  Inject( () => modelRM, name: 'newModel1'),
],
)
// Or
Injector(
inject: [
  Inject<Counter>(() => Counter()),
  Inject(
    () => Injector.getAsReactive<Counter>(asNewReactiveInstance: true),
    name: Enum.newModel1,
  ),
],
```
At later time if you want to consume the injected new reactive instance you use:

```dart
// get the injected new reactive instance
ReactiveModel<T> modelRM2 = Injector.getAsReactive<T>(name : 'newModel1');
//Or
ReactiveModel<T> modelRM2 = Injector.getAsReactive<T>(name : Enum.newModel1);
```
* You can not get a new reactive model by using `getAsReactive(context: context)` with a defined context. It will throw because only the reactive singleton that can subscribe a widget using the context.

* With the exception of the raw singleton they share, the reactive singleton and the new reactive instances have an independent reactive environment. That is, when a particular reactive instance issues a notification with an error or with `ConnectionState.awaiting`, it will not affect other reactive environments.

* `states_rebuilder` allows reactive instances to share their notification or state with the reactive singleton. This can be done by:   
1- `notifyAllReactiveInstances` parameter of `setState` method. If true, each time a notification is issued by the reactive instance in which `setState` is called, all other reactive instances are notified.   
2- `joinSingletonWith` parameter of `setState` method or `Inject` class. This time, new reactive instances, when issuing a notification, can clone their state to the reactive singleton.
  * If `joinSingletonWith` is set to` JoinSingleton.withNewReactiveInstance`, this means that the reactive singleton will have the state of the new reactive instance issuing the notification.
  * If `joinSingletonWith` is set to `JoinSingleton.withCombinedReactiveInstances`, this means that the singleton will hold a combined state of all the new reactive instances.    
  The combined state priority logic is:   
  Priority 1- The combined `ReactiveModel.hasError` is true if at least one of the new instances has error    
  Priority 2- The combined `ReactiveModel.connectionState` is awaiting if at least one of the new instances is awaiting.    
  Priority 3- The combined `ReactiveModel.connectionState` is 'none' if at least one of the new instances is 'none'.     
  Priority 4- The combined `ReactiveModel.hasDate` is true if it has no error, it isn't awaiting  and it is not in 'none' state.
* `joinSingletonWith` can be defined in `setState` method or in `Inject` class constructor. When set in the `setState` method, it means that only the new instance, where` setState` is called, is joined to the reactive singleton. Whereas if `joinSingletonWith` is defined in the` Inject` constructor, this means that all new reactive instances will be joined to the reactive singleton.
* New reactive instances can send data to the reactive singleton. `joinSingletonToNewData` parameter of reactive environment hold the sending message.

# StateBuilder
In addition to its state management responsibility, `StateBuilder` offers a facade that facilitates the management of the widgets lifecycle.
```dart
StateBuilder<T>(
  onSetState: (BuildContext context, ReactiveModel<T> model){
  /*
  Side effects to be executed after sending notification and before rebuilding the observers. Side effects are navigating, opening the drawer, showing snackBar,...  
  
  It is similar to 'onSetState' parameter of the 'setState' method. The difference is that the `onSetState` of 'setState' method is called once after executing the 'setState'. But this 'onSetState' is executed each time a notification is send from one of the observable model this 'StateBuilder' is subscribing.
  
  You can use another nested setState here.
  */
  },
  onRebuildState: (BuildContext context, ReactiveModel<T> model){
  // The same as in onSetState but called after the end rebuild process.
  },
  initState: (BuildContext context, ReactiveModel<T> model){
  // Function to execute in initState of the state.
  },
  dispose: (BuildContext context, ReactiveModel<T> model){
  // Function to execute in dispose of the state.
  },
  didChangeDependencies: (BuildContext context, ReactiveModel<T> model){
  // Function to be executed  when a dependency of state changes.
  },
  didUpdateWidget: (BuildContext context, ReactiveModel<T> model, StateBuilder oldWidget){
  // Called whenever the widget configuration changes.
  },
  afterInitialBuild: (BuildContext context, ReactiveModel<T> model){
  // Called after the widget is first inserted in the widget tree.
  },
  afterRebuild: (BuildContext context, ReactiveModel<T> model){
  /*
  Called after each rebuild of the widget.

  The difference between onRebuildState and afterRebuild is that the latter is called each time the widget rebuilds, regardless of the origin of the rebuild. 
  Whereas onRebuildState is called only after rebuilds after notifications from the models to which the widget is subscribed.
  */
  },
  // If true all model will be disposed when the widget is removed from the widget tree
  disposeModels: true,

  // A list of observable objects to which this widget will subscribe.
  models: [model1, model2]

  // Tag to be used to filer notification from observable classes.
  // It can be any type of data, but when it is a List, 
  // this widget will be saved with many tags that are the items in the list.
  tag: dynamic

   watch: (ReactiveModel<T> model) {
    //Specify the parts of the state to be monitored so that the notification is not sent unless this part changes
  },

  builder: (BuildContext context, ReactiveModel<T> model){
    /// [BuildContext] can be used as the default tag of this widget.

    /// The model is the first instance (model1) in the list of the [models] parameter.
    /// If the parameter [models] is not provided then the model will be a new reactive instance.
  },
  builderWithChild: (BuildContext context, ReactiveModel<T> model, Widget child){
    ///Same as [builder], but can take a child widget containing the part of the widget tree that we do not want to rebuild.
    /// If both [builder] and [builderWithChild] are defined, it will throw.

  },

  //The child widget that is used in [builderWithChild].
  child: MyWidget(),

)
```
# StateWithMixinBuilder
`StateWithMixinBuilder` is similar to `StateBuilder` and extends it by adding mixin (practical case is animation),
```Dart
StateWithMixinBuilder<T>( {
  Key key, 
  dynamic tag, // you define the tag of the state. This is the first way
  List<StatesRebuilder> models, // You give a list of the logic classes (BloC) you want this this widget to listen to.
  initState: (BuildContext, String,T) {
     // for code to be executed in the initState of a StatefulWidget
  },
  dispose (BuildContext, String,T) {
    // for code to be executed in the dispose of a StatefulWidget
  }, 
  didChangeDependencies: (BuildContext, String,T) {
    // for code to be executed in the didChangeDependencies of a StatefulWidget
  }, 
  didUpdateWidget: (BuildContext, String,StateBuilder, T){
    // for code to be executed in the didUpdateWidget of a StatefulWidget
  },
  didChangeAppLifecycleState: (String, AppLifecycleState){
    // for code to be executed depending on the life cycle of the app (in Android : onResume, onPause ...).
  },
  afterInitialBuild: (BuildContext, String,T){
    // for code to be executed after the widget is inserted in the widget tree.
  },
  afterRebuild: (BuildContext, String) {
    // for code to be executed after each rebuild of the widget.
  }, 
  @required MixinWith mixinWith
});
```
  Available mixins are: singleTickerProviderStateMixin, tickerProviderStateMixin, AutomaticKeepAliveClientMixin and WidgetsBindingObserver.


> [List of article about `states_rebuilder`](https://medium.com/@meltft/states-rebuilder-and-animator-articles-4b178a09cdfa?source=friends_link&sk=7bef442f49254bfe7adc2c798395d9b9)


# Dependency Injection

`states_rebuilder` uses the service locator pattern for injecting dependencies using the` injector` with is a StatefulWidget. To understand the principle of DI, it is important to consider the following principles:

1. `Injector` adds classes to the container of the service locator in` initState` and deletes them in the `dispose` state. This means that if `Injector` is removed and re-inserted in the widget tree, a new singleton is registered for the injected models.

2. You can use nested injectors. As the `Injector` is a simple StatefulWidget, it can be added anywhere in the widget tree. A typical use is to insert the `Injector` deeper in the widget tree just before using the injected classes.

3. Injected classes are registered lazily. This means that they are not instantiated after injection until they are consumed for the first time using `Injector.get` or` Injector.getAsModel`.

4. For each injected class, you can consume the registered instance using `Injector.get` or the reactive model wrapper of the injected instance using` Injector.getAsModel`. As the raw instance and the reactive instance are registered lazily, if you consume a class using only `Injector.get` and not` Injector.getAsModel`, the reactive instance will never be instantiated.

5. You can register classes with concrete types or abstract classes.

That said: 
> It is possible to register a class as a singleton, as a lazy singleton or as a factory simply by choosing where to insert it in the widget tree.

* To save a singleton that will be available for all applications, insert the `Injector` widget in the top widget tree. It is possible to set the `isLazy` parameter to false to instantiate the injected class the time of injection.

* To save a singleton that will be used by a branch of the widget tree, insert the `Injector` widget just above the branch. Each time you get into the branch, a singleton is registered and when you get out of it, the singleton will be destroyed.

* With `Injector`, you can inject futures and use `whenConnectionState` to display useful information to the user and finally you can get the registered raw singleton using `Injector.get` method anywhere in the app. This is useful for instantiating plug-ins such as `SharedPreferences`. So you do not have to make the `main` function async and wait before calling `runApp` and use `WidgetsFlutterBinding.ensureInitialized()`.
For example, you can show a splash screen informing the user that something is instantiating and display a helping error message if a plug-in fails to initialize.
example :
```dart
void main() {
  runApp(
    //global injection
    Injector(
      inject: [
        Inject.future(() => SharedPreferences.getInstance(),
        isLazy: false,
        ),
      ],
      builder: (context) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Getting sharedPreferences Reactive Model
    final sharedPreferencesRM =
        Injector.getAsReactive<SharedPreferences>(context: context);
    return sharedPreferencesRM.whenConnectionState(
      onIdle: () => Text('onIdle'),
      onWaiting: () => SplashScreen(),
      onError: (error) => Text('error message'),
      onData: (_) {
        //sharedPreferences instance is available and can be used any where in the app

        return Injector(
          inject: [Inject(() => MyClass(sharedPreferences: Injector.get()))],
          builder: (_) {
            
            ....
          },
        );
      },
    );
  }
}
```