import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/services/counter_service.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/viewModels/counter2_share_model.dart';

class Counter2ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2ShareModel>(
      models: [() => Counter2ShareModel(Injector.get<CounterService>())],
      builder: (context, Counter2ShareModel model) => Scaffold(
            appBar: AppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("${model.counter}"),
                RaisedButton(
                  child: Text("Increment"),
                  onPressed: model.increment,
                ),
                Divider(),
                Expanded(
                  child: Markdown(data: _firstExample),
                )
              ],
            ),
          ),
    );
  }
}

final String _firstExample = """
## counter2_share_model.dart file:

class Counter2ShareModel extends StatesRebuilder {
  
  Counter2ShareModel(this.counterService); // (1)

  final CounterService counterService;
  int get counter => counterService.counter;

  increment() {
    counterService.increment();
    rebuildStates();
  }
}

## counter2_share_view.dart file:

class Counter2ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2ShareModel>(
      models: [() => Counter2ShareModel(Injector.get<CounterService>())], //(1)
      builder: (context, Counter2ShareModel model) => Scaffold(
            appBar: AppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("\${model.counter}"),
                RaisedButton(
                  child: Text("Increment"),
                  onPressed: model.increment,
                ),
                Divider(),
                Expanded(
                  child: Markdown(data: _firstExample),
                )
              ],
            ),
          ),
    );
  }
}

- (1) :The registered instance of `CounterService is injector in the constructor of `Counter2Share` .
""";
