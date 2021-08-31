//OK
# Table of Contents <!-- omit in toc --> 
- [**state mutation callback (fn)**](#state-mutation-callback-(fn)) 
- [**onSetState**](#onSetState) 
- [**onRebuildState**](#onRebuildState) 
- [**onData and onError**](#onData-and-onError) 
- [**catchError**](#catchError) 
- [**debounceDelay**](#debounceDelay) 
- [**throttleDelay**](#throttleDelay) 
- [**shouldAwait**](#shouldAwait) 
- [**skipWaiting**](#skipWaiting) 
- [**context**](#context)

To mutate the state of an injected state, we can:
* For immutable state:
```dart
model.state = newState;
```
* For state of type bool:
```dart
model.toggle();
//equivalents to :
model.state = !model.state;
```
* For any kind of state, whether immutable or mutable:
```dart
model.setState(
    (T state) => ....,
);
```

After the state is mutated, state listeners are notified to rebuild.

setState is also used for more options for state mutation. This is the setState API:

```dart
Future<T?> setState(
    dynamic Function(T)? fn, {
    On<void>? onSetState, 
    void Function()? onRebuildState, 
    void Function(T)? onData, 
    void Function(dynamic)? onError, 
    bool catchError = false, 
    int debounceDelay = 0, 
    int throttleDelay = 0, 
    bool shouldAwait = false, 
    bool skipWaiting = false, 
    BuildContext? context
  }
)
```



## state mutation callback (fn)
The positional parameter is a callback that will be invoked to mutate the state. It exposes the current state. It can have ant type of return including Future and Stream.

While calling the mutation callback, states_rebuilder checks the return type:
* If it is a sync object, the state is mutated and notification is emitted with `onData` status flag.
* If the return type is Future, a notification is emitted with `isWaiting` status flag, and the state waits for the result of the Future and once data is obtained, a notification is emitted with `onData` status flag.
* If the return is Stream, a notification is emitted with `isWaiting` status flag, and the state subscribe to the stream, and emits a notification with `onData` status flag each time a data is emitted.
* If an error is caught, a notification is emitted with `hasError` status flag and the `error` object.

## onSetState

Injected state, can be defined to handle side effect the time of injecting it. `onSetState` is called after notification emission and before widget rebuild.
example:
```dart
final model = RM.inject(
    ()=> Model(),
    onSetState: On.error(
        (err)=> //show snack bar
    )
)
```
The `onSetState` defined like this is considered as the default one. And when `setState` is called without defining its `onSetState` parameter, the latter `onSetState` will be invoked.

In some scenarios, one might want to define different side effects for a particular call of `setState`.

The `onSetState` defined in `setState` method, will override the default `onSetState` defined in `RM.injected`.

`onSetState` take an On object which has many named constructors:
```dart
// Called when notified regardless of state status of the notification
On(()=> print('on'));
// Called when notified with data status
On.data(()=> print('data'));
// Called when notified with waiting status
On.waiting(()=> print('waiting'));
// Called when notified with error status
On.error((err, refresh)=> print('error'));
// Exhaustively handle all four status
On.all(
  onIdle: ()=> print('Idle'), // If is Idle
  onWaiting: ()=> print('Waiting'), // If is waiting
  onError: (err, refresh)=> print('Error'), // If has error 
  onData:  ()=> print('Data'), // If has Data
)
// Optionally handle the four status
On.or(
  onWaiting: ()=> print('Waiting'),
  onError: (err, refresh)=> print('Error'),
  onData:  ()=> print('Data'),
  or: () =>  print('or')
)
```
Note that setState side effects will not override the default ones unless they have the same callback status.
example:
```dart
final model = RM.inject(
    ()=> Model(),
    onSetState: On.error(
        (err, refresh)=> ...
    )
);

//As the side effect here is for waiting status, it will not override
//the default side effect which is for error status.
model.setState(
    (state)=> ...,
    onSetState: On.waiting(
        ()=> ...
    )
)
```
## onRebuildState
onRebuildState is reserved for side effects you want to execute after state notification with onData status and after the rebuild of the widget.

## onData and onError

Used to handle side effects:
* `onError` is similar to `On.error`.
* `onData` is similar to `On.data`.

## catchError
Whether to catch the error or not. It is set automatically to true if there is any side effect that used On.error callback.

## debounceDelay:
The time in milliseconds that should be passed without and other call of setState to execute the mutation callback.

## throttleDelay:
The time in milliseconds within only one call of the mutation callback is allowed.

## shouldAwait
If set to true and if the state is waiting for an async task, the mutation callback is only after the async task ends with data.
## skipWaiting
If set to true, the `isWaiting` and `onWaiting` state status are ignored.

## context
Used to define the BuildContext to be used for side effects executed after this call of setState. In most cases you do not need to define it because BuildContext is available using `RM.context`.
