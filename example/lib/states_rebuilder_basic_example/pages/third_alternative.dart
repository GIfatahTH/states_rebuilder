import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../blocs/counter_bloc.dart';

class ThirdAlternative extends StatelessWidget {
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('The Third alternative'),
            //All widget that has a tag will be rebuilt.
            //look at the increment3() method in the BloC.
            RaisedButton(
              child: Text("rebuildStates()"),
              onPressed: counterBloc.increment3,
            ),
            Text(
                "Navigate back to the first tab to see that the first counter is incremented"),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(thirdAlternative),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String thirdAlternative = 'Third alternative\n\n'
    'Your UI part\n'
    '//All widget that has a tag will be rebuilt.\n'
    '//look at the increment3() method in the BloC.\n'
    'RaisedButton(\n'
    '  child: Text("rebuildStates()"),\n'
    '  onPressed: counterBloc.increment3,\n'
    '),\n'
    'Your Bloc Part\n'
    'void increment3() {\n'
    '  _counter1++;\n'
    '  rebuildStates();\n\n'
    '  // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and\n'
    '  // are given `tag` will rebuild to reflect the new counter value.\n'
    '  //\n'
    '  // you get a similar behavior like in scoped_model or provider packages\n'
    '}\n';
