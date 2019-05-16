import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Flutter Demo",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: RootPage());
  }
}

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Root Page"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                  child: Text("Increase value"),
                  onPressed: () => counterBloc.updateValue()),
              RaisedButton(
                  child: Text("Go to next page"),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => HomePage()))),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false);
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text("Detail Page")),
        body: new MyBody(),
      ),
    );
  }
}

class MyBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Center(
      child: ListView(
        children: [
          StateBuilder(
              blocs: [counterBloc],
              builder: (_, hashtag) {
                print('yfhgj $hashtag');
                return Row(children: <Widget>[
                  Text("Count is ${counterBloc.value}"),
                  RaisedButton(
                    child: Text("Increase value"),
                    onPressed: () => counterBloc.updateValue1(hashtag),
                  )
                ]);
              }),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                  blocs: [counterBloc],
                  builder: (_, __) {
                    return Text("Count is ${counterBloc.value}");
                  },
                  tag: "value2"),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [counterBloc],
                builder: (_, __) {
                  return Text("Count is ${counterBloc.value}");
                },
              ),
              RaisedButton(
                child: Text("Increase value"),
                onPressed: () => counterBloc.updateValue(),
              )
            ],
          ),
        ],
      ),
    );
  }
}

final counterBloc = CounterBloc();

class CounterBloc extends StatesRebuilder {
  int value = 0;

  void updateValue() {
    value += 1;
    final s = DateTime.now().microsecondsSinceEpoch;
    rebuildStates();
    print(DateTime.now().microsecondsSinceEpoch - s);
  }

  void updateValue1(hastag) {
    value += 1;
    final s = DateTime.now().microsecondsSinceEpoch;
    rebuildStates(null, hastag);
    print(DateTime.now().microsecondsSinceEpoch - s);
  }
}
