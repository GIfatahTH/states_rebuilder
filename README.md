# `States_rebuilder` <!-- omit in toc --> 

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)

<p align="center">
    <image src="assets/Logo-Black.png" width="500" alt=''/>
</p>

<p align="justify">
States Rebuilder is an easy flutter state management solution that allows for clear and sharp separation of concern between the user interface (UI) logic and the business logic. The separation is clear and sharp to the point that the business logic is written with pure, vanilla, plain old dart classes without extending any external library-specific classes and without annotation or code generation.
</p>

 With `States_rebuilder`, you can easily: 
* Manage / Refactor the [Immutable](https://github.com/GIfatahTH/states_rebuilder/wiki/immutable-state-management) and [Mutable](https://github.com/GIfatahTH/states_rebuilder/wiki/mutable-state-management) state without affecting your UI code. 

* Work with [Future and Stream](https://github.com/GIfatahTH/states_rebuilder/wiki/futures_and_streams), it's "hot pluggable", without affecting your UI code.


* [Achieve injected dependencies](https://github.com/GIfatahTH/states_rebuilder/wiki/Asynchronous-Dependency-Injection) asynchronously (no Provider needed). &nbsp; 

* Invoke side effects without ❌`BuildContext`, like Dialogs, Navigate, SnackBars, and [many others](https://github.com/GIfatahTH/states_rebuilder/issues/129). 

* [Persist state](https://github.com/GIfatahTH/states_rebuilder/issues/134) to localStorage and restore it when the application is restarted.

* [Override the state](https://github.com/GIfatahTH/states_rebuilder/wiki/17-inherited_inject) for a particular widget tree branch (Widget-aware state).


# Documentation
* [**Official Documentation**](states_rebuilder_package)
