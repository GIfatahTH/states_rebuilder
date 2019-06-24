import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/services/counter_service_the_same_view.dart';
import '../../ui/views/counter1_share_view_the_same_view.dart';
import '../../ui/views/counter2_share_view_the_same_view.dart';

class DoubleCounterShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterServiceSameView()],
      builder: (_, __) => Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Counter1ShareTheSameView(),
                  Counter2ShareTheSameView(),
                ],
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
This is a show case on how to rebuild independent views from displayed in the same screen.

## counter_service_the_same_view.dart file:

class CounterServiceSameView {
  int _counter = 0;
  int get counter => _counter;

  increment() {
    _counter++;
    __rebuildStates();__ // (1)
  }

 __rebuildStates() {__ //(1)
    __Injector.get<Counter1ShareModelSameView>().rebuildStates();__ // (2)
    __Injector.get<Counter2ShareModelSameView>().rebuildStates();__
  }
}

## counter1_share_model_same_view.dart file:

class Counter1ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}

## counter2_share_model_same_view.dart file:

class Counter2ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}

1 - Define a method called `_rebuildStates`.
2 - Get instances of the viewModels and call `rebuildStates`

""";
