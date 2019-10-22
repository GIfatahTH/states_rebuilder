import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel {
  int counter = 0;
  increment1() => counter++;
  increment2() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Injector(
        inject: [Inject<CounterModel>(() => CounterModel())],
        builder: (_, __) => Scaffold(
          appBar: AppBar(),
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
                  Builder(builder: (context) {
                    final model =
                        Injector.getAsModel<CounterModel>(); // without context
                    return StateBuilder(
                      viewModels: [model],
                      tag: i % 2,
                      builder: (_, __) => GridItem(
                        count: model.snapshot.connectionState ==
                                ConnectionState.waiting
                            ? null
                            : model.state.counter,
                        onTap: () {
                          if (i % 2 == 0)
                            model.setState((state) => state.increment1(),
                                tags: [i % 2]);
                          else
                            model.setState((state) => state.increment2(),
                                tags: [i % 2]);
                        },
                      ),
                    );
                  }),
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
