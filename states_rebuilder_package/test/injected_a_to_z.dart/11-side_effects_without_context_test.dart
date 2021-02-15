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
BuildContext? contextFromOnData;
NavigatorState? navigatorStateFromOnData;

final model = RM.inject<int>(
  () => 0,
  onData: (data) {
    //Here is the right place to call side effects that uses the BuildContext
    contextFromOnData = RM.context;
    navigatorStateFromOnData = RM.navigate.navigatorState;

    //Navigation
    // RM.navigate.to(Page1());

    //show Alert Dialog
    RM.navigate.toDialog(
      AlertDialog(
        content: Text('Alert'),
      ),
    );
  },

  onError: (e, s) {
    RM.scaffold.showSnackBar(
      SnackBar(content: Text(e.message)),
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
    'get BuildContext, navigatorState and showDialog',
    (tester) async {
      final widget = MaterialApp(
        //set the navigator key
        navigatorKey: RM.navigate.navigatorKey,
        home: Builder(
          builder: (context) {
            return Text(model.state.toString());
          },
        ),
      );

      await tester.pumpWidget(widget);

      //we get navigator state

      expect(RM.navigate.navigatorState, isNotNull);
      //
      model.state++;

      await tester.pump();
      //We verify that when the onData is execute, it get the provided context
      expect(contextFromOnData, isNotNull);
      expect(navigatorStateFromOnData, isNotNull);

      //Expect to see an AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );

  testWidgets(
    'get ScaffoldState from setStat ',
    (tester) async {
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        home: Scaffold(
          body: Column(
            children: [
              Text(
                model.state.toString(),
              ),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () {
                      model.setState(
                        (s) => throw Exception('An error!'),
                        context: context,
                        /*/*catchError: true*/*/
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.byType(RaisedButton));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('An error!'), findsOneWidget);
    },
  );

  testWidgets(
    'get ScaffoldState from StateBuilder ',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: On.data(
            () => Text(
              model.state.toString(),
            ),
          ).listenTo(model),
        ),
      );

      await tester.pumpWidget(widget);

      expect(RM.scaffold.scaffoldState, isNotNull);
      expect(RM.context, isNotNull);
    },
  );
}
