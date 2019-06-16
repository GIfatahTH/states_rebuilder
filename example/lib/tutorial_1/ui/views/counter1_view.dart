import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/viewModels/counter1_model.dart';

class Counter1View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1Model>(
        models: [() => Counter1Model()],
        builder: (context, Counter1Model model) => Scaffold(
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
            ));
  }
}

final String _firstExample = """
## counter1_model.dart file:

class Counter1Model extends __StatesRebuilder__ {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
    __rebuildStates()__;
  }
}

## counter1_view.dart file:

class Counter1View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return __Injector<Counter1Model>(__ 
      __models: [() => Counter1Model()],__ 
      __builder: (context,Counter1Model model) => Column(__ 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("\${model.counter}"),
                RaisedButton(
                  child: Text("Increment"),
                  onPressed: model.increment,
                ),
               )
              ],
            ),
    );
  }
}
""";
