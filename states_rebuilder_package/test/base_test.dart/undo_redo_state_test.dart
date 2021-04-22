import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counter = RM.inject<int>(
  () => 0,
  onData: (_) {},
  undoStackLength: 8,
);

void main() {
  setUp(() {
    counter.dispose();
  });
  testWidgets(
    'WHEN undoStackLength is greater than 0'
    'THEN state is redone and done',
    (tester) async {
      //Expect that initially, we can not undo or redo the state
      expect(counter.canUndoState, false);
      expect(counter.canRedoState, false);

      expect(counter.state, 0);

      //first increment
      counter.state++;
      expect(counter.state, 1);

      //Now as the state change, we can undo the state but
      //still we can not redo it.
      expect(counter.canUndoState, true);
      expect(counter.canRedoState, false);

      //Second increment
      counter.state++;
      expect(counter.state, 2);

      //Again, we can undo the state but
      //still we can not redo it.
      expect(counter.canUndoState, true);
      expect(counter.canRedoState, false);

      //First call of undoState
      counter.undoState();

      //the state is back to the last state and widget is refreshed
      expect(counter.state, 1);

      //We can continue undoState and we can redo the last undo
      expect(counter.canUndoState, true);
      expect(counter.canRedoState, true);

      //Second call of undoState
      counter.undoState();

      //The initial state
      expect(counter.state, 0);

      //We can not undoState because stack is empty
      expect(counter.canUndoState, false);
      //We can redo the undos
      expect(counter.canRedoState, true);

      //First redo
      counter.redoState();

      expect(counter.state, 1);

      //We can both undo and redo
      expect(counter.canUndoState, true);
      expect(counter.canRedoState, true);

      //
      counter.redoState();

      expect(counter.state, 2);

      //We can undo but not redo
      expect(counter.canUndoState, true);
      expect(counter.canRedoState, false);
    },
  );

  testWidgets(
      'WHEN state is mutated'
      'THEN the redo stack is reset', (tester) async {
    expect(counter.state, 0);

    //First increment
    counter.state++;

    //Second increment
    counter.state++;

    expect(counter.state, 2);

    //We can undo but not redo
    expect(counter.canUndoState, true);
    expect(counter.canRedoState, false);

    //First undo
    counter.undoState();

    //second undo
    counter.undoState();

    expect(counter.state, 0);

    expect(counter.canUndoState, false);
    expect(counter.canRedoState, true);

    //Third increment
    counter.state++;

    expect(counter.state, 1);

    //the can redo is false
    expect(counter.canUndoState, true);
    expect(counter.canRedoState, false);
  });

  testWidgets(
      'WHEN state is mutated asynchronously'
      'THEN only state with hasData flag are add to the undo redo stack',
      (tester) async {
    void _onPressed() {
      counter.setState((s) async {
        await Future.delayed(Duration(seconds: 1));
        return counter.state + 1;
      });
    }

    expect(counter.state, 0);
    //First increment
    _onPressed();

    //counter is in the waiting state
    //This state is ignored for undo / redo
    expect(counter.isWaiting, true);

    //after one second
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 1);

    ////First increment
    _onPressed();

    expect(counter.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 2);

    //After two async increment we can undo state but not redo it
    expect(counter.canUndoState, true);
    expect(counter.canRedoState, false);

    //First undo
    counter.undoState();

    //counter is back to one not the waiting state
    expect(counter.state, 1);

    //Second udo
    counter.undoState();

    //The initial state
    expect(counter.state, 0);
  });

  testWidgets(
      'WHEN clearUndoStack is called'
      'THEN the undo redo history is cleared', (tester) async {
    expect(counter.state, 0);
    //First increment
    counter.state++;

    //Second increment
    counter.state++;

    expect(counter.state, 2);

    //We can undo but not redo
    expect(counter.canUndoState, true);
    expect(counter.canRedoState, false);

    //First undo
    counter.undoState();

    expect(counter.canUndoState, true);
    expect(counter.canRedoState, true);
    //
    counter.clearUndoStack();

    expect(counter.canUndoState, false);
    expect(counter.canRedoState, false);
  });
}
