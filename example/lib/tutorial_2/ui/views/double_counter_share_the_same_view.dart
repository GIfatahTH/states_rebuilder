import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/services/counter_service.dart';
import '../../ui/views/counter1_share_view_the_same_view.dart';
import '../../ui/views/counter2_share_view_the_same_view.dart';

class DoubleCounterShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterService()],
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
This is a show case of how `Streaming` class make async controlling of the UI very easy.

The `Counter1ShareTheSameView` and `Counter2ShareTheSameView` listen to the same `Streaming` from the `counterService` class. The counter class are independent and none of them knows the existence of the other. They listen to the same stream. They listen to single subscription stream. Actually `Streaming` gives you the ability to make as many widgets listen to the same single subscription stream as you like.
""";
