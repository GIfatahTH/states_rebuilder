//OK
`OnReactive` widget is a widget used to rebuild a part of the widget tree in response to state change.

`OnReactive` implicitly subscribes to injected ReactiveModels based on the getter `ReactiveModel.state` called during rebuild.

Example:

```dart
final counter1 = RM.inject(()=> 0) // Or just use extension: 0.inj()
final counter2 = 0.inj();
int get sum => counter1.state + counter2.state;

//In the widget tree:
Column(
    children: [
        OnReactive( // Will listen to counter1
            ()=> Text('${counter1.state}');
        ),
        OnReactive( // Will listen to counter2
            ()=> Text('${counter2.state}');
        ),
        OnReactive(// Will listen to both counter1 and counter2
            ()=> Text('$sum');
        )
    ]
)
```

Note that `counter1` and `counter2` are global final variable that holds the state. They are disposed automatically when not in use (have no listener).

You can scope the `counter1` and `counter2` variable and put them inside a class:

```dart
class CounterModel {
    final counter1 = RM.inject(()=> 0) // Or just use extension: 0.inj()
    final counter2 = 0.inj();
    int get sum => counter1.state + counter2.state;

    void increment1() => counter1.state++;
    void increment2() => counter2.state++;

    void asyncMethod() => counter1.setState((s) async => asyncRep())
}
```
Just instantiate a global instance of the `CounterModel` and use it throughout your app. The `CounterModel` instance is not a global state rather it acts like a container that contains the counter1 and counter2 states.

You can easily test the app and make sure the all states are reset to their initial state between tests.

```dart
final counterModel = CounterModel();
```
In the widget tree:
```dart
Column(
    children: [
        OnReactive( // Will listen to counter1
            ()=> Text('${counterModel.counter1.state}');
        ),
        OnReactive( // Will listen to counter2
            ()=> Text('${counterModel.counter2.state}');
        ),
        OnReactive(// Will listen to both counter1 and counter2
            ()=> Text('${counterModel.sum}');
        )
    ]
)
```

`OnReactive` can listen to any state called form its child widget tree, no matter how deep the widget tree is provided that the widget is not loaded lazily.

```dart
OnReactive(
    ()=> DeepWidgetTree(),
)

class DeepWidgetTree extends StatelessWidget{
    Widget builder (BuildContext context){
        return Column(
            children: [
                //Will look up the widget tree and subscribe (if not already subscribed) to the first found OnReactive widget
                Text('${counter1.state}'),
                AnOtherChildWidget();
            ]
        );
    }
}

class DeepWidgetTree extends StatelessWidget {
    Widget builder (BuildContext context){
        //Will look up the widget tree and subscribe (if not already subscribed) to the first found OnReactive widget
        return Text('${counter2.state}');
    }
}
```
`OnReactive` can not capture state consumed inside builder method of some lazily loaded widget such as `ListView.builder` and `TabViewPage`.

In any case OnReactive should be inserted deep in the widget tree to wrap the part we want to rebuild.


Inside `OnReactive `you can call any of the available state status flags (`isWaiting`, `hasError`, `hasData`, ...) or just use `onAll` and `onOrElse` methods:
```dart
OnReactive(
    ()=> {
        if(myModel.isWaiting){
            return WaitingWidget();
        }
        if(myModel.hasError){
            return ErrorWidget();
        }
        return DataWidget();
    }
)
//Or use onAll method:
OnReactive(
    ()=> {
        myModel.onAll(
            onWaiting: ()=> WaitingWidget(),
            onError: (err, refreshErr)=> ErrorWidget(),
            onDate: (data)=> DataWidget(),
        );
    }
)

//Or use onOrElse method:
OnReactive(
    ()=> {
        myModel.onOrElse(
            onWaiting: ()=> WaitingWidget(),
            orElse: (data)=> DataWidget(),
        );
    }
)
```

If you want to optimize widget rebuild and prevent some part of the child widget tree from rebuilding each time use `Child`, `Child2`, `Child3` widget.

```dart
Child(
  (child) => OnReactive(
      () => Colum(
          children: [
              Text('model.state'), // This part will rebuild
              child, //This part will not rebuild
          ],
      ),
  ),
  child: WidgetNotToRebuild(),
);
```



This is the full API of `OnReactive`:

```dart
OnReactive(
    (){
        //Widget to rebuild
    }, 
    sideEffects: SideEffects(
        initState: (){
            // Side effect to call when the widget is first inserted into the widget tree
        },
        dispose: (){
            // Side effect to call when the widget is removed from the widget tree
        },
        onSetState: (snapState){
            // Side effect to call when is notified to rebuild

            //if the OnReactive listens to many states, the exposed snapState is that of the state that emits the notification
        },
    )
    shouldRebuild: (oldSnap, newSnap){
        // return bool to whether rebuild the widget or not.

        //if the OnReactive listens to many states, the exposed snapState is that of the state that emits the notification
    },
    
    //Debug print an informative message when the widget is rebuild with the name of the state that has emitted the notification.
    debugPrintWhenRebuild: 'custom name',
    //Debug print an informative message when a state is added to the list of subscription.
    debugPrintWhenObserverAdd: 'custom name,
);
```


