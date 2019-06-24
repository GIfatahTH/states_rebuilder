import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/viewModels/counter1_share_model._same_view.dart';

class Counter1ShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1ShareModelSameView>(
      models: [() => Counter1ShareModelSameView()],
      builder: (context, Counter1ShareModelSameView model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("${model.counter}"),
              RaisedButton(
                child: Text("Increment. View 1"),
                onPressed: model.increment,
              ),
            ],
          ),
    );
  }
}
