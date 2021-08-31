states_rebuilder offers a build-in and simple debug logger. You can log state nonfiction and/or widget rebuild

## State Notification Log
Let's see the output of a simple counter app:

```dart
final counter = RM.inject(
    ()=> 0,
    debugPrintWhenNotifiedPreMessage : '',
);
```
this will be the output:(From state initializing to state disposing)
```
<int> : INITIALIZING... ==> isIdle : 0
<int> : isIdle : 0 ==> hasData: 1
<int> : hasData: 1 ==> hasData: 2
<int> : hasData: 2 ==> DISPOSING...
```

The pattern is : FROM (old state) ==> TO (new State) for each transition.

Notice `<int>`. It is the type of the injected state.

You can give the injected state a name to distinguish it in the log console:

```dart
final counter = RM.inject(
    ()=> 0,
    debugPrintWhenNotifiedPreMessage : 'counter',
);
```
this will be the output:
```
<counter> : INITIALIZING... ==> isIdle : 0
<counter> : isIdle : 0 ==> hasData: 1
<counter> : hasData: 1 ==> hasData: 2
<counter> : hasData: 2 ==> DISPOSING...
```
You can also define how the state is printed. This is useful if the state is for example a long list of items. It is not practical to print a list of 50 items in the console. You may want to only print the length of the list.


```dart
final counter = RM.inject<List<int>>(
    ()=> [],
    debugPrintWhenNotifiedPreMessage : 'counter',
    toDebugString: (state) => 'Length :${state.length}',
);
```
this is output:
```
<counter> : INITIALIZING... ==> isIdle : Length :0
<counter> : isIdle : Length :0 ==> hasData: Length :36
<counter> : hasData: Length :36 ==> hasData: Length :97
<counter> : hasData: Length :97 ==> DISPOSING...
```

## Widget Rebuild log
You can print log rebuild event using `debugPrintWhenRebuild`

```dart
final counter = RM.inject(() => 0);
class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: On(
          () => Text(counter.state.toString()),
        ).listenTo(
          counter,
          //Will print a message when this widget is rebuild
          debugPrintWhenRebuild: 'Body', 
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => counter.state++,
        ),
      ),
    );
  }
}
```

This will print :

```
flutter: INITIAL BUILD <Body>: SnapState<int>(isIdle : 0)
flutter: REBUILD <Body>: SnapState<int>(hasData: 1)
flutter: REBUILD <Body>: SnapState<int>(hasData: 2)
flutter: REBUILD <Body>: SnapState<int>(hasData: 3)
```