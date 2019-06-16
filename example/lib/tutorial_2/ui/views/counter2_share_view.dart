import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder_demo/tutorial_2/logic/viewModels/counter2_share_model.dart';

class Counter2ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2ShareModel>(
      models: [() => Counter2ShareModel()],
      builder: (context, Counter2ShareModel model) => Scaffold(
            appBar: AppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (model.snapshot.hasData)
                  Text("${model.snapshot.data}")
                else
                  Text("no Data"),
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
  final counterService = Injector.get<CounterService>();
  Counter2ShareModel() {
    counterService.streamingCounter.addListener(this); // (1)
  } 
  AsyncSnapshot<int> get snapshot =>
      counterService.streamingCounter.snapshots[0]; // (2)
  increment() {
    counterService.counterSink((snapshot.data ?? 0) + 1); // (3)
  }
}


## counter1_share_view.dart file:

class Counter2ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1ShareModel>(
        models: [() => Counter2ShareModel()],
        builder: (context, Counter2ShareModel model) => Scaffold(
              appBar: AppBar(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (model.snapshot.hasData)
                    Text("\${model.snapshot.data}")
                  else
                    Text("no Data"),
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
            ));
  }
}

- (1) : Register this viewModel using `addListener()`. `addListener` takes two arguments. The first required argument is the viewModel you want to register. If you do not want to rebuild all the view when a streams emits a value, use the second optional argument which is a tag. You can specify the tag of the `StateBuilder` widget you want to rebuild. This listener is automatically removed when related view widget is disposed.
- (2) : get the snapshots you want (single , merged or combined).
- (3) : Call `counterSink` to add values to the sink.
""";
