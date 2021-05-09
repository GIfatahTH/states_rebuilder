import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class NameRepository {
  Future<String> getNameInfo(String name) async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextInt(10) > 6) {
      throw Exception('Server Error');
    }
    return 'This is the info of $name';
  }
}

// Inject the repository, so it can be mocked in test.
//
// As the behavior of the repository is not predicted because it depends on a
// random number.
// In test we define a fake implementation of NameRepository, and injected it
// using : repository.injectMock(()=> FakeNameRepository()); and voila, just
// pump the widget and test it predictably. (See test folder)
final repository = RM.inject(() => NameRepository());

// create a name state and inject it.
final name = RM.inject<String>(
  () => '',
  debugPrintWhenNotifiedPreMessage: 'name',
);

final helloName = RM.inject<String>(
  () => 'Hello, ${name.state}',
  // helloName depends on the name injected model.
  // Whenever the name state changes the helloName will recalculate its
  // creation function and notify its listeners.
  //
  // helloName state status is a combination of its own state and the state
  // of the injected models that it depends on.
  // ex: if name is waiting => helloName is waiting,
  //     if name has error => helloName has error,
  //     if name has data => helloName state will be recalculated

  dependsOn: DependsOn(
    {name},
    // Do not recalculate until 400 ms has passed without any
    // further notification from name injected model.
    debounceDelay: 400,
  ),
  // Execute side effects while notify the state
  //
  // It take on On objects, it has many named constructor: On.data, On.error,
  // On.waiting, On.all and On.or
  onSetState: On.or(
    onWaiting: () => RM.scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('Waiting ...'),
            Spacer(),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
    onError: (err, refresh) => RM.scaffold.showSnackBar(
      SnackBar(
          content: Row(
        children: [
          Text('${err.message}'),
          IconButton(icon: Icon(Icons.refresh), onPressed: () => refresh()),
        ],
      )),
    ),
    // the default case. hide the snackbar
    or: () => RM.scaffold.hideCurrentSnackBar(),
  ),
  //Set the undoStackLength to 5. This will automatically
  // enable doing and undoing of the  state
  undoStackLength: 5,
  debugPrintWhenNotifiedPreMessage: 'helloName',
);
//Stream that emits the entered name letter by letter
final streamedHelloName = RM.injectStream<String>(
  () async* {
    final letters = name.state.trim().split('');
    var n = '';
    for (var letter in letters) {
      await Future.delayed(Duration(milliseconds: 50));
      // yield the name letter by letter
      yield n += letter;
    }
  },
  onInitialized: (state, subscription) {
    // As the stream will start automatically on creation,
    // we use the onInitialized hook to pause it.
    subscription.pause();
  },
  middleSnapState: (snapState) {
    snapState.print(preMessage: 'streamedHelloName');
    //Here we change the state
    if (snapState.nextSnap.hasData) {
      return snapState.nextSnap
          .copyWith(data: snapState.nextSnap.data!.toUpperCase());
    }
  },
);
//
//
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // To navigate and show snackBars without the BuildContext, we define
      // the navigator key
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: Text('Hello world Example')),
        body: Column(
          children: [
            TextField(
              onChanged: (String value) {
                // state mutation
                name.setState(
                  (s) => repository.state.getNameInfo(value),
                  // You can debounce from here so that the getNameInfo method
                  // will not be invoked unless 400ms has passed without and other
                  // setState call.

                  // debounceDelay: 400,
                );
                // After state mutation, notify helloName to recalculate
                // and rebuild
              },
            ),
            Spacer(),
            Row(
              children: [
                On.data(
                  () => IconButton(
                    icon: Icon(Icons.arrow_left_rounded, size: 40),
                    onPressed: helloName.canUndoState
                        ? () => helloName.undoState()
                        : null,
                  ),
                ).listenTo(helloName),
                Spacer(),
                Center(
                  child: On.all(
                    // This part will be re-rendered each time the helloName
                    // emits notification of any kind of status (idle, waiting,
                    // error, data).
                    onIdle: () => Text('Enter your name'),
                    onWaiting: () => CircularProgressIndicator(),
                    onError: (err, refresh) => Row(
                      children: [
                        Text('${err.message}'),
                        IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () => refresh()),
                      ],
                    ),
                    onData: () => Text(helloName.state),
                  ).listenTo(helloName),
                ),
                Spacer(),
                On.data(
                  () => IconButton(
                    icon: Icon(Icons.arrow_right_rounded, size: 40),
                    onPressed: helloName.canRedoState
                        ? () => helloName.redoState()
                        : null,
                  ),
                ).listenTo(helloName),
              ],
            ),
            Spacer(),
            ElevatedButton(
              child: Text('Start Streaming'),
              onPressed: () {
                // Calling refresh on any injected will re-execute its creation
                // Function and notify its listeners
                streamedHelloName.refresh();
              },
            ),
            SizedBox(height: 20),
            On.data(
              //This will rebuild if the stream emits valid data only
              () => Text('${streamedHelloName.state}'),
            ).listenTo(streamedHelloName),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
