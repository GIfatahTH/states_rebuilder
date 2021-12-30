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

- [02 (A): imperative_navigation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex02_imperative_navigation.dart)
   <br /><b> Description: </b>
  Refactoring example 01 into imperative approach.

- [02 (B): imperative & imperative_navigation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex02_imperative_navigation1.dart)
   <br /><b> Description: </b>
  To use Nav2 in a combination of declarative and imperative approaches, and remove a hidden page from stack.

- [03: Using builder_navigator](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex03_using_builder.dart)
  <br /><b> Description: </b>
  To use of the `InjectedNavigator.builder` method to wrap the app inside the body of the `Scaffold` and the `AppBar` that used a fixed navigation menu.

- [04: Deep linking naviation (Basic)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex04_to_deeply_1.dart)
  <br /><b> Description: </b>
  To know the difference between `InjectedNavigator.to` and `InjectedNavigator.toDeeply` methods.
  
- [05: Deep linking naviation (Normal)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex05_to_deeply_2.dart)
  <br /><b> Description: </b>
  The same as pervious example 04, but written using a `RouteWidget`

- [06: Deep linking naviation (Advanced)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex06_to_deeply_3.dart)
  <br /><b> Description: </b>
  The same as pervious example 04 & 05, it is using `RouteWidget` with static helper methods to decentralize the route logic from one place to belonging page widget.

- [07: Cyclic_Redirect (No fair)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex07_on_navigate_cyclic_redirect.dart)
  <br /><b> Description: </b>
  After reading of this example say no fear to cyclic redirect.

- [08: Redirection & Return Information](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex08_on_navigate_redirection_from.dart)
  <br /><b> Description: </b>
  This example is a show case that when a route redirect at another route, the latter will have all information about the route it is redirected from.

- [09: Authentication & Navigation Guards](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex09_on_navigate_signin.dart)
  <br /><b> Description: </b>
  This example will show you how to easily build up a redirection guard when auth status is invaild, it is all done by a tiny API `InjectedNavigator.onNavigate`.
  
- [10: Pop Validation & Navigation Guards](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex10_on_back_navigation.dart)
  <br /><b> Description: </b>
  This example will show you how to prevent leaving from a page without validating its data.

  
- [11: Tailor-made Page Transition Animation (Basic)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex10_on_back_navigation.dart)
  <br /><b> Description: </b>
  Look! There is a `transitionsBuilder` that can let you play the transition animation within 20 lines of code, whenever it's to a specific page or all the pages, those animations reusable.
  
  ```Dart
    final navigator = RM.injectNavigator(
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: Transform.rotate(
            angle: 1 - animation.value,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 1000),
      routes: { 
         '/specific page': (data) => RouteWidget(
            transitionsBuilder: RM.transitions.upToBottom(),
          ),
           /* ... Other routes */
      }
  ```
  
- [12: Re-implementation Page Transition Animation (Normal)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex10_on_back_navigation.dart)
  <br /><b> Description: </b>
  This example is funny, you will learn how to re-implementation a staggered animation demo example from ResoCoder.
  
    
- [13: 404 Unknown_Routes](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex13_unknown_routes.dart)
  <br /><b> Description: </b>
  Sometimes, you know, the application doesn't go to next page until crashed, Ladies and gentlemen, it's the right place for you to define 404.
  
- [14: Data Return from a Screen (Basic)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex14_return_data_from_screen.dart)
  <br /><b> Description: </b>
  Example of data return from a screen.
  
   
- [15: Nested Routes](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex15_nested_route.dart)
  <br /><b> Description: </b>
  Example of nested routes.
  
- [15: Nested Routes](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex15_nested_route.dart)
  <br /><b> Description: </b>
  Example of nested routes for dealing with multiple sub routes and their components.  
  
- [15: Books App](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex_006_5_navigation/lib/ex16_books_app.dart)
  <br /><b> Description: </b>
  Using states_rebuilder rewrite the flutter book app demo.
    
  
  
  
  


