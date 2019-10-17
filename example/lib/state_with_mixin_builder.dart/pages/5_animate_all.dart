import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterBlocAnimAll {
  int counter = 0;

  AnimationController controller;
  Animation animation;

  initAnimation(TickerProvider ticker) {
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: ticker);
    animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      }
    });
  }

  VoidCallback _listener;
  triggerAnimation(VoidCallback listener) {
    controller.reset();
    animation.removeListener(_listener);
    _listener = listener;
    animation.addListener(_listener);
    controller.forward();
    counter++;
  }

  dispose() {
    controller.dispose();
    print("hi I am disposed $controller");
  }
}

class AnimateAllExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<CounterBlocAnimAll>(() => CounterBlocAnimAll())],
      builder: (_, __) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Injector.getAsModel<CounterBlocAnimAll>(context: context);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text("Animate All subscribed states"),
          Expanded(
            child: StateWithMixinBuilder<TickerProvider>(
              mixinWith: MixinWith.singleTickerProviderStateMixin,
              initState: (_, __, ticker) => bloc.state.initAnimation(ticker),
              dispose: (_, __, ___) => bloc.state.dispose(),
              builder: (_, __) => GridView.count(
                crossAxisCount: 3,
                children: <Widget>[
                  for (var i = 0; i < 12; i++)
                    StateBuilder(
                      viewModels: [null],
                      tag: i,
                      builder: (_, __) => Transform.rotate(
                        angle: bloc.state.animation.value,
                        child: GridItem(
                          count: bloc.state.counter,
                          onTap: () => bloc.state
                              .triggerAnimation(() => bloc.setState((_) {})),
                        ),
                      ),
                    ),
                ],
              ),
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
