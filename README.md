# `States_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)

<p align="justify">
States Rebuilder is a easy flutter state management solution that allows for clear and sharp separation of concern between the user interface (UI) logic and the business logic. The separation is clear and sharp to the point that the business logic is written with pure, vanilla, plain old dart classes without extending any external library-specific classes and without annotation or code generation.
</p>

 With `States_rebuilder`, you can easily: 
* Manage / Refactor the [Immutable](https://github.com/GIfatahTH/states_rebuilder/wiki/stream) and [Mutable](https://github.com/GIfatahTH/states_rebuilder/wiki/mutable-state-management) state without affecting your UI code. 

* Work with [Future](https://github.com/GIfatahTH/states_rebuilder/wiki/stream) and [Stream](https://github.com/GIfatahTH/states_rebuilder/wiki/stream), it's "hot pluggable", without affecting your UI code.


* Achieve injected dependencies asynchronously (no Provider needed). 
    - [📙 Appoarch 1 - Injector](https://github.com/GIfatahTH/states_rebuilder/wiki/Asynchronous-Dependency-Injection) &nbsp; 
      [📘 (Easier) Appoarch 2 - Funtional Injection (FI)](https://github.com/GIfatahTH/states_rebuilder/wiki/00-functional_injection)&nbsp;&nbsp; 
      [📚 Difference? ](https://github.com/GIfatahTH/states_rebuilder/issues/123)

* Invoke side effects without ❌`BuildContext`, like Dialogs, Navigate, MediaQuery, and [many others](https://github.com/GIfatahTH/states_rebuilder/issues/129). 


# Table of Contents
- [`States_rebuilder`](#states_rebuilder)
- [Table of Contents](#table-of-contents)
- [Getting Started with States_rebuilder](#getting-started-with-states_rebuilder)
- [Breaking Changes](#breaking-changes)
- [Mechanism](#mechanism)
  - [Business logic](#business-logic)
  - [UI logic](#ui-logic)
- [Documentation](#documentation)
- [List of Article](#list-of-article)
- [Examples:](#examples)
  - [Basics 🧗‍♀️:](#basics-️)
  - [Advanced 🏋️‍♀️:](#advanced-️️)
    - [Firebase Series:](#firebase-series)
    - [Firestore Series in Todo App:](#firestore-series-in-todo-app)
      #### [`Immutable State`](#immutable-state)
      #### [`Mutable State`](#mutable-state)
      #### [`Code in Bloc Style`](#code-in-bloc-style)

# Getting Started with States_rebuilder
1. Add this to your package's pubspec.yaml file:
```
dependencies:
  states_rebuilder: ^3.0.0
```
2. Import it in any Dart code:
```
import 'package:states_rebuilder/states_rebuilder.dart';
```
3. Basic use case:
```
// 🗄️ Plain Data Class
class Model {
  int counter;

  Model(this.counter);
}  

// 🤔 Business Logic
class ServiceState {
  ServiceSatate(this.model);
  final Model model;  

  void incrementMutable() { model.counter++ };
}


// 🚀 Global Functional Injection 
final serviceState = RM.inject(() => ServiceState(Model(0)));


// 👀 UI  
class CounterApp extends StatelessWidget {
  final _model = serviceState.state.model;

  @override
  Widget build(BuildContext context) {
    return Column (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            RaisedButton(
                child: const Text('🏎️ Counter ++'),
                onPressed: () => serviceState.setState(
                    (s) => s.incrementMutable(),
                ),
            ),
            RaisedButton(
                child: const Text('⏱️ Undo'),
                onPressed: () => serviceState.setState(
                    (s) => serviceState.canUndoState? serviceState.undoState() : null;,
                ),
            ),
            serviceState.rebuilder(() => Text('🏁Result: ${_model.counter}')),
        ],
    );
  }  
}
```


# Breaking Changes

### Since 3.0: &nbsp; [Here](https://github.com/GIfatahTH/states_rebuilder/issues/123) <!-- omit in toc --> 

### Since 2.0: &nbsp; [Here](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/changelog/v-2.0.0.md) <!-- omit in toc --> 


# Mechanism

## Business logic

>The business logic classes are independent of any external library. They are independent even from `states_rebuilder` itself.


Another advantage of `states_rebuilder` is that it has practically no boilerplate. It has no boilerplate to the point that you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold for example `onLoading`, `onLoaded`, `onError` states. `states_rebuilder` automatically manages these asynchronous statuses and exposes the `isIdle`,` isWaiting`, `hasError` and` hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic.

>With `states_rebuilder`, you write business logic without bearing in mind how the user interface would interact with it.

## UI logic

With `states_rebuilder`, you write your user interface using StatelessWidget, and when you need a business logic class, you just inject a singleton of the class using the `Injector` widget and get it from any child widget using the `Injector.get` method.

The instance obtained using `Injector.get` is not reactive, it is the registered singleton of the pure dart class. To make a vanilla dart class reactive, just get it using the `Injector.getAsReactive` method.
<p align="center">
    <image src="assets/01-states_rebuilder__singletons.png" width="400" alt=''/>
</p>


The model obtained is of `ReactiveModel` type and it is observable in the context of observer pattern. Observer widgets can subscribe to it and the observable reactive model can notify them to rebuild.


To subscribe to a `ReactiveModel`, `states_rebuilder` offers `StateBuilder`, `StateWithMixinBuilder`, `WhenRebuilder`, `WhenRebuilderOr` and `OnSetStateListener` widgets.

To notify observers you call `setState` or `setValue` methods of an observable model.
<p align="center">
    <image src="assets/01-states_rebuilder_state_wheel.png" width="400" alt=''/>
</p>


With `states_rebuilder`, you can create as many `ReactiveModel`s as you want from the same object, so that you can surgically control the part of the widget tree to rebuild.
<p align="center">
    <image src="assets/01-states_rebuilder_new_reactive_model.png" width="400" alt=''/>
</p>


# Documentation
* [**Official Documentation**](states_rebuilder_package)

# List of Article
* [**List of articles about `states_rebuilder`**](https://medium.com/@meltft/states-rebuilder-and-animator-articles-4b178a09cdfa?source=friends_link&sk=7bef442f49254bfe7adc2c798395d9b9)

# Examples:

* [**States_rebuilder from A to Z using global functional injection**](https://github.com/GIfatahTH/states_rebuilder/wiki/00-functional_injection)

## Basics 🧗‍♀️:
You are new to `states_rebuilder` this is right place to start from. The order is tailor-made for you:

* [**The simplest counter app**](examples/001-flutter_default_counter_app) Default flutter counter app refactored using `states_rebuilder`. You will understand the concept of `ReactiveModel` and how to make a pure dart class reactive. You will see the use of `ReactiveModel.create`, `setValue`, `isIdle`, `isWaiting`, `hasData`, `hasError`, `onIdle`, `onWaiting`, `onError`, `onData`, `whenConnectionState`, `StateBuilder` and `WhenRebuilder`.

* [**Login form validation**](examples/002-form_validation_with_reactive_model) Simple form login validation. The basic `ReactiveModel` concepts are put into practice to make form validation one of the easiest tasks in the world. The concept of exposed model is explained here.


* [**Counter app with flavors**](examples/003-async_counter_app_with_injector) Injector as dependency injection is used, and a counter app with two flavors is built. You will see the use of `Injector`, `Injector.get`, `Injector.getAsReactive`, `Inject.interface`, `Inject.env`, and `setState`.

* [**CountDown timer**](examples/004-1-countdown_timer) This is a timer that ticks from 60 and down to 0. It can be paused, resumed or restarted. You see how to inject enumeration and how to make two reactive models interact. You will see the use of `OnSetStateListener`.

* [**CountDown timer (🚀Global functional injection appoarch)**](examples/004-2-countdown_timer_with_functional_injection) This is a timer rewritten using global functional injection.

* [**Double async counters**](examples/005-double_async_counter_with_error) Two counter that share the same model. You will see the use of tags to filter notifications and the concept of new reactive models to limit rebuild process. You will see `tag`, `filteredTags` and `asNew` 

* [**Multi async counters**](examples/006-multi_async_counter_with_error) The is a solution of an imaginary and very tricky state management requirement. You will see how the concept of ReactiveModel can solve very difficult state management requirements. You will see How can Reactive singleton interact with new reactive models. You will use
 `joinSingleton`, `JoinSingleton.withCombinedReactiveInstances`, `joinSingletonToNewData`

</br>

## Advanced 🏋️‍♀️:
Here, you will take your programming skills up a notch, deep dive in Architecture:

* [**User posts and comments**](examples/007-1-clean_architecture_dane_mackier_app_with_Injector)  The app communicates with the JSONPlaceholder API, gets a User profile from the login using the ID entered. Fetches and shows the Posts on the home view and shows post details with an additional fetch to show the comments.

* [**User posts and comments (🚀Global functional injection appoarch)**](examples/007-2-clean_architecture_dane_mackier_app_with_functional_injection): The  User posts and comments rewritten using global functional injection.

* [**GitHub use search app**](examples/011-github_search_app) The app will search for github users matching the input query. The query will be debounced by 500 milliseconds.

### Firebase Series:

* [**Firebase login** ](examples/008-clean_architecture_firebase_login)The app uses firebase for sign in. The user can sign in anonymously, with google account, with apple account or with email and password.

* [**Firebase Realtime Database**](examples/010-clean_architecture__multi_counter_realtime_firebase) The app add, update, delete a list of counters from firebase realtime database. The app is built with two flavors one for production using firebase and the other for test using fake data base.

### Firestore Series in Todo App:

## <p align='center'>`Immutable State` </p> <!-- omit in toc --> 
* [**Todo MVC with immutable state and firebase cloud service**](examples/009-1-1-clean_architecture_todo_mvc_cloud_firestore_immutable_state_with_injector) : This is an implementation of the TodoMVC using states_rebuild, firebase cloud service as backend and firebase auth service for user authentication. This is a good example of immutable state management.

* [**Todo MVC with immutable state and firebase cloud service (🚀Global functional injection appoarch)**](examples/009-1-2-clean_architecture_todo_mvc_cloud_firestore_immutable_state_with_functional_injection) : Immutable TodoMVC rewritten using global functional injection.

## <p align='center'>`Mutable State`</p> <!-- omit in toc --> 
* [**Todo MVC with mutable state and sharedPreferences for persistence**](examples/009-2-1-clean_architecture_todo_mvc_mutable_state_with_injector) : This is the same Todos app but using mutable state and sharedPreferences to locally persist todos. In this demo app, you will see an example of asynchronous dependency injection.

* [**Todo MVC with mutable state and sharedPreferences for persistence (🚀Global functional injection appoarch)**](examples/009-2-2-clean_architecture_todo_mvc_mutable_state-with__functional_injection) : The mutable TodoMVC rewritten using global functional injection.


## <p align='center'>`Code in Bloc Style`</p> <!-- omit in toc --> 
* [**Todo MVC following flutter_bloc library approach**](examples/009-3-1-todo_mvc_the_flutter_bloc_way_with_injector) : This is the same Todos App built following the same approach as in flutter_bloc library.

* [**Todo MVC following flutter_bloc library approach (🚀Global functional injection appoarch)**](examples/09-3-2-todo_mvc_the_flutter_bloc_way_with__functional_injection) : This is the same Todos App built following the same approach as in flutter_bloc library using global functional injection.


</br>
**Note that all of the above examples are tested. With `states_rebuilder`, testing your business logic is the simplest part of your coding time as it is made up of simple dart classes. On the other hand, testing widgets is no less easy, because with `states_rebuilder` you can isolate the widget under test and mock its dependencies.**



