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
              RM.navigate.to(const PreferencePage());
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          child: On(
            () => Text(
              i18n.of(context).counterTimes(counter.state),
              style: Theme.of(context).textTheme.display1,
            ),
          ).listenTo(counter),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => counter.state++,
      ),
    );
  }
}
