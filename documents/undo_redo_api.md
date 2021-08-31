//OK
To activate the undo and redo of an immutable state, we define the history stack length using the `undoStackLength` parameter when injecting the state.

```dart
final todos = RM.inject(
    ()=> <String>[],
    undoStackLength: 8,
    ); 
```

* To check if the state can be undone use `model.canUndoState`, and to undo it use `model.undoState()`
* To check if the state can be redone use `model.canRedoState`, and to undo it use `model.redoState()`

Here is a simple example:

```dart
final counter = RM.inject(
  () => 0,
  //to activate the option of undoing redoing the state we have to set
  // the undo stack length
  undoStackLength: 8,
);


//This is a simple counter app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: OnReactive(() {
        return Text('${counter.state}');
      }),
    );
  }
}
```

# Testing:

```dart
void main() {
  testWidgets('undo and redo state works', (tester) async {
    await tester.pumpWidget(MyApp());
    //first build
    expect(find.text('0'), findsOneWidget);

    //Expect that initially, we can not undo or redo the state
    expect(counter.canUndoState, isFalse);
    expect(counter.canRedoState, isFalse);

    //first increment
    counter.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    //Now as the state change, we can undo the state but
    //still we can not redo it.
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);

    //Second increment
    counter.state++;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    //Again, we can undo the state but
    //still we can not redo it.
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);

    //First call of undoState
    counter.undoState();
    await tester.pump();

    //the state is back to the last state and widget is refreshed
    expect(find.text('1'), findsOneWidget);

    //We can continue undoState and we can redo the last undo
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isTrue);

    //Second call of undoState
    counter.undoState();
    await tester.pump();

    //The initial state
    expect(find.text('0'), findsOneWidget);

    //We can not undoState because stack is empty
    expect(counter.canUndoState, isFalse);
    //We can redo the undos
    expect(counter.canRedoState, isTrue);

    //First redo
    counter.redoState();
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    //We can both undo and redo
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isTrue);

    //First redo
    counter.redoState();
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    //We can undo but not redo
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);
  });

  testWidgets('Redo is reset when the counter is incremented', (tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('0'), findsOneWidget);

    //First increment
    counter.state++;
    await tester.pump();
    //Second increment
    counter.state++;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    //We can undo but not redo
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);
    
    //First undo
    counter.undoState();
    await tester.pump();
    //second undo
    counter.undoState();
    await tester.pump();

    expect(find.text('0'), findsOneWidget);

    expect(counter.canUndoState, isFalse);
    expect(counter.canRedoState, isTrue);

    //Third increment
    counter.state++;
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    //the can redo is false
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);
  });

  testWidgets('Only valid state are tracked', (tester) async {
    void _onPressed() {
      counter.setState((s) async {
        await Future.delayed(Duration(seconds: 1));
        return counter.state + 1;
      });
    }

    await tester.pumpWidget(MyApp());
    expect(find.text('0'), findsOneWidget);
    //First increment
    _onPressed();
    await tester.pump();
    //counter is in the waiting state
    //This state is ignored for undo / redo
    expect(counter.isWaiting, isTrue);

    //after one second
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    ////First increment
    _onPressed();
    await tester.pump();
    expect(counter.isWaiting, isTrue);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    //After two async increment we can undo state but not redo it
    expect(counter.canUndoState, isTrue);
    expect(counter.canRedoState, isFalse);

    //First undo
    counter.undoState();
    await tester.pump();
    //counter is back to one not the waiting state
    expect(find.text('1'), findsOneWidget);

    //Second udo
    counter.undoState();
    await tester.pump();
    //The initial state
    expect(find.text('0'), findsOneWidget);
  });
}
```
