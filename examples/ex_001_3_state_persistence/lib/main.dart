import 'package:ex_001_3_state_persistence/hive_imp.dart';
import 'package:ex_001_3_state_persistence/shared_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_imp.dart';

enum Env { fake, hive, sharedPreferences }

final env = Env.hive;

final localStore = RM.inject(
  () => {
    Env.fake: FakeStore(),
    Env.hive: HiveStorage(),
    Env.sharedPreferences: SharedPreferencesStore(),
  }[env]!,
);

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
    debugPrintOperations: true,

    //For primitive state (String, double, int , bool) you don't need to define fromJson and to Joson
    // fromJson: (j) => int.parse(j),
    // toJson: (s) => '$s',

    throttleDelay: 500,
  ),
);

void main() async {
  await RM.storageInitializer(localStore.state);
  return runApp(MaterialApp(
    home: MyHomePage(
      title: 'Persisted Counter',
    ),
  ));
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            //subscribe to counter injected model
            OnReactive(
              () => Text(
                '${counter.state}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            counter.state++;
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
