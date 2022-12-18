# ex_001_3_state_persistence


## State persistence

To Persist the state and retrieve it when the app restarts,
  ```dart
  final model = RM.inject<MyModel>(
      ()=>MyModel(),
    persist:() => PersistState(
      key: 'modelKey',
      toJson: (MyModel s) => s.toJson(),
      fromJson: (String json) => MyModel.fromJson(json),
      //Optionally, throttle the state persistence
      throttleDelay: 1000,
    ),
  );
  ```
  You can manually persist or delete the state
  ```dart
  model.persistState();
  model.deletePersistState();
  ```
  [🗎 See more detailed information about state persistence](https://github.com/GIfatahTH/states_rebuilder/wiki/state_persistence_api).
