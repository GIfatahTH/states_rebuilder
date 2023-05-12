import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
/*
* This is an example of plugins that need to be initialized before the main app
* widget is inflated.
*
* Injected plugins using RM.injectFuture can be mocked for test as they are 
* simple state pretending that they are already initialized.
*/

class SemBastLocalStorage {
  late final Database db;
  late final store = StoreRef.main();
  // the initialize method return and instance of SemBastLocalStorage after
  // initialization
  Future<SemBastLocalStorage> initialize() async {
    String dbPath = 'sample.db';
    DatabaseFactory dbFactory = databaseFactoryIo;
    db = await dbFactory.openDatabase(dbPath);
    return this;
  }

  Future<void> write<T>(String key, T value) async {
    await store.record('key').put(db, value);
  }

  Future<T> read<T>(String key) async {
    return (await store.record(key).get(db)) as T;
  }
}

// Use injected Future
//
// See test folder to see how it is mocked to test HomePage only
final semBastLocalStorageRM = RM.injectFuture(
  () => SemBastLocalStorage().initialize(),
);

void main() {
  // No need to initialize plugins here.
  runApp(const MyApp());
}

// Use TopStatelessWidget abstract class
class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  List<FutureOr<void>>? ensureInitialization() {
    return [
      // manually initialize the state
      semBastLocalStorageRM.initializeState(),
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      ),
      // Any future
      () async {
        await Future.delayed(const Duration(seconds: 1));
      }()
    ];
  }

  @override
  Widget? splashScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget? errorScreen(error, VoidCallback refresh) {
    return const Scaffold(
      body: Center(
        child: Text('Error'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  static final textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBuilder<String>.create(
        creator: () => '',
        builder: (rm) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                      ),
                    ),
                    TextButton(
                      onPressed: () => semBastLocalStorageRM.state.write(
                        'key',
                        textEditingController.text,
                      ),
                      child: const Text('Persist'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final value =
                        await semBastLocalStorageRM.state.read<String>('key');
                    rm.state = value;
                  },
                  child: const Text('Read stored Value'),
                ),
                const SizedBox(height: 12),
                if (rm.state.isNotEmpty) Text(rm.state),
              ],
            ),
          );
        },
      ),
    );
  }
}
