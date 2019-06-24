import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/viewModels/counter2_share_model._same_view.dart';

class Counter2ShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2ShareModelSameView>(
      models: [() => Counter2ShareModelSameView()],
      builder: (context, Counter2ShareModelSameView model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("${model.counter}"),
              RaisedButton(
                child: Text("Increment. View2"),
                onPressed: model.increment,
              ),
            ],
          ),
    );
  }
}
