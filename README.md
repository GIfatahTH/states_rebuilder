# states_rebuilder

A Flutter state management combined with dependency injection solution that allows : 
  * a 100% separation of User Interface (UI) representation from your logic classes
  * an easy control on how your widgets rebuild to reflect the actual state of your application.
Model classes are simple dart classes without any need of inheritance, notification, streams or annotation and code generation.


## example of the simple Counter app:
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
      builder: (context, __) {
        ///`context` is optional. Here `getAsModel` is called without context because we do not want this widget to update
        final counter = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            //To mutate the state, use `setState` method. This insures that the dependent widgets are updated after state mutation.
            onPressed: () => counter.setState((state) => state.increment()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///Here the `getAsModel`is called with the `context` to automatically add this widget to the list of dependent widgets of the model.
    final counter = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You have pushed this many times"),
          //use the `state` getter to get the model state.
          Text("${counter.state.count}"),
        ],
      ),
    );
  }
}
```
## Principal ideas of the states_rebuilder
> 1- Register a model (or any kind of values) using the `Injector` widget.   
>> The registered (injected) models are available for access within the `Injector` itself and any of its child widgets.   
>> Registered (injected) models are automatically unregistered when the `Injector` is disposed (removed) from the widget tree. 
>> Registered model can be disposed to release recourses. This is done by using the `dispose` parameter of Injector or set the `disposeModels` parameter to true.
>> Futures and Streams can be registered (injected) using the named constructor `Inject.future` and `Inject.stream `respectively.   
>> Streams are automatically disposed when the `Injector` is removed from the widget tree.
>> Models can be registered associated with custom names.
>> Models are lazily instantiated. Set the parameter `isLazy` of the `Inject` to false if you want to intentionally instantiated a registered model.

> 2- To get any of the registered models :
>> Use `Injector.get<T>()` to get a singleton of the `T` class.    
>> No need for the `context`, hence you can get a registered model inside any class.    
>> To get a model registered with a custom name, use `Injector.get<T>(name: customName)`.     
>> To get a new instance of a registered model, use `Injector.getNew<T>()`.     

> 3- To get any of the registered model and make it reactive :     
> (Reactive means that the model allows widgets to register as listeners notify them to update after state mutation).   
>> Use `Injector.getAsModel<T>()` to get a singleton of type `ModelStatesRebuilder<T>`. (ModelStatesRebuilder extends StatesRebuilder).    
>> Another way to make a model reactive is to extend it with `StatesRebuilder` class.
>> To register a widget as a listener in a particular reactive model :    
>>> Use `Injector.getAsModel<T>(context:context)`. The context is optional and when it is provided, the widget is automatically registered in the model. For futures and streams, use `Injector.getAsModel<T>(context:context).snapshot`  to get the `AsyncSnapshot`.
>>> Use `StateBuilder` widget. `StateBuilder` make rebuild process filtrable. This is done by giving `StateBuilder` a tag. When a model sends notifications to its dependent with a particular tag, only those `StateBuilder` that have this tag will rebuild.    

> 4- To notify listeners of a reactive model :
>> Use `setState(Function(T) state,{List tag})` method. This works with models obtained using `Injector.getAsModel<T>()`.    
>> Use `rebuildStates([List tag])` method. This works inside a model that extends `StatesRebuilder`.   
>> Use the getter `state` to get the state of a models obtained using `Injector.getAsModel<T>()`.      

> 5- states_rebuilder offers an easy facade to get:
>> The widget lifeState : use `initState`, `dispose`, `didChangeDependencies`, `didUpdateWidget`, `afterInitialBuild` and `afterRebuild`.    
>> The app life cycle in Android (onCreate, onPause, ...) and in IOS (didFinishLaunchingWithOptions, applicationWillEnterForeground ..): use `appLifeCycle`.   

> 6- states_rebuilder offers the widget `StateWithMixinRebuilder` to deal with the most common mixins.   Available mixins are: `singleTickerProviderStateMixin`, `tickerProviderStateMixin`, `AutomaticKeepAliveClientMixin` and `WidgetsBindingObserver`.



## This Library offers the following classes and methods:

  ### `Injector` widget for dependency injection:
  To register models and services use Injector. The registered model will be available to all child widgets of the Injector
  ```dart
  Injector<T>({
    List<Inject<D>> inject, // List of Model to register wrapped with `Inject` object.
                            // To inject future and stream use the named constructor `Inject<T>.future` and `Inject<T>.stream`.
    List<() → dynamic> models, // List of models to register. prefer using `inject` instead.
    (BuildContext context, T model) → Widget builder, // The builder method.
    (T model) → void initState, // a custom method to call when Injector is first added to the widget tree.
    (T model) → void dispose, // a custom method to call when Injector is disposed.
    (T, AppLifecycleState) → dynamic appLifeCycle, // A closure to execute code depending on the life cycle of the app (in Android : onResume, onPause ...).
    (BuildContext, String,T) → void afterInitialBuild, // for code to be executed after the widget is inserted in the widget tree.
    (BuildContext, String) → void afterRebuild, // for code to be executed after each rebuild of the widget.
    bool disposeModels: false // Whether Injector will automatically call dispose method from the registered models.
  }) 
  ```
  To get the same instance of the model inside any class use:
  ```dart 
  Injector.get<T>({dynamic name, BuildContext context, bool silent = false}).
  ``` 
  Where T is the type of the model and name is optional used if you want to call a named model.

  To get the same instance of a registered model and make it reactive use:
  ```dart 
  Injector.getAsModel<T>(({dynamic name, BuildContext context, bool silent = false})).
  ``` 
  Where T is the type of the model and name is optionally used if you want to call a named model.
  If you provide the context parameter the widget will listen to the model and rebuild when the state of the model is changed.

  To get a new instance of the model, you  use:
  ```dart 
  Injector.getNew<T>([String name]).
  ``` 
  Model are automatically unregistered when the injector is disposed.

  `Injector.get` or `Injector.getAsModel` now throws if no registered model is found. This can be silent by setting the parameter `silent` to true

#### Prototype Example for dependency injection

```dart
    Widget build(BuildContext context) {
    return Injector( 
      inject: [
        Inject(() => ModelA()),
        Inject(() => ModelB()),
        Inject(() => ModelC(Injector.get<ModelA>())),// Directly inject ModelA in ModelC constructor
        Inject<IModelD>(() => ModelD()),//To register with Interface type.
        Inject<bool>.future(() => Future(), initialValue:0),//To register a future.
        Inject<int>.stream(() => Stream()),//To register a stream.
        Inject(() => ModelD(),name:"customName"), // to use custom name
        ],
      builder: (context,model) => MyWidget(model), // model is of type `ModelA`. when `rebuildStates()` is called in `ModelA` this widget will rebuild
    );
  }

  // You can get your models from any class provided it is registered before calling it.
  class MyWidget extends StatelessWidget {

    final ModelA modelA = Injector.get<ModelA>(); // get the ModelA singleton
    final ModelA modelA1 = Injector.getNew<ModelA>(); // get new instance
    final modelD = Injector.getAsModel<ModelD>(context:context); // get ModelD as `StatesRebuilder` type and subscribe this widget
    final modelDNamed = Injector.get<ModelD>("costumeName");
    final futureSnapshot = Injector.getAsModel<bool>(context:context, name: "costumeName").snapshot; // get the snapshot of an injected future
    final streamSnapshot = Injector.getAsModel<int>(context:context).snapshot; // get the snapshot of an injected future

    @override
    Widget build(BuildContext context) {
      return Widget(
        child: ChildWidget(modelID.state.myVar ) // get the state of a reactive model
        onPressed:()=> modelD.setState((state) { state mutation }), // mutate the state of a reactive model
      )
    }
  }
  ```
### The `StateBuilder` Widget. 
You wrap any part of your widgets with it to add it to the listeners' list of your logic classes and hence can rebuild when the any of the logic classes send notifications.

notification can be sent by:
1- calling `rebuildStates` method inside a class that extends `StatesRebuilder`.
2- calling `setState(Function(T))` of any reactive model obtained using `Injector.getAsMode`.

  This is the constructor of the `StateBuilder`:
  
  ```dart
  StateBuilder( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way. You can provide a list of tags.
      List<StatesRebuilder> viewModels, // You give a list of the logic classes (BloC) you want this widget to listen to.
      @required (BuildContext, String) → Widget builder,
      (BuildContext, String) → void initState, // for code to be executed in the initState of a StatefulWidget
      (BuildContext, String) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (BuildContext, String) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (BuildContext, String, StateBuilder) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget
      (BuildContext, String) → void afterInitialBuild, // for code to be executed after the widget is inserted in the widget tree.
      (BuildContext, String) → void afterRebuild, // for code to be executed after each rebuild of the widget.
    });
  ```
  `tag` is of type dynamic. It can be String (for small projects) or enum members (enums are preferred for big projects). When a list of dynamic tags is provided, states_rebuilder considers it as many tags and will rebuild this widget if any of these tags are invoked by the `rebuildStates` method or by `setState` method.


  ## The `StatesRebuilder` class. 
  Your logics classes (viewModels) will extend this class to create your own business logic BloC (equally can be called ViewModel or Model).
  * The `rebuildStates` method. You call it inside any of your logic classes that extend `StatesRebuilder`. It rebuilds all the mounted 'StateBuilder' widgets. It can filter the widgets to rebuild by tag.
  This is the signature of the `rebuildState`:
  ```dart
  rebuildStates([List<dynamic> tags])
  ```
  You can use `hasState` to check whether the `StatesRebuilder` has state to rebuild or not before calling `rebuildStates` to avoid any error.
  

  ### The `StateWithMixinBuilder` class. 
 * To extends the state with mixin (practical case is animation), use `StateWithMixinBuilder`
```Dart
StateWithMixinBuilder<T>( {
      Key key, 
      dynamic tag, // you define the tag of the state. This is the first way
      List<StatesRebuilder> viewModels, // You give a list of the logic classes (BloC) you want this this widget to listen to.
      @required (BuildContext, String) → Widget builder, 
      @required (BuildContext, String,T) → void initState, // for code to be executed in the initState of a StatefulWidget
      @required (BuildContext, String,T) → void dispose, // for code to be executed in the dispose of a StatefulWidget
      (BuildContext, String,T) → void didChangeDependencies, // for code to be executed in the didChangeDependencies of a StatefulWidget
      (BuildContext, String,StateBuilder, T) → void didUpdateWidget // for code to be executed in the didUpdateWidget of a StatefulWidget,
      (String, AppLifecycleState) → void didChangeAppLifecycleState // for code to be executed depending on the life cycle of the app (in Android : onResume, onPause ...).
      (BuildContext, String,T) → void afterInitialBuild, // for code to be executed after the widget is inserted in the widget tree.
      (BuildContext, String) → void afterRebuild, // for code to be executed after each rebuild of the widget.
      @required MixinWith mixinWith
});
```
  Available mixins are: singleTickerProviderStateMixin, tickerProviderStateMixin, AutomaticKeepAliveClientMixin and WidgetsBindingObserver.
