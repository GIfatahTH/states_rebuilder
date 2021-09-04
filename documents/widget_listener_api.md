
# Table of Contents <!-- omit in toc --> 
- [listenTo](#listenTo)
    - [onSetState](#onSetState)
    - [onAfterBuild](#onAfterBuild)
    - [initState](#initState)
    - [dispose](#dispose)
    - [shouldRebuild](#shouldRebuild)
    - [watch](#watch)
- [listenTo (Extension of list of Injected state)](#listenTo-(Extension-of-list-of-Injected-state))
    - [The combined status (OnCombined)](#The-combined-status-(OnCombined))
    - [The exposed state](#The-exposed-state)
- [On.future](#On.future)
- [Child](#child) 
- [TopAppWidget](#TopAppWidget)
- [futureBuilder](#futureBuilder)
    - [future](#future)
    - [onWaiting](#onWaiting)
    - [onError](#onError)
    - [onData](#onData)
    - [dispose](#dispose)
    - [onSetState](#onSetState)
- [streamBuilder](#streamBuilder)
- [rebuilder](#rebuilder)
- [whenRebuilder](#whenRebuilder)
- [whenRebuilderOr](#whenRebuilderOr)


## listenTo

```dart
//Extension on `On` object
Widget On<Widget>((){ }).listenTo<T>(
    Injected<T> inject, {
    On<void>? onSetState, 
    On<void>? onAfterBuild, 
    void Function()? initState, 
    void Function()? dispose, 
    void Function(_StateBuilder<T>)? didUpdateWidget, 
    bool Function(SnapState<T>?)? shouldRebuild, 
    Object? Function()? watch, 
    Key? key
  }
)
```
From version 4.4.0 OnBuilder widget is introduced to replace `On<Widget>((){ }).listenTo`.

```dart
//Extension on `On` object
Widget OnBuilder(
    listenTo: injected,
    onBuilder: On((){ })),
    sideEffects: SideEffects(
        On<void>? onSetState, 
        On<void>? onAfterBuild, 
        void Function()? initState, 
        void Function()? dispose, 
    )
    bool Function(SnapState<T>?)? shouldRebuild, 
    Object? Function()? watch, 
    Key? key,
)
```

The `On<Widget>((){ }).listenTo` may be deprecated in further releases.

### On((){ })
It is the part that will render in the widget tree. `On` class has many named constructor that allows fro better control on when to rebuild the widget.
```dart
final model = RM.inject(()=> Model());

// in the widget tree.

//On() constructor: the widget is rebuild for each notification regardless the its state status
On(()=> MyWidget()).listenTo(model);


//On.data() constructor: the widget is rebuild only if notification has `hasData` state status
On.data(()=> MyWidget()).listenTo(model);


//On.waiting() constructor: the widget is rebuild only if notification has `isWaiting` or `hasData` state status
On.waiting(()=> MyWidget()).listenTo(model);

//On.error() constructor: the widget is rebuild only if notification has `hasError` or `hasData` state status
On.error((err, refresh)=> MyWidget()).listenTo(model);


//On.all() constructor: for each state status there is a corresponding widget to render
On.all(
    onIdle: ()=> Text('Idle'),
    onWaiting: ()=> Text('Waiting..'),
    onError: (err, refresh) => Text('Error'),
    onData: ()=> MyWidget(),
).listenTo(model);

//On.or() constructor: similar to On.all but state status callbacks 
// are optional with one required default one
On.or(
    onWaiting: ()=> Text('Waiting..'),
    or: => MyWidget(),
).listenTo(model);

//Used to listen to a future.
On.future<F>(
    onWaiting: ()=> Text('Waiting..'),
    onError: (error, refresher) => Text('Error'),//Future can be reinvoked
    onData: (data)=> MyWidget(),
).future(()=> anyKindOfFuture);

//This widget subscribe to the `stateAsync` of the injected model.
//This is a one-time subscription of the onWaiting and onError and 
//ongoing subscription of onData
On.future<F>(
    onWaiting: ()=> Text('Waiting..'),
    onError: (error, refresher) => Text('Error'),//Future can be reinvoked
    onData: (data)=> MyWidget(),
).listenTo(model);
```
### onSetState
Use for side effects to be called after notification and just before widget rebuild. It take an `On` object.
```dart
On(
 ()=> MyWidget()
).listenTo(
   model,
   onSetState: On.error(
       (err)=> //show snack bar or navigate to an other page
   )
);

```
### onAfterBuild
Similar to OnSetState but invoked after widget rebuild.
### initState
Callback to be invoked once the widget is inserted into the widget tree.
### dispose
Callback to be invoked once the widget is removed from the widget tree.
### shouldRebuild
Callback that returns a bool value to control the widget rebuild.
### watch
Callback that returns an object and only if its value changes that the rebuild proceeds.

## listenTo (Extension of list of Injected state)
```dart
Widget OnCombined<T, Widget>((T){}).listenTo<T>({
    OnCombined<T, void>? onSetState, 
    OnCombined<T, void>? onAfterBuild, 
    void Function()? initState, 
    void Function()? dispose, 
    void Function(_StateBuilder<T>)? didUpdateWidget, 
    bool Function()? shouldRebuild, 
    Object? Function()? watch, 
    Key? key,
 }
)
```
You can listen to a list of Injected state and expose a combined state of them.
```dart
OnCombined.all(
    onWaiting: ()=> Text('Waiting..'),//if any is waiting
    onError: (err, refresh) => Text('Error'),//if any has error
    onIdle: ()=> Text('Idle'),//if any is idle
    onData: ()=> MyWidget(),// if all have data
).listenTo(
  [model1, model2, model3],
   onSetState: On.error(//If any has error
        (err, refresh)=> //show snack bar or navigate to an other page
    ),
),
```
### The combined status (OnCombined)

Notice that the state status callbacks are of type `OnCombined` and not `On`. This is to highlight that the state status callback is called depending on the combined state states of all the injected models. 

This is the logic of state status combination:
* **isWaiting has the first priority**: If any of the injected models is in the waiting status, the combined status will be waiting.
* **hasError has the second priority**: If none of the injected states is in the waiting status and if any of the injected states has an error, the combined status will be hasError.
* **isIdle has the third priority**: If none of the injected states is in the waiting status nor the error status, and if any of the injected states are idle, the combined status will be isIdle.
* **hasData has the last priority**: If all injected states have data then the combined state status will have onData status.

### The exposed state
`OnCombined((state){})`, `OnCombined.data((state){})`, `onData: (state){}` and `or: (state){}` constructors exposes a combined state of the list of injected state.

```dart
final Injected<String> stringInj = ''.inj();
final Injected<int> intInj = 0.inj();
final Injected<bool> boolInj = false.inj();
OnCombined.data(
    (state){
    //1- First case: (T is dynamic or Object)
    //See in the onSetState parameter above

    //2- Second case: (T is defined)

    //If T is defined thant the exposed state will be the first state 
    //of type T in the list of injected states

    //Example: if T is String

    //if stringInj changes and emits a notification:
        print(state is String) // will print true

        //ex: if intInj changes and emits a notification:
        print(state is String) // will print true

    //ex: if boolInj changes and emits a notification:
        print(state is String) // will print true

    }
).listenTo(
    [stringInj, intInj, boolInj],
    onSetState: OnCombined(
        (state){
          //1- First case: (T is dynamic or Object)

         //If the generic type is not defined (dynamic or Object)
         ///state will be the state of the model that is sending the 
         // notification

         //ex: if stringInj changes and emits a notification:
         print(state is String) // will print true

         //ex: if intInj changes and emits a notification:
         print(state is int) // will print true

        //ex: if boolInj changes and emits a notification:
         print(state is bool) // will print true

        //2- Second case: (T is defined)
        //See in the child parameter bellow

        }
    ),
  ),
)
```

## On.future
### On.future( ... ).future()
```dart
 ///To listen to any future
 On.future<T>({
     required Widget Function()? onWaiting, 
     //In cas of error the future can be re-invoked
     required Widget Function(dynamic, void Function() refresh)? onError, 
     required Widget Function(T data) onData
     }).future(
        Future<T> Function() future, {
        void Function()? dispose, 
        On<void>? onSetState, 
        Key? key
      }
    );
```
Example::
```dart
onFuture(
    onWaiting: ()=> CircularProgressIndicator(),
    onError: (dynamic error, void Function() refresh){
        return Column(
            children: [
                Text(error.message),
                RaisedButton(
                    child: Text('Refresh'),
                    onPressed: ()=> refresh(),
                )
            ]
        )
    },
    onData: (data)=> Text('data');
).future(()=> Future.delayed(Duration(seconds:1)), ()=> 'Data');
```
Here once the widget is inserted into the widget tree, it displays a `CircularProgressIndicator` for one second, and if the future resolves successfully a text showing the data is displayed.

In case when the future fails, the error message is displayed, with a `RaisedButton` used to refresh and reinvoke the future and display a `CircularProgressIndicator` while waiting for the future .

### On.future( ... ).listenTo()
```dart
 ///To listen to an injected state
 On.future<T>({
     //onWaiting and onError are one-time listeners.
     required Widget Function()? onWaiting, 
     //In cas of error the future can be re-invoked
     required Widget Function(dynamic, void Function() refresh)? onError, 
     //onData continues listening to the injected model
     required Widget Function(T data) onData
     }).listenTo(
        Injected<T> injected, {
        void Function()? dispose, 
        On<void>? onSetState, 
        Key? key
      }
    );
```

Example :

```dart
final model = RM.injectFuture(()=> ...);
On.future(
    onWaiting: ()=> CircularProgressIndicator(),
    onError: (dynamic error, void Function() refresh){
        return Column(
            children: [
                Text(error.message),
                RaisedButton(
                    child: Text('Refresh'),
                    onPressed: ()=> refresh(),
                )
            ]
        )
    },
    onData: (data)=> Text('data');
).future(()=> model.stateAsync);
```
`onWaiting` and` onError` are invoked once after creating the widget. Then they lose connection with the injected state.

`onData` continues to listen for the injected state and rebuilds itself if the injected state issues a notification with the onData state.

## Child
Child widget is used in combination of other listener widgets to control the part of sub widget tree to rebuild.

```dart
Child(
  (child) => On(
      () => Colum(
          children: [
              Text('model.state'), // This part will rebuild
              child, //This part will not rebuild
          ],
      ),
  ).listenTo(model),
  child: WidgetNotToRebuild(),
);
```

## futureBuilder
```dart
Widget futureBuilder<F>({
    Future<F>? Function(T?, Future<T>)? future, 
    required Widget Function()? onWaiting, 
    required Widget Function(dynamic)? onError, 
    required Widget Function(F) onData, 
    void Function()? dispose, 
    On<void>? onSetState, 
    Key? key
 }
)
```
`futureBuilder` listens to a future from the injected state and exposes callbacks to handle waiting, error, data state status.

It is important to notice that it listens to a future from the injected state and not to the injected state. Let's see the difference with this example:

```dart
final model = RM.injectFuture(()async=> ...);

//1- First widget
// listen using futureBuilder
//listen to the future of the state
model.futureBuilder(
    onWaiting: ()=> ..,
    onError: (error)=> ..
    onData: (data)=>...
)

//2- Second widget
//Listen using listenTo
//Listen to the state
On.all(
    onWaiting: ()=> ..,
    onError: (err, refresh)=> ..
    onData: (data)=>...
).listenTo(model)
```
Both ways of listening using `futureBuilder` (first widget) or `listenTo` (second widget) give the same result (Displaying a waiting widget the data or error widget).

The difference is when the state of the model is mutated the second widget will rebuild but the first widget (`futureBuilder`) will not rebuild.

For example, if we call the `refresh` method:
```dart
model.refresh();

//The first widget (futureBuilder) will not be affected

//But the second widget (listen) will display a waiting widget 
//then a data or error widget
```
In `futureBuilder`, onWaiting an `onError` are required but can be null. If any of the is set to null, the `onData` will be called instead.
```dart
model.futureBuilder(
    onWaiting: ()=> ..,
    onError: null// Here on error is null
    onData: (data)=>...
)
// when the future ends will error, the `onData` will be invoked
```
### future
The future parameter is optional. 
- If the future is not given and the state is injected using `RM.injectFuture`, that the future will be the injected future.
- If the future is not given and the state is not injected using `RM.injectFuture` it will throw an `ArgumentError`
### onWaiting
The callback to be invoked if the future is waiting. If set to null, the `onData` will be called instead.
### onError
The callback to be invoked if the future ends with an error. If set to null, the `onData` will be called instead.
### onData
The callback to be invoked if the future ends with data.
### dispose
The callback to be involved when the widget is removed from the widget tree.
### onSetState
Used for side effects. It takes an `On` object.

## streamBuilder
```dart
Widget streamBuilder<S>({
    required Stream<S>? Function(T?, StreamSubscription<dynamic>?) stream, 
    required Widget Function()? onWaiting, 
    required Widget Function(dynamic)? onError, 
    required Widget Function(S) onData, 
    Widget Function(S)? onDone, 
    void Function()? dispose, 
    On<void>? onSetState, 
    Key? key
 }
)
```

Similar to futureBuilder but used for stream.
## rebuilder
```dart
Widget rebuilder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) 
```
Listen to the injected Model and ***rebuild only when the model emits a notification with new data***.

Exactly equivalent to :
```dart
On.data(
    () => builder()
).listenTo(
    model,
    initState: initState != null ? () => initState() : null,
    dispose: dispose != null ? () => dispose() : null,
    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
    watch: watch,
);
```
## whenRebuilder
```dart
Widget whenRebuilder({
    required Widget Function() onIdle,
    required Widget Function() onWaiting,
    required Widget Function() onData,
    required Widget Function(dynamic) onError,
    void Function()? initState,
    void Function()? dispose,
    bool Function()? shouldRebuild,
    Key? key,
  })

```
Listen to the injected Model and rebuild when it emits a notification.

Exactly equivalent to :
```dart
On.all(
   onIdle: onIdle,
   onWaiting: onWaiting,
   onError: onError,
   onData: onData,
).listenTo(
    model,
    initState: initState != null ? () => initState() : null,
    dispose: dispose != null ? () => dispose() : null,
    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
);
```
## whenRebuilderOr
```dart
Widget whenRebuilderOr({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic)? onError,
    Widget Function()? onData,
    required Widget Function() builder,
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) 
```
Listen to the injected Model and rebuild when it emits a notification.

Exactly equivalent to :
```dart
On.or(
    onIdle: onIdle,
    onWaiting: onWaiting,
    onError: onError,
    onData: onData,
    or: builder,
).listenTo(
    model,
    initState: initState != null ? () => initState() : null,
    dispose: dispose != null ? () => dispose() : null,
    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
    watch: watch,
);
```