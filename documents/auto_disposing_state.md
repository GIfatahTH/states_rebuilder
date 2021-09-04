By default all injected states are autodisposed when no longer used.

By auto-disposing a state, we mean:
- Cancel any pending future.
- Close any open stream.
- Close running timer (in `autoSignOut`).
- Reset the state to its initial value.
- and clear all Iterable used internally.

In some cases, it is useful to prevent the state from auto disposing. To de so, we only set the autoDisposed to false:

```dart
final model = RM.inject(
    ()=>0,
    bool autoDisposeWhenNotUsed = false, 
)
```

In such a situation, it is preferable to dispose the state manually by calling `model.dispose` or `RM.disposeAll()` inside a `dispose` method of a `statefulWidget` or inside the `setUp` or `tearDown` callback of the widget test.

A more convenient way is to use the `TopAppWidget`, that is used on top of the `MaterialApp` widget.

```dart
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      didChangeAppLifecycleState: (state) {
        // for code to be executed depending on the life cycle of the app (in Android : onResume, onPause ...).
      },
      child: MaterialApp(
        home : ...
      ),
    );
  }
}
```

`TopAppWidget` will dispose all non-disposed state when it is disposed of.

Also `TopAppWidget` provides two handy hooks to handle appLifeCycleState and system locales change.