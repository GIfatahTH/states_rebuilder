// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
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

final model = RM.inject<int>(
  () => 0,
  sideEffects: SideEffects.onAll(
    onWaiting: null,
    onError: (e, s) {
      ScaffoldMessenger.of(RM.context!).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    },
    onData: (data) {
      //Here is the right place to call side effects that uses the BuildContext
      contextFromOnData = RM.context;

      //Navigation
      // RM.navigate.to(Page1());

      //show Alert Dialog
      showDialog(
        context: RM.context!,
        builder: (context) {
          return AlertDialog(
            content: Text('Alert'),
          );
        },
      );
    },
  ),

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
        home: OnReactive(
          () {
            return Text(model.state.toString());
          },
        ),
      );

      await tester.pumpWidget(widget);

      //we get navigator state

      //
      model.state++;

      await tester.pump();
      //We verify that when the onData is execute, it get the provided context
      expect(contextFromOnData, isNotNull);

      //Expect to see an AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );

  testWidgets(
    'get ScaffoldState from setStat ',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: OnBuilder(
              listenTo: model,
              builder: () {
                return Column(
                  children: [
                    Text(
                      model.state.toString(),
                    ),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () {
                            model.setState(
                              (s) => throw Exception('An error!'),
                              // context: context,//TODO check me
                              /**/
                            );
                          },
                          child: Text(''),
                        );
                      },
                    )
                  ],
                );
              }),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.byType(ElevatedButton));
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
          body: OnBuilder.data(
            listenTo: model,
            builder: (_) => Text(
              model.state.toString(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      expect(RM.context, isNotNull);
    },
  );
}
