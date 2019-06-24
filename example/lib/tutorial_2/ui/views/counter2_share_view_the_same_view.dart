import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/viewModels/counter2_share_model.dart';

class Counter2ShareTheSameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter2ShareModel>(
      models: [() => Counter2ShareModel()],
      builder: (context, Counter2ShareModel model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (model.snapshot.hasData)
                Text("${model.snapshot.data}")
              else
                Text("no Data"),
              RaisedButton(
                child: Text("Increment. View2"),
                onPressed: model.increment,
              ),
            ],
          ),
    );
  }
}
