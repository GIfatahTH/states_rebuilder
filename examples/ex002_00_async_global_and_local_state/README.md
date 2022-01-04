# Example 002 - Async Global and Local State
This is the second part of a series of what I called example catalog.

## Getting Started
First, make sure you have installed states_rebuilder package, please check out the [installation guide](https://github.com/GIfatahTH/states_rebuilder/tree/master/states_rebuilder_package#getting-started-with-states_rebuilder). 

Secondly, this page assumes you've already read the first part [sync global and local state mutation](./../ex001_00_sync_global_and_local_state).


## Step-by-step
We will go form basic to advanced async global and local state mutation.

- [01: Async Hello counter app with custom status flag](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_001_00_async_counter_app_with_user_defined_flags.dart)
     <br />**Description:**
  We start by changing the default counter app by making the counter to increment asynchronously. We will use our custom defined state status flag (initial, data, error).

- [02: Async Hello counter app with states_rebuilder status flag](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_002_00_async_counter_app_with_state_rebuilder_flags.dart)
     <br />**Description:**
  This is the same async counter app of the previous example rewritten using predefined states_rebuilder flags (`isIdle`, `isWaiting`, `hasData`, `hasError`). In This example the mutation between status is done manually.

- [03: Async Hello counter app with states_rebuilder status flag](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_002_00_async_counter_app_with_state_rebuilder_full_api.dart)
     <br />**Description:**
  Here is the full power of states_rebuilder. states_rebuilder comes with predefined state status flags (`isIdle`, `isWaiting`, `hasData`, `hasError`). The mutation of the flags is done automatically without the loose of what to trigger and what to ignore. 

- [04: Weather app written using states_rebuilder async api](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_004_00_weather_app_example.dart)
     <br />**Description:**
  This is a rewrite of the weather app from ResoCoder tutorial using the new async states_rebuilder api.

- [05: Important not on async state mutation](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_005_00_important_notes_on_async_mutation.dart)
  <br />**Description:**
  Read some of the important notes about the limitation of async state mutation.

## Intermediate concepts 🧐

- [06: Working repositories and external service provider](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_006_00_repositories_and_service_provider.dart)
  <br />**Description:**
  Here are some of the best practices you should follow to deal with repositories and external service provider (`http` library is used as an example).

- [07: Working plugins](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_007_00_plugins_intialization.dart)
  <br />**Description:**
  Here are some of the best practices you should follow to deal with plugins that need to be initialized before utilization (`sembast` library is used as an example).

- [08: Disposing of async state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_008_00_disposing_state.dart)
  <br />**Description:**
  Example of state initialization and disposing of.

- [09: Using ObBuilder with async tasks](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_009_00_use_of_on_builder.dart)
  <br />**Description:**
  Example of how to use `ObBuilder` with async task mutation to control the widget rebuild.

- [10: Local async state (Local state in a listView)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_010_00_local_state_in_list_view.dart)
  <br />**Description:**
  Example of async local state in list of views.

- [11: Local async state (Local state in a route stack)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_011_00_stacked_local_state.dart)
  <br />**Description:**
  Example of async local state declared in many route pages.

- [12: Async state persistance (Future case)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_012_00_state_persistance_for_injected_future.dart)
  <br />**Description:**
  Example of Future state local persistance. Futures, once the state is persisted, will not triggered until the state is refreshed. 

- [13: Async state persistance (Stream case)](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_012_00_state_persistance_for_injected_future.dart)
   <br />**Description:**
  Example of stream state persistance. By default the state is persisted on stream data emission. Once the app restart the state starts with the last persisted state and the stream continues to emit data. 

## Advanced concepts 🧐

- [14: Local state connection with global state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_014_00_local_state_connection_with_global_state.dart)
   <br />**Description:**
  This is an example of a global state of list of items that creates a set of local state item. We can connect both so that when the local state (item) updates will trigger the global state of list of items to update. The opposite is true, we can set that when the global state update, all local state item will recreated.

- [15: Local state connection with global state](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_015_00_local_state_connection_with_global_state.dart)
   <br />**Description:**
  Here is the top performance of states_rebuilder. With almost the same code as the above example we can create local state from the TodosViewModel so that tow independent todos list in the same app.

- [16: Pessimistic async update](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_016_00_pessimistic_update.dart)
   <br />**Description:**
  In this example we will see how to pessimistically update a list of items. We will wait until the update is performed without error to update the UI. (state interceptor with future is used)

- [17: Optimistic async update](https://github.com/GIfatahTH/states_rebuilder/blob/dev/examples/ex002_00_async_global_and_local_state/lib/ex_017_00_optimistic_update.dart)
   <br />**Description:**
  In this example we will see how to optimistically update a list of items. We will update the ui with the new state instantly. If an error occurs, we will revert back to the last state before update. (state interceptor with stream is used)
