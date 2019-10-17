import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterBlocAll {
  int counter = 0;
  bool isActive = true;
  increment1() => counter++;
  increment2() async {
    await Future.delayed(Duration(seconds: 1));
    isActive = true;
    counter++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Injector(
        inject: [Inject<CounterBlocAll>(() => CounterBlocAll())],
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
                    final bloc =
                        Injector.getAsModel<CounterBlocAll>(context: context);
                    return StateBuilder(
                      viewModels: [bloc],
                      tag: i % 2,
                      builder: (_, __) => GridItem(
                        count: bloc.state.isActive ? bloc.state.counter : null,
                        onTap: () {
                          if (i % 2 == 0)
                            bloc.setState((state) => state.increment1(),
                                tags: [i % 2]);
                          else
                            bloc
                              ..setState((state) => state.isActive = false,
                                  tags: [i % 2])
                              ..setState((state) => state.increment2(),
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
