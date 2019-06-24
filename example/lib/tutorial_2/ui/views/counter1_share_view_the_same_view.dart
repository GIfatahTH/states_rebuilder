import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/viewModels/counter1_share_model.dart';

class Counter1ShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1ShareModel>(
      models: [() => Counter1ShareModel()],
      builder: (context, Counter1ShareModel model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (model.snapshot.hasData)
                Text("${model.snapshot.data}")
              else
                Text("no Data"),
              RaisedButton(
                child: Text("Increment. View 1"),
                onPressed: model.increment,
              ),
            ],
          ),
    );
  }
}
