
# Table of Contents <!-- omit in toc --> 
- [**creator**](#creator) 
- [**initialState**](#initialState) 
- [**onInitialized and onDisposed**](#onInitialized-and-onDisposed) 
- [**onSetState**](#onSetState) 
- [**middleSnapState**](#middleSnapSate) 
- [**onWaiting, onError and onData**](#onWaiting,-onError-and-onData) 
- [**dependsOn**](#dependsOn) 
- [**undoStackLength**](#undoStackLength) 
- [**persist**](#persist) 
- [**autoDisposeWhenNotUsed**](#autoDisposeWhenNotUsed) 
- [**isLazy**](#isLazy) 
- [**debugPrintWhenNotifiedPreMessage**](#debugPrintWhenNotifiedPreMessage)

```dart
Injected<T> RM.inject<T>(
    T Function() creator, {
        T? initialState, 
        void Function(T)? onInitialized, 
        void Function(T)? onDisposed, 
        On<void>? onSetState, 
        SnapState<T> Function(MiddleSnapSate<T> ) middleSnapState,
        void Function()? onWaiting, 
        void Function(T)? onData, 
        void Function(dynamic, StackTrace?)? onError, 
        DependsOn<T>? dependsOn, 
        int undoStackLength = 0, 
        PersistState<T> Function()? persist, 
        bool autoDisposeWhenNotUsed = true, 
        bool isLazy = true, 
        String? debugPrintWhenNotifiedPreMessage
    }
)

//Similar to RM.inject, except that the creator returns Future<T>
Injected<T> RM.injectFuture<T>(
    Future<T> Function() creator, {
        T? initialState, 
        void Function(T)? onInitialized, 
        void Function(T)? onDisposed, 
        On<void>? onSetState, 
        SnapState<T> Function(MiddleSnapSate<T> ) middleSnapState,
        void Function()? onWaiting, 
        void Function(T)? onData, 
        void Function(dynamic, StackTrace?)? onError, 
        DependsOn<T>? dependsOn, 
        int undoStackLength = 0, 
        PersistState<T> Function()? persist, 
        bool autoDisposeWhenNotUsed = true, 
        bool isLazy = true, 
        String? debugPrintWhenNotifiedPreMessage
    }
)

//Similar to RM.inject, except that the creator returns Stream<T> and
//the onInitialized exposes the current StreamSubscription
Injected<T> RM.injectStream<T>(
    Stream<T> Function() creator, {
        T? initialState, 
        void Function(T, StreamSubscription)? onInitialized, 
        void Function(T)? onDisposed, 
        On<void>? onSetState, 
        SnapState<T> Function(MiddleSnapSate<T> ) middleSnapState,
        void Function()? onWaiting, 
        void Function(T)? onData, 
        void Function(dynamic, StackTrace?)? onError, 
        DependsOn<T>? dependsOn, 
        int undoStackLength = 0, 
        PersistState<T> Function()? persist, 
        bool autoDisposeWhenNotUsed = true, 
        bool isLazy = true, 
        String? debugPrintWhenNotifiedPreMessage
    }
)

//Similar to RM.inject, except that the creator is a Map<dynamic, FutureOr<T> Function()> 
Injected<T> RM.injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()>  creator, {
        T? initialState, 
        void Function(T)? onInitialized, 
        void Function(T)? onDisposed, 
        On<void>? onSetState, 
        SnapState<T> Function(MiddleSnapSate<T> ) middleSnapState,
        void Function()? onWaiting, 
        void Function(T)? onData, 
        void Function(dynamic, StackTrace?)? onError, 
        DependsOn<T>? dependsOn, 
        int undoStackLength = 0, 
        PersistState<T> Function()? persist, 
        bool autoDisposeWhenNotUsed = true, 
        bool isLazy = true, 
        String? debugPrintWhenNotifiedPreMessage
    }
)
```

RM.inject is used to inject primitives, enum or objects.
Example:
```dart
final counter = RM.inject<int>(()=> 0);
final model = RM.inject<Model>(()=> Model());
//For simple injection, you can use extensions
final counter = 0.inj();
final switcher = false.inj();
final model = Model().inj<Model>();
```

## creator
The **`creator`** parameter is a callback the is used to create the injected state. When `refresh` method is invoked on the injected state, the `creator` callback is re-executed to define the new state.
The `creator` callback is called lazily, that is, it will not be invoked at the time of the instantiating of the Injected state, but it will be called the first time the state is used.(see `isLazy` parameter below).

## initialState
Because of the null safety, the state can not be null. For this reason, the initial state before calling the `creator` is inferred by the library as follows 
* If the state is int the initial state is 0.
* If the state is double the initial state is 0.0.
* If the Sting is double the initial state is empty String.
* If the state is bool the initial state is false.
* If the state is not primitive the initial state is the first created instance.
Example:
```dart
final counter = RM.inject(()=> 10); // initialState is 0.
final model = RM.inject(()=> Model()); // the initial state is the instance created after invoking creator callback.
```
You have the choice to define the initial state of your choice using the `initialState` parameter.
For RM.injectFuture and RM.injectStream where the state is not defined synchronically. If the state is primitive then it is inferred by the library, in the other case the state can not be defined until the async task emits data. In this case you have either to define the initial state explicitly or to handle the waiting state status and not getting the state until is ready.
> If you try to get the state when it is not ready, `ArgumentError.notNull` is thrown

## onInitialized and onDisposed
The injected state has its lifecycle (created when first used and disposed of when no longer used). With `onInitialized` and `onDisposed` hooks you can handle side effects on state creation and destruction.
For `RM.stream`, `onInitialized` exposes the current `StreamSubscription`. It can be used to pause the subscription after initialization.
Example:
```dart
final stream = RM.injectStream<int>(
 ()=> Stream.periodic(Duration(seconds:1), (val)=> val),
 onInitialized: (state, subscription){
 //Pausing the subscription
 subscription.pause();
 }
);
//later on, we can restart the stream;
stream.subscription.start();
```

## onSetState
To handle side effects when the state is mutated and emits notification, you use `onSetState` parameter that takes an `On` object:
example:
```dart
final model = RM.inject(
 ()=> Model(),
 onSetState: On.all(
 onIdle: ()=> print('Idle'),
 onWaiting: ()=> print('Waiting…'),
 onError: (err) => print ('Error'),
 onData: () => // Navigate to …
 )
)
```
The `On` class has other named constructors:
```dart
// Called when notified regardless of state status of the notification
On(()=> print('on'));
// Called when notified with data status
On.data(()=> print('data'));
// Called when notified with waiting status
On.waiting(()=> print('waiting'));
// Called when notified with error status
On.error((error, refresh)=> print('error'));
// Exhaustively handle all four status
On.all(
 onIdle: ()=> print('Idle'), // If is Idle
 onWaiting: ()=> print('Waiting'), // If is waiting
 onError: (err, refresh)=> print('Error'), // If has error 
 onData: ()=> print('Data'), // If has Data
)
// Optionally handle the four status
On.or(
 onWaiting: ()=> print('Waiting'),
 onError: (err, refresh)=> print('Error'),
 onData: ()=> print('Data'),
 or: () => print('or')
)
```
Note that side effects defined here are the default side effects, they can be overridden for a particular call of `setState` method. See [setState API](set_state_api#onSetState).
Example:
```dart
final model = RM.inject(
 ()=> Model(),
 onSetState: On.error((err, refresh)...),
 onWaiting: ()=> print('Show snack bar…'),
 )
)
// The call of setState without onError handling will invoke the default On.error callback (showing a snack bar)
model.setState((s)=> …);
//But if On.error is defined for a setState, it will override the default definition, and show a dialog and not a snack bar
model.setState(
 (s)=> ..,
 onSetState:  On.error((err, refresh)...)
 onWaiting: ()=> print('Show dialog…'),
 )
)
```
## middleSnapState
This is a callback that is used to track the state's life and transitions. It exposes a `MiddleSnapState<T>` object and returns a `SnapState<T>`.

The `MiddleSnapState<T>` objects, holds a snap of the state before state calculation (called `currentSnap`) and a snap of the state after new calculation and just before state mutation.

It is the right palace to log some valuable information about the state for debugging purposes.

```dart
final model = RM.inject(
    ()=> Model(),
    middleSnapState: (middleSnap) {
        print(middleSnap.currentSnap); //snap state before calculation
        print(middleSnap.nextSnap); //snap state after calculation
        //
        if(middleSnap.nextSnap.hasError) {
            //Error and stackTraces can be sent to a an error tracking service
            print(middleSnap.nextSnap.error);
            print(middleSnap.nextSnap.stackTrace);
        }

        //
        middleSnap.print(); //Build-in logger

        ///If return nothing or return null, the state will be mutate to hold the nextSnap
    },
)
```
For more information about the build-in logger see [here](debugging)

Inside the middleSnapSate callback, you can change how the state will be mutated.
Here is an example of a count-down timer that counts from 60 to 0 seconds

```dart
final timer = RM.injectStream<int>(
  //stream emits 0, 1, 2, ... infinitely
  () => Stream.periodic(Duration(seconds: 1), (tick) => tick + 1),
  middleSnapState: (middleSnap) {
    if (middleSnap.nextSnap.data > 60) {
      //cancel subscription and return the currentSnap (holds 0)
      timer.subscription.cancel();
      return middleSnap.currentSnap;
    }
    return middleSnap.nextSnap.copyToHasData(
      // It will return a state of 60, 59, 58, ... 0
      60 - middleSnap.nextSnap.data,
    );
  },
)

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OnReactive(
            () => Text(timer.state.toString()),
          ),
        ),
      ),
    );
  }
}
```

This is another example of email field validation
```dart
final email = RM.inject<String>(
  () => '',
  middleSnapState: (middleSnap) {
    if (middleSnap.nextSnap.hasData) {
      if (!middleSnap.nextSnap.data.contains('@')) {
        return middleSnap.nextSnap.copyToHasError(
          Exception('Enter a valid Email'),
        );
      }
    }
  },
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: OnReactive(
          () => TextField(
            onChanged: (value) => email.state = value,
            decoration: InputDecoration(
              errorText: email.error?.message,
            ),
          ),
        ),
      ),
    );
  }
}
```

## onWaiting, onError and onData
Used to handle side effects:
* `onWaiting` is similar to `On.waiting`.
* `onError` is similar to `On.error`.
* `onData` is similar to `On.data`.

## dependsOn
An injected state can depend on one or more other injected states.
Example:
```dart
final stateA = RM.inject(()=> StateA());
final stateB = RM.injectFuture(()=> StateB().init());
final stateC = RM.inject(
 ()=> StateC( stateA: stateA, stateB: stateB),
 dependsOn: DependsOn(
 {stateA, stateB},
 //Option param
 shouldNotify: (stateC)=> someCondition
 debounceDelay:500 // in milliseconds
 throttleDelay: 500 // in milliseconds
 )
)
```
The `stateC` depends on `stateA` and `stateB`. This means that when any of `stateA` and `stateB` emits notification, the creator callback of `stateC` is re-invoked to calculate the new state and notify its listeners.
The state status of `stateC` is a combination of both state status of `stateA` and `stateC`:
* If `stateA` isWaiting and/or `stateB` isWaiting than `stateC` isWaiting;
* If `stateA` hasError and/or `stateB` hasError than `stateC` hasError;
* If `stateA` asData and `stateB` hasData than `stateC` hasData;
Optionally, `stateC` recalculation can be:
* stopped if `shouldNotify` callback return false.
* debounced with the time defined with `debounceDelay` parameter.
* throttled with the time defined with `throttleDelay` parameter.

## undoStackLength
If `undoStackLength` is defined, the state can be undone and/or redone.
* To check if the state can be undone use `model.canUndoState`, and to undo it use `model.undoState()`
* To check if the state can be redone use `model.canRedoState`, and to undo it use `model.redoState()`

## persist
To be able to persist the state you have first to implement the `IPersistStore` interface with a local storage provider of your choice.
This is an example of hive plugging:
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
The next step is to initialize the storage provider. In the main method:
```dart
 void main()async{
 WidgetsFlutterBinding.ensureInitialized();
 
 await RM.storageInitializer(HiveImp());
 runApp(MyApp());
 }
```
Now when injecting the state, we can set its storage setting using the `persist` parameter:
```dart
 final model = RM.inject<MyModel>(
   ()=>MyModel(),
   persist:() => PersistState(
   key: 'modelKey',
   toJson: (MyModel s) => s.toJson(),
   fromJson: (String json) => MyModel.fromJson(json),
   //Optionally, throttle the state persistance
   throttleDelay: 1000,
   //You can override the default storage provider
   persistStateProvider: AnotherPersistStateProvider()
   ),
 );
```

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

## autoDisposeWhenNotUsed
state is automatically disposed if no longer listen. If you want the state to be alive even if not used, you set `autoDisposeWhenNotUsed` to false.
You can manually dispose the state invoking : `model.dispose()`;

## isLazy
state is lazily initialized; it will not initialized until first used. If this is not the behavior you want to set `isLazy` to false.

## debugPrintWhenNotifiedPreMessage
To help you track the lifecycle of the state and debug your app, you can print an informative message to inform you when the state is initialized, notified and disposed.