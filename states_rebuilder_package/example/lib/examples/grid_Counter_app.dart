import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel {
  int counter = 0;
  void increment() => counter++;
  Future<void> incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Injector(
        inject: [
          Inject<CounterModel>(
            () => CounterModel(),
            joinSingleton: JoinSingleton.withCombinedReactiveInstances,
          )
        ],
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Center(
              child: StateBuilder<CounterModel>(
                observe: () => RM.get<CounterModel>(),
                builder: (_, modelRM) {
                  if (modelRM.isWaiting) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      '${modelRM.joinSingletonToNewData ?? "Tap on A Counter"}',
                      style: TextStyle(fontSize: 30),
                    ),
                  );
                },
              ),
            ),
          ),
          body: CounterGrid(),
        ),
      ),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder<CounterModel>(
                    builder: (context, model) {
                      return GridItem(
                        count: model.isWaiting ? null : model.state.counter,
                        onTap: () {
                          if (i % 2 == 0)
                            model.setState((state) => state.increment(),
                                notifyAllReactiveInstances: true,
                                joinSingletonToNewData: () =>
                                    'I am Counter ${i + 1} I hold ${model.state.counter}');
                          else
                            model.setState(
                              (state) => state.incrementAsync(),
                              joinSingletonToNewData: () =>
                                  'I am Counter ${i + 1} I hold ${model.state.counter}',
                            );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final int count;
  final Function onTap;
  GridItem({this.count, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          border:
              Border.all(color: Theme.of(context).primaryColorDark, width: 4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: count != null
              ? Text(
                  "$count",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                  ),
                )
              : CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
        ),
      ),
      onTap: onTap,
    );
  }
}
