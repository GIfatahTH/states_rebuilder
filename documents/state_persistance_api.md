//OK
With states_rebuilder, you can persist some of the app’s state to localStorage and restore it when the application is restarted.

To set states_rebuilder to store state, follow these steps:

## implement `IPersistStore`
`IPersistStore` is an abstract class to implement and override five methods with a localStorage service of your choice (SharedPreferences, Hive, ...),

> states_rebuilder does not have a localStorage provider by default. It is simply because: 
> * Depending on third party library increase in maintenance cost.
> * Almost all non-trivial applications must store data locally and use one of the localStorage plugins.
> * Writing a few lines of code for the whole application is not a heavy task.

Example of `sharedPreferences`:

```dart
class SharedPreferencesImp implements IPersistStore {
  SharedPreferences _sharedPreferences;
  
  @override
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  T read<T>(String key) {
    return _sharedPreferences.getString(key) as T;
  }

  @override
  Future<void> write<T>(String key, T value) {
    return _sharedPreferences.setString(key, value as String);
  }

  @override
  Future<void> delete(String key) async {
    return _sharedPreferences.remove(key);
  }

  @override
  Future<void> deleteAll() {
    return _sharedPreferences.clear();
  }
}
```

Example of `hive`:

```dart
class HiveImp implements IPersistStore {
 Box box;
@override
 Future<void> init() async {
 await Hive.initFlutter();
 box = await Hive.openBox('myBox');
 }
@override
 Object read(String key) {
 return box.get(key);
 }
@override
 Future<void> write<T>(String key, T value) async {
 return box.put(key, value);
 }
@override
 Future<void> delete(String key) async {
 return box.delete(key);
 }
@override
 Future<void> deleteAll() async {
 return box.clear();
 }
}
```


This is the hard part.

## Injection

```dart
final counter = RM.inject<int>(
  () => 0,
  persist: PersistState(
    key: 'counter1',
    toJson: (state) => '$state',//Optional for primitives
    fromJson: (json) => int.parse(json),//Optional for primitives
  ),
);
```
The `persist` parameter takes an instance of `PersistState` :
- `key`: is a String identifier of the state to be used in the `localStorage`.
- `toJson`: callbacks that expose the current state and return a `String` representation of the state.
- `fromJson`: Callback that exposes a `String` representation of the state and returns the parsed state.

`toJson` is a callback that exposes the current state and returns a String representation of the state. If it is not defined, it will be inferred for primitive:
* int: (int s)=> '$s';
* double: (double s)=> '$s';
* String: (String s)=> '$s';
* bool: (bool s)=> s? '1' : '0';
 
If it is not defined and the model is not primitive, it will throw and `ArgumentError`.
`fromJson` is a callback that exposes the String representation of the state and returns the parsed state. If it is not defined, it will be inferred for primitive:
* int: (String json)=> int.parse(json);
* double: (String json)=> double.parse(json);
* String: (String json)=> json;
* bool: (String json)=> json =='1';
If it is not defined and the model is not primitive, it will throw and `ArgumentError`.
`persistStateProvider` if not defined the default storage provider initialized in the main method will be used.


> We will see later with more complex objects.

## the UI:

```dart
void main() async {

  //Pass the IPersistStore you created to  states_rebuilder and wait for it to initialize.
  await RM.persistanceInitializer(SharedPreferencesImp());
  runApp(MyApp());
}
```
That all you need to do! Now states_rebuilder takes the state object and saves it to persisted storage whenever it changes. Then on app launch, it retrieves this persisted state and uses it.

## PersistOn:
The default behavior is to store the state whenever it changes. In some situations, this may not be the optimal choice.

states_rebuilder gives you two other choices:

* Persist the state one time when the state is disposed.
```dart
final counter = RM.inject<int>(
  () => 0,
  persist: PersistState(
    key: 'counter1',
    toJson: (state) => '$state',
    fromJson: (json) => int.parse(json),
    //Add this line
    persistOn: PersistOn.disposed,
  ),
);
```
* Persist the state manually.

```dart
final counter = RM.inject<int>(
  () => 0,
  persist: PersistState(
    key: 'counter1',
    toJson: (state) => '$state',
    fromJson: (json) => int.parse(json),
    //Add this line
    persistOn: PersistOn.manualPersist,
  ),
);
```
To persist the state use: 
```dart
counter.persistState()
```
## Throttling persistence:
To avoid overloading the localStorage provider when the state changes frequently, you can set a throttling delay:

```dart
final counter = RM.inject<int>(
  () => 0,
  persist: PersistState(
    key: 'counter1',
    toJson: (state) => '$state',
    fromJson: (json) => int.parse(json),
    //Add this line
    throttleDelay: 3000,//in a 3 seconds' window, one state is persisted (the last one).
  ),
);
```

In all case you can delete the persisted state using:
```dart
counter.deletePersistState()
```
or delete all :
```dart
counter.deleteAll()
```

to refresh the state to its initial value:
```dart
counter.refresh()
```


## More complex object:

No matter how complex the object is, the only requirement is that it must have `toJson` and `fromJson` methods (the naming is up to you):

For example, I used vsCode to generate this data class. You can use a serializable library for example:

```dart
class Counter {
  int count;
  Counter({
    this.count,
  });

  void increment() => count++;

  Map<String, dynamic> toMap() {
    return {
      'count': count,
    };
  }

  factory Counter.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Counter(
      count: map['count'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Counter.fromJson(String source) =>
      Counter.fromMap(json.decode(source));
}
```
to inject:

```dart
final counter = RM.inject<Counter>(
  () => Counter(0),
  persist: PersistState(
    key: 'counter1',
    toJson: (s) => s.toJson(),
    fromJson: (json) => Counter.fromJson(json),
  ),
);
```

## testing:

states_rebuilder, has a prebuilt mock that you can use in your test:

```dart
void main() async {
 await RM.persistanceInitializerMock();
}
```