//OK
With `ObBuilder` you can explicitly listen to one or many injected state.

```dart
OnBuilder(
    listenTo: myState,
    //called whenever myState emits a notification
    builder: () => Text('${counter.state}'),
    sideEffect: SideEffect(
        initState: () => print('initState'),
        onSetState: On(() => print('onSetState')),
        onAfterBuild: On(() => print('onAfterBuild')),
        dispose: () => print('dispose'),
    ),
    shouldRebuild: (oldSnap, newSnap) {
      return true;
    },
    debugPrintWhenRebuild: 'myState',
),


//Rebuild only when the myState emits notification with isData equals to true
OnBuilder.data(
    listenTo: myState,
    builder: (data) => Text('$data'),
),

//Handle all possible state status
OnBuilder.all(
    listenTo: myState,
    onIdle: () => Text('onIdle'),
    onWaiting: () => Text('onWaiting'),
    onError: (err, errorRefresh) => Text('onError'),
    onData: () => Text('{myState.state}'), 
),

//Handle all possible state status with orElse fallback for the undefined status.
OnBuilder.orElse(
    listenTo: myState,
    onWaiting: () => Text('onWaiting'),
    orElse: () => Text('{myState.state}'),
),
```

You can listen to many injected state using the `listenToMany` parameter.
In this case the OnBuilder will react and expose a combined state of all injected states

```dart
OnBuilder.all(
        listenToMany: [myState1, myState2],
        onWaiting: () => Text('onWaiting'), // Will be invoked if at least one state is waiting
        onError: (err, refreshError) => Text('onError'), // Will be invoked if at least one state has error
        onData: (data) => Text(myState.state.toString()), // Will be invoked if all states have data.
        sideEffect: SideEffect(
            initState: () => print('initState'),
            onSetState: On(() => print('onSetState')),
            onAfterBuild: On(() => print('onAfterBuild')),
            dispose: () => print('dispose'),
        ),

        /// shouldRebuild will take the oldSnap before mutation and the newSanp after mutation in the parameter
        shouldRebuild: (oldSnap, newSnap) {
        return true;
        },
        debugPrintWhenRebuild: '',
    ),
```

This is the logic of state status combination:
* **isWaiting has the first priority**: If any of the injected models is in the waiting status, the combined status will be waiting.
* **hasError has the second priority**: If none of the injected states is in the waiting status and if any of the injected states has an error, the combined status will be hasError.
* **isIdle has the third priority**: If none of the injected states is in the waiting status nor the error status, and if any of the injected states are idle, the combined status will be isIdle.
* **hasData has the last priority**: If all injected states have data then the combined state status will have onData status.


`OnBuilder<T>`, `OnBuilder<T>.data`, `OnBuilder<T>.all` and `OnBuilder<T>.orElse` constructors exposes a combined state of the list of injected state.

Example

```dart
final Injected<String> stringInj = ''.inj();
final Injected<int> intInj = 0.inj();
final Injected<bool> boolInj = false.inj();

OnBuilder<T>.data(
    listenToMany: [stringInj, intInj, boolInj],
    builder: (state){
       //1- First case: (T is dynamic or Object)
       //See in the onSetState parameter below
   
       //2- Second case: (T is defined)
   
       //If T is defined than the exposed state will be the first state 
       //of type T in the list of injected states
   
       //Example: if T is String
   
       //if stringInj changes and emits a notification:
           print(state is String) // will print true
   
       //ex: if intInj changes and emits a notification:
           print(state is String) // will print true
   
       //ex: if boolInj changes and emits a notification:
           print(state is String) // will print true
    }
    sideEffects: sideEffects(
        onSetState: (snap){
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
            //See in the builder parameter above
        }
    )
)
```

`OnBuilder` is equivalent to `On( ... ).listenTo(..)` widget:
```dart
OnBuilder.all(
    listenTo: counter,
    onWaiting: () => Text('onWaiting'),
    onError: (err, errorRefresh) => Text('onError'),
    onData: (data) => Text('{counter.state}'),
),
//is just equivalent to:
On.all(
    onWaiting: () => Text('onWaiting'),
    onError: (err, errorRefresh) => Text('onError'),
    onData: () => Text('{counter.state}'),
).listenTo(counter),
```

The latter form may be deprecated in later releases.


For each `OnBuilder` widget flavor there is method like equivalent:
```dart
//Widget-like
OnBuilder(
    listenTo: myState,
    builder: () => Text('${myState.state}'),
),

//Method-like
myState.rebuild(
    () => Text('{myState.state}'),
),
//
//Widget-like
OnBuilder.data(
    listenTo: myState,
    builder: (data) => Text('$data')),
),

//Method-like
myState.rebuild.onData(
    (data) => Text(data),
),

//Widget-like
OnBuilder.all(
    listenTo: myState,
    onIdle: () => Text('onIdle'),
    onWaiting: () => Text('onWaiting'),
    onError: (err, errorRefresh) => Text('onError'),
    onData: (data) => Text('{myState.state}'),
)

//Method-like    
myState.rebuild.onAll(
    onIdle: () => Text('onIdle'),
    onWaiting: () => Text('onWaiting'),
    onError: (err, errorRefresh) => Text('onError'),
    onData: (data) => Text('{myState.state}'),
),
//
//Widget-like
OnBuilder.orElse(
    listenTo: myState,
    onWaiting: () => Text('onWaiting'),
    or: (data) => Text('{myState.state}'),
),

//Method-like
myState.rebuild.onOrElse(
    onWaiting: () => Text('onWaiting'),
    orElse: (data) => Text('{myState.state}'),
),

//Widget-like
OnBuilder.orElse(
    listenTo: [myState1 , myState2],
    onWaiting: () => Text('onWaiting'),
    or: (data) => Text('$data'),
),

//Method-like
[myState1 , myState2].rebuild.onOrElse(
    onWaiting: () => Text('onWaiting'),
    orElse: (data) => Text('$data'),
),

```

For each specific Injected, such as `InjectedAnimation`, `InjectedAuth`, there is a dedication builder widget, `OnAnimationBuilder`, `OnAuthBuilder`.

The pattered is: `InjectedFoo` => `OnFooBuilder`

Example:
```dart
final myAnimation = RM.injectedAnimation();

///Widget like
OnAnimationBuilder(
    listenTo: myAnimation
    builder: (animate) {
        return Container(
            width: animate.fromTween((_) => Tween(begin: 0, end: 100)),
        );
    }
),

//Method-like
myAnimation.rebuild.onAnimation((animate) {
    return Container(
        width: animate.fromTween((_) => Tween(begin: 0, end: 100)),
    );
}),
```


If you want to optimize widget rebuild and prevent some part of the child widget tree from unnecessary rebuilding, use `Child`, `Child2`, `Child3` widget.

```dart
Child(
  (child) => OnBuilder(
      listenTo: model,
      builder: () => Colum(
          children: [
              Text('model.state'), // This part will rebuild
              child, //This part will not rebuild
          ],
      ),
  ),
  child: WidgetNotToRebuild(),
);
`