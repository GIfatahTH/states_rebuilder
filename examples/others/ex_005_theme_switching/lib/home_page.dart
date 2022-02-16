import 'i18n.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'preference_page.dart';

final counter = 0.inj();

class HomePage extends StatelessWidget {
  const HomePage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.of(context).home),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to the PreferencePage
              print(RM.navigate.navigatorKey.currentState);
              print(Navigator.of(context));
              RM.navigate.to(const PreferencePage());
              // RM.navigate.navigatorKey.currentState!.push(
              //     MaterialPageRoute(builder: (_) => const PreferencePage()));
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          child: OnReactive(
            () => Text(
              i18n.of(context).counterTimes(counter.state),
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => counter.state++,
      ),
    );
  }
}
