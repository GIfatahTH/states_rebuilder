import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterBlocOne {
  int counter = 0;
  increment() {
    counter++;
  }
}

class RebuildOneExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject(() => CounterBlocOne())],
      builder: (_) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
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
                    StateBuilder<CounterBlocOne>(
                      models: [Injector.getAsReactive<CounterBlocOne>()],
                      builder: (context, bloc) => GridItem(
                        count: bloc.state.counter,
                        onTap: () => bloc.setState(
                          (state) => state.increment(),
                          filterTags: [context],
                        ),
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
