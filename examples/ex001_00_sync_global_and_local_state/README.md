# ex001_00_sync_global_and_local_state


## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [installation guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 

This catalog of examples is the first of a series of others, I intended to do to cover all the features of states_rebuilder from very basic to highly advanced.

These examples are intended to serve as tutorials and can be used for reference in the future.

# Sync mutation of global and local state


In this first set of examples, you will learn how to work with global and local states. You will also learn how to mutate the state synchronously. [See here for more advanced async state mutation](./../ex002_00_async_global_and_local_state)

## Newbie level

- [01: Hello counter app](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_001_00_default_counter_app.dart)
   <br /><b> Description: </b>
  The default Flutter counter app rewritten using States_rebuilder. You will come across `ReactiveStatelessWidget` for the widget subscription in the injected state.

- [02: Hello counter app version 2](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_002_00_default_counter_app.dart)
   <br /><b> Description: </b>
  The default Flutter counter app rewritten using states_rebuilder with some modification to explore more features of `ReactiveStatelessWidget`
  > * ReactiveStateless widget can resister to any state consumed in its child widget provided that the child widget is not lazily loaded as in `ListView.builder` items
  > * Child widget declared with const modifier can not listen to parent `ReactiveStatelessWidget`

- [03: Hello counter app version 3](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_003_00_default_counter_app.dart)
   <br /><b> Description: </b>
  The default Flutter counter app rewritten using states_rebuilder using `OnReactive` widget to limit the part of the widget that rebuilds.
  > states, when the widget is building, will look up the widget tree for the nearest `ReactiveStateless` or `OnReactive` widget to resister it.

- [04: Hello counter app version 4](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_004_00_default_counter_app.dart)
   <br /><b> Description: </b>
  The default Flutter counter app rewritten using states_rebuilder using `OnBuilder` widget.
  > In contrast to `ReactiveStatelessWidget` which implicitly register to states consumed in the child widget tree, `OnBuilder` must explicitly register the state. `OnBuilder` can be used to optimize rebuild.
  

## Basic level

- [05: Global injection and MVVM architecture](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_005_00_model_view_view_model_counter_app.dart)
   <br /><b> Description: </b>
  Organize your cade and separate business logic from user interface logic. The logic class can only contain the logic related to a particular view; then it can be called ModelView or controller. Or, in other cases, the logic can be used in many views and other logic classes; then it can be called Bloc, Service, or whatever you want.

 - [06: Disposing a global state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_006_00_disposing_state.dart)
   <br /><b> Description: </b>
  Global states have a lifecycle, it is created when first used, and destroyed when no longer listen to.
  > * A state never listened to, never disposed of.
  > * A global state is a state that has only one active instance at a time. It can be used in the whole app or just for a part of the app.

 - [07: Local state]()
   <br /><b> Description: </b>
  The purpose of the following examples is to illustrate the concept of local state and how to distinguish it from global state.

  We are interested in using local state primarily in two scenarios:
  * List of independent states of the same type:
    - [Example of list of local state create; the wrong way.](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_007_00_local_state_the_wrong_way.dart)
    - [Example of list of local state create; the right way.](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_008_00_local_state_the_right_way.dart)
  * Set of independent states of the same type living in stacked routes:
    - [Example of local state created in different routes; the wrong way](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_009_00_local_state_the_wrong_way.dart)
    - [Example of local state created in different routes; the wrong way](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_010_00_local_state_the_right_way.dart)

    > Local states are states of the same type living together but independent of each other.

    > Local state is created and injected in the widget tree based on the `InheritedWidget` principle.
   
 - [08: Undo and redo immutable state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_011_00_undo_and_redo_state.dart)
   <br /><b> Description: </b>
  Undo and redo immutable state and undo queue cleaning.


## Intermediate level

 - [09: state persistence - primitives](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_012_00_state_persistance.dart)
   <br /><b> Description: </b>
  Example of state persistance of primitives using `SharedPreferences`.

 - [10: state persistence - list of Objects](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_013_00_state_persistance_List_of_Object.dart)
   <br /><b> Description: </b>
  Example of state persistance of list of objects using `Hive`.

 - [11: state interceptor](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_014_00_state_interceptor.dart)
   <br /><b> Description: </b>
  You can capture the state after it is calculated and just before state mutation. You can perform state validation or emit some side effects. Furthermore, you can also change how the state will be mutated. [state interceptor has other important use in async state mutation]().

 - [13: Rebuild optimization and performance boost](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_016_00_performance_optimization.dart)
   <br /><b> Description: </b>
  Optimize the rebuild process using `shouldRebuild` hook.

 - [14: The weather app from ResoCoder tutorial - version 1](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_018_00_weather_app_example.dart)
   <br /><b> Description: </b>
    The weather app rewritten using the new states_rebuilder api. In this version we will define our only state flags (initial, loading, error, data)

 - [15: The weather app from ResoCoder tutorial - version 2](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_018_01_weather_app_example.dart)
   <br /><b> Description: </b>
    The weather app rewritten using the new states_rebuilder api. In this version we will define the predefined flag of sates_rebuilder (isIdle, isLoading, hasError, hasData)

 - [15: BloC library approach](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex001_00_sync_global_and_local_state/lib/ex_019_00_migration_from_bloc_library.dart)
   <br /><b> Description: </b>
    We will create one of the examples of BloC library using its approach of building apps. You learn how to migrate an app written with Bloc to states_rebuilder.
