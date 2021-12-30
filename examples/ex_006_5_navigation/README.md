# ex_006_5_navigation

## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [installation guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 

[Introduction to API `RM.injectNavigator` and Migration from Nav1 to Nav2](https://github.com/GIfatahTH/states_rebuilder/issues/249)
<Br> </Br>

In this example, you will learn how to work on Flutter Navigation 2.0 (Nav2) more easily with states_rebuilder's API `RM.injectNavigator`.

Basic in use: [Quick demo of below code](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex14_return_data_from_screen.dart)

```Dart
final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const HomeScreen(),
    '/selection-screen': (data) => const SelectionScreen(),
  },
);
```

## Exploring Use-cases
Here it provides a bundle of use-cases of Nav2 from simple to complex:

- [01:_declarative_navigation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex01_declarative_navigation.dart)
   <br /><b> Description: </b>
  To use Nav2 remain in declarative approach.

- [02 (A): imperative_navigation (imperative)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex02_imperative_navigation.dart)
   <br /><b> Description: </b>
  Refactoring example 01 into imperative approach.

- [02 (B): imperative_navigation (declarative & imperative)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex02_imperative_navigation.dart)
   <br /><b> Description: </b>
  To use Nav2 in a combination of declarative and imperative approaches, and remove a hidden page from stack.

- [03: Using builder_navigator](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex03_using_builder.dart)
  <br /><b> Description: </b>
  To use of the `InjectedNavigator.builder` method to wrap the app inside the body of the `Scaffold` and the `AppBar` that used a fixed navigation menu.

- [04: Deep linking naviation (Basic)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex04_to_deeply_1.dart)
  <br /><b> Description: </b>
  To know the difference between `InjectedNavigator.to` and `InjectedNavigator.toDeeply` methods.
  
- [05: Deep linking naviation (RouteWidget)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex05_to_deeply_2.dart)
  <br /><b> Description: </b>
  The same as pervious example 04, but written using a `RouteWidget`

- [06: Deep linking naviation (RouteWidget advanced)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex06_to_deeply_3.dart)
  <br /><b> Description: </b>
  The same as pervious example 04 & 05, it is using `RouteWidget` with static helper methods to decentralize the route logic from one place to belonging page widget.

- [07: Cyclic_Redirect (No fair)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex07_on_navigate_cyclic_redirect.dart)
  <br /><b> Description: </b>
  After reading of this example say no fear to cyclic redirect.

- [08: Redirection and Return Information](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex08_on_navigate_redirection_from.dart)
  <br /><b> Description: </b>
  This example is a show case that when a route redirect at another route, the latter will have all information about the route it is redirected from.
  


