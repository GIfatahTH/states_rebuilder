# Example 003 - Dependent state management


This is the last set of example to master core state management using states_rebuilder. 

It is very important to see the last to parts before continuing here :
* [Sync state management]((./../ex001_00_sync_global_and_local_state))
* [Async state management]((./../ex002_00_async_global_and_local_state))

## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [installation guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 


- [01: Nested injected dependency](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex003_00_dependent_state_management/lib/ex_001_00_nested_repository_dependencies.dart)
   <br />**Description:**
  This example is a use case where a class depends on other plugins that are instantiated asynchronously. The class must wait until the plugins are ready before initialization.

- [02: Sync dependent state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex003_00_dependent_state_management/lib/ex_002_00_sync_dependent_model.dart)
   <br />**Description:**
  This is an example of a state the depends synchronously on other injected state. When the state of any of the latter changes, the dependent state should recalculate.

- [03: Async dependent state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex003_00_dependent_state_management/lib/ex_003_00_async_dependent_model.dart)
   <br />**Description:**
  This is an example of a state the depends asynchronously on other injected state. The status of the dependent state is the combination of the other state status.

- [04: todo app](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex003_00_dependent_state_management/lib/ex_003_00_async_dependent_model.dart)
   <br />**Description:**
  A todo app example that uses state dependence.