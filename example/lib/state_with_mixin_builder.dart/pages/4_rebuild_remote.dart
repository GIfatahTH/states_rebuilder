import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum CounterGridTag { isEven }

class CounterBlocRemote extends StatesRebuilder {
  int counter = 0;
  bool isEven;
  increment(tagID) {
    isEven = tagID == 0;
    counter++;
    rebuildStates([tagID, CounterGridTag.isEven]);
  }
}

class RebuildRemoteExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterBlocRemote()],
      builder: (_) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Injector.singleton<CounterBlocRemote>();
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              StateBuilder(
                blocs: [bloc],
                tag: CounterGridTag.isEven,
                builder: (_, __) => bloc.isEven == null
                    ? CircularProgressIndicator()
                    : bloc.isEven
                        ? Icon(Icons.looks_two)
                        : Icon(Icons.looks_one),
              ),
              Text("Rebuild remote widget with tag"),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder(
                    tag: i % 2,
                    blocs: [bloc],
                    builder: (_, tagID) => GridItem(
                          count: bloc.counter,
                          onTap: () => bloc.increment(i % 2),
                        ),
                  )
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
          child: Text(
            "$count",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
