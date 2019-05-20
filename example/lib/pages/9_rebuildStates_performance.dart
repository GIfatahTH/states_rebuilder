import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum CounterTag { time }

class CounterBloc extends StatesRebuilder {
  int counter = 0;
  int time;
  String state;
  AnimationController controller;
  Animation animation;

  initAnimation(TickerProvider ticker) {
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: ticker);
    animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      }
    });
  }

  VoidCallback listener;
  triggerAnimation(tagID) {
    animation.removeListener(listener);
    listener = () {
      time = DateTime.now().microsecond;
      rebuildStates([tagID, CounterTag.time]);
      time = DateTime.now().microsecond - time;
      print(time);
    };
    animation.addListener(listener);
    controller.forward();
    counter++;
  }

  dispose() {
    controller.dispose();
  }

  lifecycleState(BuildContext context, String tagID, AppLifecycleState state) {
    this.state = "$state";
    rebuildStates([CounterTag.time]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Text(
              '$state',
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
    );
  }
}

class RebuildStatesPerformanceExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      bloc: CounterBloc(),
      child: CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: StateWithMixinBuilder(
        mixinWith: MixinWith.widgetsBindingObserver,
        initState: (_, __, observer) =>
            WidgetsBinding.instance.addObserver(observer),
        dispose: (_, __, observer) =>
            WidgetsBinding.instance.removeObserver(observer),
        didChangeAppLifecycleState: (context, tagID, state) {
          bloc.lifecycleState(context, tagID, state);
        },
        builder: (_, __) => Column(
              children: <Widget>[
                StateBuilder(
                    blocs: [bloc],
                    tag: CounterTag.time,
                    builder: (_, __) => Column(
                          children: <Widget>[
                            Text(
                                "Time taken to execute rebuildStates() ${bloc.time}"),
                            Text(
                                "This page is mixin with widgetsBindingObserver. The state is: ${bloc.state}"),
                          ],
                        )),
                Expanded(
                  child: StateWithMixinBuilder(
                    mixinWith: MixinWith.singleTickerProviderStateMixin,
                    initState: (_, __, ticker) => bloc.initAnimation(ticker),
                    dispose: (_, __, ___) => bloc.dispose(),
                    builder: (_, __) => GridView.count(
                          crossAxisCount: 3,
                          children: <Widget>[
                            for (var i = 0; i < 12; i++)
                              StateBuilder(
                                tag: i % 2,
                                blocs: [bloc],
                                builder: (_, tagID) => Transform.rotate(
                                      angle: bloc.animation.value,
                                      child: GridItem(
                                        count: bloc.counter,
                                        onTap: () =>
                                            bloc.triggerAnimation(i % 2),
                                      ),
                                    ),
                              ),
                          ],
                        ),
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
