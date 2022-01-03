# Example 001 - Sync mutation of global and local state

This catalog of examples is the first of a series of others, which intends to cover all the features of `states_rebuilder` from basic to very advanced. Therefore, it is hoped that you can get some inspirations from here and for the reference in the future. :+1:


## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [installation guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 


## Let's Go
In this first set of examples, you will learn how to work with global and local states. You will also learn how to mutate the state synchronously. [See here for more advanced async state mutation](./../ex002_00_async_global_and_local_state)

### Newbie Level :nerd_face:

- [01: Hello counter app](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_001_00_default_counter_app.dart)
   <br /><b> Description: </b>
  The default Flutter counter app rewritten using States_rebuilder. You will come across `ReactiveStatelessWidget` for the widget subscription in the injected state.

- [02: Hello Counter App - Ver. 2](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_002_00_default_counter_app.dart)
   <br />**Description:**
  The default Flutter counter app rewritten using states_rebuilder with some modification to explore more features of `ReactiveStatelessWidget`
   > ReactiveStateless widget can resister to any state consumed in its child widget provided that the child widget is not lazily loaded as in `ListView.builder` items
   > 
   > :heavy_exclamation_mark:	 Child widget declared with **const** modifier can not listen to parent `ReactiveStatelessWidget`

- [03: Hello Counter App - Ver. 3](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_003_00_default_counter_app.dart)
   <br />**Description:**
  The default Flutter counter app rewritten using states_rebuilder using `OnReactive` widget to limit the part of the widget that rebuilds.
  > When the widget is building, the injected `states` will look up the widget tree for the nearest `ReactiveStateless` or `OnReactive` widget to resister it.

- [04: Hello Counter App - Ver. 4](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_004_00_default_counter_app.dart)
   <br />**Description:**
  The default Flutter counter app rewritten using states_rebuilder using `OnBuilder` widget.
  > In contrast to `ReactiveStatelessWidget` which implicitly register to states consumed in the child widget tree, `OnBuilder` must explicitly register the state. `OnBuilder` can be used to optimize rebuild.


### Basic Level :monocle_face:

- [05: Global Injection and MVVM Architecture](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_005_00_model_view_view_model_counter_app.dart)
   <br />**Description:**
  Organize your cade and separate business logic from user interface logic. The logic class can only contain the logic related to a particular view; then it can be called ModelView or controller. Or, in other cases, the logic can be used in many views and other logic classes; then it can be called Bloc, Service, or whatever you want.

 - [06: Disposing of Global State](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_006_00_disposing_state.dart)
   <br />**Description:**
  Global states have a lifecycle, it is created when first used, and destroyed when no longer listen to.
   > A global state is a state that has only one active instance at a time. It can be used in the whole app or just for a part of the app.

 - [07: Local State]()
   <br />**Description:**
  The purpose of the following examples is to illustrate the concept of local state and how to distinguish it from global state.

     We are interested in using local state primarily in two scenarios:
      * List of independent states of the same type:
         - [:x: DO NOT: Directly use local state into each item from ListView](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_007_00_local_state_the_wrong_way.dart)
         - [:white_check_mark: DO: Allocate the independent state for each item by `Widget-wise Injection`](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_008_00_local_state_the_right_way.dart)
      * Set of independent states of the same type living in stacked routes:
         - [:x: DO NOT: Local states intreacted with outside routes](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_009_00_local_state_the_wrong_way.dart)
         - [:white_check_mark: DO: Should decare a global state with local state together](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_010_00_local_state_the_right_way.dart)
    > Local states are states of the same type living together but independent of each other.
    > 
    > Local state is created and injected in the widget tree based on the `InheritedWidget` principle.
   
 - [08: Undo and Redo Immutable State](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_011_00_undo_and_redo_state.dart)
   <br />**Description:**
  Undo and redo immutable state and undo queue cleaning.


### Intermediate Level :sunglasses:

 - [09: State Persistence - Primitives](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_012_00_state_persistance.dart)
   <br />**Description:**
  Example of state persistance of primitives using `SharedPreferences`.

 - [10: State Persistence - List of Objects](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_013_00_state_persistance_List_of_Object.dart)
   <br />**Description:**
  Example of state persistance of list of objects using `Hive`.

 - [11: State Interceptor](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_014_00_state_interceptor.dart)
   <br />**Description:**
  You can capture the state after it is calculated and just before state mutation. You can perform state validation or emit some side effects. Furthermore, you can also change how the state will be mutated. Also, State interceptor has [other important use in async state mutation]().

 - [13: Rebuild Optimization and Performance Boost](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_016_00_performance_optimization.dart)
   <br />**Description:**
  Optimize the rebuild process using `shouldRebuild` hook.

 - [14: Refactoring of The Weather App - Ver. 1](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_018_00_weather_app_example.dart)
   <br />**Description:**
    We will going to refactor The Weather App from ResoCoder using the new states_rebuilder's API. In this version we will define our only state flags (initial, loading, error, data)

 - [15: Refactoring of The Weather App - Ver. 2](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_018_01_weather_app_example.dart)
   <br />**Description:**
   Continuing with version 1, in this version we will define the predefined `flag` of sates_rebuilder (isIdle, isLoading, hasError, hasData)

 - [15: BloC Library Approach](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_019_00_migration_from_bloc_library.dart)
   <br />**Description:**
   By creating one of the examples from BloC library and using its approach of building apps with states_rebuilder. You will realize that it can happly keep **`mindset`** and **`code-style`** from BloC, all totheger applying into states_rebuilder.
