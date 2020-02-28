# `states_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)


`states_rebuilder` is a flutter state management solution that allows for clear and sharp separation of concern between the user interface (UI) logic and the business logic. The separation is clear and sharp to the point that the business logic is written with pure, vanilla, plain old dart classes without extending any external library-specific classes and without annotation or code generation.

## Business logic

>The business logic classes are independent of any external library. They are independent even from `states_rebuilder` itself.

The only constraint imposed by `states_rebuilder` is to ensure that methods supposed to be called from the user interface must return anything; their only role is to mutate the state (aka fields) of the class.

Another advantage of `states_rebuilder` is that it has practically no boilerplate. It has no boilerplate to the point that you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold for example `onLoading`, `onLoaded`, `onError` states. `states_rebuilder` automatically manages these asynchronous statuses and exposes the `isIdle`,` isWaiting`, `hasError` and` hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic.

>With `states_rebuilder`, you write business logic without bearing in mind how the user interface would interact with it.

## UI logic

With `states_rebuilder`, you write your user interface using StatelessWidget, and when you need a business logic class, you just inject a singleton of the class using the `Injector` widget and get it from any child widget using the `Injector.get` method.

The instance obtained using `Injector.get` is not reactive, it is the registered singleton of the pure dart class. To make a vanilla dart class reactive, just get it using the `Injector.getAsReactive` method.

<image src="assets/01-states_rebuilder__singletons.png" width="400"/>

The model obtained is of `ReactiveModel` type and it is observable in the context of observer pattern. Observer widgets can subscribe to it and the observable reactive model can notify them to rebuild.


To subscribe to a `ReactiveModel`, `states_rebuilder` offers `StateBuilder`, `StateWithMixinBuilder`, `WhenRebuilder`, `WhenRebuilderOr` and `OnSetStateListener` widgets.

To notify observers you call `setState` or `setValue` methods of an observable model.

<image src="assets/01-states_rebuilder_state_wheel.png" width="400"/>

With `states_rebuilder`, you can create as many `ReactiveModel`s as you want from the same object, so that you can surgically control the part of the widget tree to rebuild.

<image src="assets/01-states_rebuilder_new_reactive_model.png" width="400"/>

# Examples:

## Basics:
You are new to `states_rebuilder` this is right place to start from. The order is important:

* [**The simplest counter app :**](examples/001-flutter_default_counter_app) Default flutter counter app refactored using `states_rebuilder`. You will understand the concept of `ReactiveModel` and how to make a pure dart class reactive. You will see the use of `ReactiveModel.create`, `setValue`, `isIdle`, `isWaiting`, `hasData`, `hasError`, `onIdle`, `onWaiting`, `onError`, `onData`, `whenConnectionState`, `StateBuilder` and `WhenRebuilder`.
* [**Login form validation**](examples/002-form_validation_with_reactive_model) Simple form login validation. The basic `ReactiveModel` concepts are put into practice to make form validation one of the easiest tasks in the world. The concept of exposed model is explained here.
* [**counter app with flavors**](examples/003-async_counter_app_with_injector) Injector as dependency injection is used, and a counter app with two flavors is built. You will see the use of `Injector`, `Injector.get`, `Injector.getAsReactive`, `Inject.interface`, `Inject.env`, and `setState`.
* [**countDown timer**](examples/004-countdown_timer) This is a timer that ticks from 60 and down to 0. It can be paused, resumed or restarted. You see how to inject enumeration and how to make two reactive models interact. You will see the use of `OnSetStateListener`.
* [**double async counters**](examples/005-double_async_counter_with_error) Two counter that share the same model. You will see the use of tags to filter notifications and the concept of new reactive models to limit rebuild process. You will see `tag`, `filteredTags` and `asNew` 
* [**multi async counters**](examples/006-multi_async_counter_with_error) The is a solution of an imaginary and very tricky state management requirement. You will see how the concept of ReactiveModel can solve very difficult state management requirements. You will see How can Reactive singleton interact with new reactive models. You will use
 `joinSingleton`, `JoinSingleton.withCombinedReactiveInstances`, `joinSingletonToNewData`

## Architecture

* [**User posts and comments**](examples/007-clean_architecture_dane_mackier_app)  The app communicates with the JSONPlaceholder API, gets a User profile from the login using the ID entered. Fetches and shows the Posts on the home view and shows post details with an additional fetch to show the comments.

* [**firebase login** ](examples/008-clean_architecture_firebase_login) The app uses firebase for sign in. The user can sign in anonymously, with google account, with apple account or with email and password.

* [**firebase realtime database**](examples/010-clean_architecture__multi_counter_realtime_firebase) The app add, update, delete a list of counters from firebase realtime database. The app is built with two flavors one for production using firebase and the other for test using fake data base.

**Note that all of the above examples are tested. With `states_rebuilder`, testing your business logic is the simplest part of your coding time as it is made up of simple dart classes. On the other hand, testing widgets is no less easy, because with `states_rebuilder` you can isolate the widget under test and mock its dependencies.**

> [List of article about `states_rebuilder`](https://medium.com/@meltft/states-rebuilder-and-animator-articles-4b178a09cdfa?source=friends_link&sk=7bef442f49254bfe7adc2c798395d9b9)