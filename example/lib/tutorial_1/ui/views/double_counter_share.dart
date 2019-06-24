import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/services/counter_service.dart';
import '../../ui/views/counter1_share_view.dart';
import '../../ui/views/counter2_share_view.dart';

class DoubleCounterShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterService()],
      builder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Go to counter 1"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter1ShareView())),
              ),
              RaisedButton(
                child: Text("Go to counter 2"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter2ShareView())),
              ),
              Divider(),
              Expanded(
                child: Markdown(data: _firstExample),
              )
            ],
          ),
    );
  }
}

final String _firstExample = """

In case you want many views (viewModels) to share the same value, you use what is called __services__.

__services__: are classes that hold data and methods to be shared between many viewModels. They should be small and with one single responsibility. They can not communicate directly with a view. They should do that through the corresponding viewModel. For this reason services must no extend `StatesRebuilder`

## counter_service.dart file:

class CounterService {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
  }
}

## double_counter_share.dart file:

class DoubleCounterShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      __models: [() => CounterService()],__ // (1)
      builder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Go to counter 1"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter1ServiceView())),
              ),
              RaisedButton(
                child: Text("Go to counter 2"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter2ServiceView())),
              ),
            ],
          ),
    );
  }
}

- (1) : Injector is used to register the `CounterService`. Now child widgets throw their viewModels can access to the registered instance
""";
