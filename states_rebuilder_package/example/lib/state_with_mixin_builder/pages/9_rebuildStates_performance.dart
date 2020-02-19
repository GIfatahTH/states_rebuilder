import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

enum CounterTag { time }

class CounterBlocPerf {
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
  triggerAnimation(VoidCallback listener) {
    animation.removeListener(this.listener);
    this.listener = () {
      time = DateTime.now().microsecondsSinceEpoch;
      // rebuildStates(["anim", CounterTag.time]);
      listener();
      time = DateTime.now().microsecondsSinceEpoch - time;
    };
    animation.addListener(this.listener);
    controller.forward();
    counter++;
  }

  dispose() {
    controller.dispose();
  }

  lifecycleState(BuildContext context, AppLifecycleState state) {
    this.state = "$state";
    // rebuildStates([CounterTag.time]);
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
    return Injector(
      inject: [Inject<CounterBlocPerf>(() => CounterBlocPerf())],
      builder: (_) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterRM = Injector.getAsReactive<CounterBlocPerf>(context: context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: StateWithMixinBuilder<WidgetsBindingObserver>(
        mixinWith: MixinWith.widgetsBindingObserver,
        initState: (_, observer) =>
            WidgetsBinding.instance.addObserver(observer),
        dispose: (_, observer) =>
            WidgetsBinding.instance.removeObserver(observer),
        didChangeAppLifecycleState: (context, state) {
          counterRM.setState((model) => model.lifecycleState(context, state),
              filterTags: [context]);
        },
        builder: (_, __) => Column(
          children: <Widget>[
            StateBuilder(
                models: [counterRM],
                tag: CounterTag.time,
                builder: (_, __) => Column(
                      children: <Widget>[
                        Text(
                            "Time taken to execute rebuildStates() ${counterRM.state.time}"),
                        Text(
                            "This page is mixin with widgetsBindingObserver. The state is: ${counterRM.state.state}"),
                      ],
                    )),
            Expanded(
              child: StateWithMixinBuilder(
                mixinWith: MixinWith.singleTickerProviderStateMixin,
                initState: (_, ticker) => counterRM.state.initAnimation(ticker),
                dispose: (_, ___) => counterRM.state.dispose(),
                builder: (_, __) => GridView.count(
                  crossAxisCount: 3,
                  children: <Widget>[
                    for (var i = 0; i < 12; i++)
                      StateBuilder(
                        models: [counterRM],
                        tag: "anim",
                        builder: (_, tagID) => Transform.rotate(
                          angle: counterRM.state.animation.value,
                          child: GridItem(
                            count: counterRM.state.counter,
                            onTap: () => counterRM.setState((value) =>
                                value.triggerAnimation(
                                    () => counterRM.setState(null))),
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
