# 1- Rebuild All listeners

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel extends StatesRebuilder {
  int counter = 0;
  increment() {
    counter++;
    rebuildStates();
  }
}

class RebuildAllExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModel>(
      models:[()=> CounterModel()],
      builder:(context,model) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<CounterModel>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: <Widget>[
          Text("Rebuild All subscribed states"),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder(
                    viewModels: [model],
                    builder: (_, __) => GridItem(
                          count: model.counter,
                          onTap: () => model.increment(),
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


    // The third alternative

```

# 2- Rebuild one listener by the automatically generated ID (address).

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel extends StatesRebuilder {
  int counter = 0;
  increment(tagID) {
    counter++;
    rebuildStates([tagID]);
  }
}

class RebuildOneExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModel>(
      models:[()=> CounterModel()],
      builder:(context,model) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<CounterModel>(context);
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
                          viewModels: [model],
                          builder: (_, tagID) => GridItem(
                                count: model.counter,
                                onTap: () => model.increment(tagID),
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
```


# 3- Rebuild filtered list of listeners by tag.

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel extends StatesRebuilder {
  int counter = 0;
  increment(tagID) {
    counter++;
    rebuildStates([tagID]);
  }
}

class RebuildSetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModel>(
      models:[()=> CounterModel()],
      builder:(context,model) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<CounterModel>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text("Rebuild a set of widgets that have the same tag"),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder(
                    tag: i % 2,
                    viewModels: [model],
                    builder: (_, tagID) => GridItem(
                          count: model.counter,
                          onTap: () => model.increment(i % 2),
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

```

# 3- Animation with StateWithMixinBuilder.

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel extends StatesRebuilder {
  int counter = 0;

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
      rebuildStates([tagID]);
    };
    animation.addListener(listener);
    controller.forward();
    counter++;
  }

  dispose() {
    controller.dispose();
  }
}

class AnimateSetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModel>(
      models:[()=> CounterModel()],
      builder:(context,model) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<CounterModel>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text("Animate a set of boxes"),
          Expanded(
            child: StateWithMixinBuilder(
              mixinWith: MixinWith.singleTickerProviderStateMixin,
              initState: (_, __, ticker) => model.initAnimation(ticker),
              dispose: (_, __, ___) => model.dispose(),
              builder: (_, __) => GridView.count(
                    crossAxisCount: 3,
                    children: <Widget>[
                      for (var i = 0; i < 12; i++)
                        StateBuilder(
                          tag: i % 2,
                          viewModels: [model],
                          builder: (_, tagID) => Transform.rotate(
                                angle: model.animation.value,
                                child: GridItem(
                                  count: model.counter,
                                  onTap: () => model.triggerAnimation(i % 2),
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