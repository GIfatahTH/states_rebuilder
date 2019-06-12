import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterBlocOne extends StatesRebuilder {
  int counter = 0;
  increment(tagID) {
    counter++;
    rebuildStates([tagID]);
  }
}

class RebuildOneExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterBlocOne()],
      builder: (_, __) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  final bloc = Injector.get<CounterBlocOne>();
  @override
  Widget build(BuildContext context) {
    return StateWithMixinBuilder(
      mixinWith: MixinWith.automaticKeepAliveClientMixin,
      builder: (_, __) => Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text("Rebuild The tapped widget"),
                Text(
                    "This page is mixin with automaticKeepAliveClientMixin to not rebuild on sweep in"),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: <Widget>[
                      for (var i = 0; i < 12; i++)
                        StateBuilder(
                          viewModels: [bloc],
                          builder: (_, tagID) => GridItem(
                                count: bloc.counter,
                                onTap: () => bloc.increment(tagID),
                              ),
                        )
                    ],
                  ),
                ),
              ],
            ),
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
