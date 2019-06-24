import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/viewModels/counter2_model.dart';

class Counter2View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2Model>(
      models: [() => Counter2Model()],
      builder: (context, Counter2Model model) => Scaffold(
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
## counter2_model.dart file:

class Counter2Model extends __StatesRebuilder__ {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
    __rebuildStates()__;
  }
}

## counter2_view.dart file:

class Counter2View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return __Injector<Counter2Model>(__ 
      __models: [() => Counter2Model()],__ 
      __builder: (context,Counter2Model model) => Column(__ 
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
