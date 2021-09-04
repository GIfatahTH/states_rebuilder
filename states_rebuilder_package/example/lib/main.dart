import 'package:example/i18n.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'name_repository.dart';

// Inject the repository, so it can be mocked in test.
//
// As the behavior of the repository is not predicted because it depends on a
// random number.
// In test we define a fake implementation of NameRepository, and injected it
// using : repository.injectMock(()=> FakeNameRepository()); and voila, just
// pump the widget and test it predictably. (See test folder)
final repository = RM.inject(() => NameRepository());

// create a name state and inject it.
final name = RM.inject(() => '');

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
      SnackBar(content: Text('${err.message}')),
    ),
    // the default case. hide the snackbar
    or: () => RM.scaffold.hideCurrentSnackBar(),
  ),
  //Set the undoStackLength to 5. This will automatically
  // enable doing and undoing of the  state
  undoStackLength: 5,
);
//Stream that emits the entered name letter by letter
final streamedHelloName = RM.injectStream<String>(
  () async* {
    if (name.state.isEmpty) {
      throw Exception(i18n.state.enterYourName);
    }
    final letters = name.state.trim().split('');
    var n = '';
    for (var letter in letters) {
      await Future.delayed(Duration(milliseconds: 50));
      // yield the name letter by letter
      yield n += letter;
    }
  },
  initialState: '',
  onInitialized: (state, subscription) {
    // As the stream will start automatically on creation,
    // we use the onInitialized hook to pause it.
    subscription.pause();
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
    return TopAppWidget(
      injectedI18N: i18n,
      builder: (context) {
        return MaterialApp(
          // To navigate and show snackBars without the BuildContext, we define
          // the navigator key
          navigatorKey: RM.navigate.navigatorKey,
          locale: i18n.locale,
          localeResolutionCallback: i18n.localeResolutionCallback,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const HomeWidget(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.of(context).helloWorldExample),
        actions: [
          OnReactive(
            () => DropdownButton<Locale>(
              value: i18n.locale,
              onChanged: (Locale locale) {
                i18n.locale = locale;
              },
              items: i18n.supportedLocales
                  .map(
                    (locale) => DropdownMenuItem<Locale>(
                      child: Text('$locale'),
                      value: locale,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      body: OnReactive(
        //One OnReactiveModel on top can detects all states it depends on, even
        //deeply nested in the widget tree provided that the widget is not loaded lazily
        //as inside the builder of ListView.builder.
        () => Column(
          children: [
            //For demo purpose, App is fractured to smaller widget.
            //Notes that widget are const,
            const TextFieldWidget(),
            const Spacer(),
            HelloNameWidget(), // Not const to make it rebuildable
            const Spacer(),
            const RaisedButtonWidget(),
            const SizedBox(height: 20),
            StreamNameWidget(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class RaisedButtonWidget extends StatelessWidget {
  const RaisedButtonWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(i18n.of(context).startStreaming),
      onPressed: () {
        // Calling refresh on any injected will re-execute its creation
        // Function and notify its listeners
        streamedHelloName.refresh();
      },
    );
  }
}

class HelloNameWidget extends StatelessWidget {
  const HelloNameWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_left_rounded, size: 40),
          onPressed:
              helloName.canUndoState ? () => helloName.undoState() : null,
        ),
        Spacer(),
        Center(
          child: helloName.onAll(
            // This part will be re-rendered each time the helloName
            // emits notification of any kind of status (idle, waiting,
            // error, data).
            onIdle: () => Text(i18n.of(context).enterYourName),
            onWaiting: () => CircularProgressIndicator(),
            onError: (err, refresh) => Text('${err.message}'),
            onData: (data) => Text(data),
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.arrow_right_rounded, size: 40),
          onPressed:
              helloName.canRedoState ? () => helloName.redoState() : null,
        ),
      ],
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}

class StreamNameWidget extends StatelessWidget {
  const StreamNameWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return streamedHelloName.onOrElse(
      onError: (err, refresh) => Text(
        err.message,
        style: TextStyle(color: Colors.red),
      ),
      //This will rebuild if the stream emits valid data only
      orElse: (data) => Text('$data'),
    );
  }
}

List<String> _products = [];
Future<List<String>> _fetchProduct() async {
  await Future.delayed(Duration(seconds: 1));
  return _products..add('Product ${_products.length}');
}

final products = RM.injectFuture(() => _fetchProduct());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => products.refresh(),
      child: products.futureBuilder(
        onWaiting: () => CircularProgressIndicator(),
        onError: (err) => Text('error : $err'),
        onData: (_) {
          return ListView.builder(
            itemCount: products.state.length,
            itemBuilder: (context, index) {
              return Text(products.state[index]);
            },
          );
        },
      ),
    );
  }
}
