import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
//For navigation we have to defined the navigatorKey of the MaterialApp widget to
//use the RM.navigate.navigatorKey.

//For other side effects we have to get a valid BuildContext
//The idea is that states_rebuilder obtains a valid BuildContext from : (By order)
// * From the BuildContext of the invoked setState.
// * The last added StateBuilder (or WhenRebuild, WhenRebuildOR or Injector).

//variable used to test that a valid BuildContext is obtained inside the onData callback,
BuildContext contextFromOnData;

final model = RM.inject<int>(
  () => 0,
  onData: (data) {
    //Here is the right place to call side effects that uses the BuildContext
    contextFromOnData = RM.context;
    //Navigation
    // RM.navigate.to(Page1());

    //show Alert Dialog
    showDialog(
      context: RM.context,
      builder: (context) {
        return AlertDialog(
          content: Text('Alert'),
        );
      },
    );
  },

  //valid for onError, onWaiting, onDisposed and onInitialized
);
void main() {
  testWidgets(
    'If no states_rebuilder widget is used return null',
    (tester) async {
      final widget = MaterialApp(
        home: Text(model.state.toString()),
      );

      await tester.pumpWidget(widget);
      //No `BuildContext` is found.
      //you have to use one of the following widgets: `UseInjected`, `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOR` or `Injector
      expect(RM.context, null);
    },
  );

  testWidgets(
    'get BuildContext, navigatorState form setState',
    (tester) async {
      final widget = MaterialApp(
        //set the navigator key
        navigatorKey: RM.navigate.navigatorKey,
        home: Builder(
          builder: (context) {
            return Column(
              children: [
                Text(model.state.toString()),
                RaisedButton(
                  onPressed: () {
                    model.setState(
                      (s) => s + 1,
                      //Here we tell setStat to use this context for side effects.
                      context: context,
                      silent: true,
                    );
                  },
                  child: Text('Tap here'),
                )
              ],
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      //Tap on the RaisedButton
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();
      //We verify that when the onData is execute, it get the provided context
      expect(contextFromOnData, isNotNull);
      //we get navigator state
      expect(RM.navigate.navigatorState, isNotNull);
      //
      //Expect to see an AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );
  testWidgets(
    'get BuildContext, navigatorState from StateBuilder ',
    (tester) async {
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        home: model.rebuilder(() => Text(model.state.toString())),
      );

      await tester.pumpWidget(widget);

      expect(RM.context, isNotNull);
      expect(RM.navigate.navigatorState, isNotNull);
      //Scaffold.of() called with a context that does not contain a Scaffold.
      expect(() => RM.scaffoldShow.scaffoldState, throwsException);
    },
  );

  testWidgets(
    'get ScaffoldState ',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: model.rebuilder(
            () => Text(
              model.state.toString(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      expect(RM.context, isNotNull);
      expect(Scaffold.of(RM.context), isNotNull);
    },
  );
}
