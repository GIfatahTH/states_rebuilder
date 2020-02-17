# `states_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)


states_rebuilder is a flutter state management solution that allows for clear and sharp separation of concern between the user interface (UI) logic and the business logic. The separation is clear and sharp to the point that the business logic is written with pure, vanilla, plain old dart class without extending any external library specific classes and without annotation or code generation.

states_rebuilder is a Flutter state management solution that allows for a clear and sharp separation of concerns between the user interface (UI) logic and the business logic. The separation is so clear and sharp that the business logic is written with the plain pure old vanilla dart classes, without extending external-library specific classes and without annotation or code generation.

## Business logic

>The business logic classes are independent of any external library. They are independent even from state_rebuilder itself.

The only constraint imposed by states_rebuilder is to ensure that the methods supposed to be called from the user interface must not return anything; their only role is to mutate the state (aka fields) of the class.

Another advantage of states_rebuilder is that it has no boilerplate. It has no boilerplate to the point that you do not have to monitor the asynchronous state yourself. You do not need to add fields to hold `onLoading`, `onLoaded`, `onError` states. states_rebuilder automatically manages these asynchronous statuses and exposes the `isIdle`,` isWaiting`, `hasError` and` hasData` getters and `onIdle`, `onWaiting`, `onError` and `onData` hooks for use in the user interface logic.

>With states_rebuilder, you write business logic without having in mind, how the user interface would interact with it.

## UI logic

With states_rebuilder, you write your user interface using StatelessWidget, and when you need a business logic class, you just inject a singleton of the class using the `Injector` widget and get it from any child widget using the `Injector.get` method.

The instance obtained is not reactive, it is the registered singleton of the pure dart class. To make a vanilla dart class reactive, just get it using the `Injector.getAsReactive` method.

<image src="https://github.com/GIfatahTH/repo_images/blob/master/011-states_rebuilder_singltons.png" width="500"/>

The model obtained is of the `ReactiveModel` type and is observable. Observer widgets can subscribe to it and the observable reactive model can notify them to rebuild.


To subscribe to a `ReactiveModel`, states_rebuilder offers `StateBuilder`, `StateWithMixinBuilder`, `WhenRebuilder`, `WhenRebuilderOr` and `OnSetStateListener` widgets.

To notify observers you call `setState` or `setValue` methods of an observable model.

<image src="https://github.com/GIfatahTH/repo_images/blob/master/011-states_rebuilder_state_wheel.png" width="500"/>

With states_rebuilder, you can create as many `ReactiveModel` as you want from the same object, so that you can surgically control the part of the widget tree to rebuild.

<image src="https://github.com/GIfatahTH/repo_images/blob/master/011-states_rebuilder_new_reactive_model.png" width="500"/>

# Examples:

## Basics:
* *The simplest counter app :* Default flutter counter app refactored using states_rebuilder. You will understand the concept of `ReactiveModel` and how to make a pure dart class reactive. You will see the use of `ReactiveModel.create`, `setValue`, `isIdle`, `isWaiting`, `hasData`, `hasError`, `onIdle`, `onWaiting`, `onError`, `onData`, `whenConnectionState`, `StateBuilder` and `WhenRebuilder`.
* *Login form validation* Simple form login validation. The basic `ReactiveModel` concepts are put into practice to make form validation one of the easiest tasks in the world. The concept of exposed model is explained here.
* *counter app with flavors* Injector as dependency injection is used, and a counter app with two flavors is built. You will see the use of `Injector`, `Injector.get`, `Injector.getAsReactive`, `Inject.interface`, `Inject.env`, and `setState`.
* *countDown timer* This is a timer that ticks from 60 and down to 0. It can be paused, resumed or restarted. You see how to inject enumeration and how to make two reactive models interact. You will see the use of `OnSetStateListener`.
* *double async counters* Two counter that share the same model. You will see the use of tags to filter notifications and the concept of new reactive models to limit rebuild process. You will see `tag`, `filteredTags` and `asNew` 
* *multi async counters* The is a solution of an imaginary and very tricky state management requirement. You will see how the concept of ReactiveModel can solve very difficult state management requirements. You will see How can Reactive singleton interact with new reactive models. You will use
 `joinSingleton`, `JoinSingleton.withCombinedReactiveInstances`, `joinSingletonToNewData`

## Architecture

* *User posts and comments*  The app communicates with the JSONPlaceholder API, gets a User profile from the login using the ID entered. Fetches and shows the Posts on the home view and shows post details with an additional fetch to show the comments.

* *firebase login* The app uses firebase for sign in. The user can sign in anonymously, with google account, with apple account or with email and password.

* *firebase realtime database* The app add, update, delete a list of counters from firebase realtime database. The app is built with two flavors one for production using firebase and the other for test using fake data base.


