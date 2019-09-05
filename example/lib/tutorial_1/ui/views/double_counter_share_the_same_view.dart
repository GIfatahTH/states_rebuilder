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

class CounterServiceSameView extends Observable {// (1)
  int counter = 0;

  increment() {
    counter++;
    rebuildStates();// (2)
  }
}

## counter1_share_model_same_view.dart file:
class Counter1ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  Counter1ShareModelSameView() {
    counterService.addObserver(this);
  }

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}

## counter2_share_model_same_view.dart file:

class Counter2ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  Counter2ShareModelSameView() {
    counterService.addObserver(this); // 3
  }

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}

1 - Extending `Observable` class and calling `rebuildStates`after mutating the state.
2 - Register to the service class and get notified when `rebuildStates` is called in the service class.

""";
