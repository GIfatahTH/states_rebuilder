import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder_demo/tutorial_1/ui/views/counter1_view.dart';
import 'package:states_rebuilder_demo/tutorial_1/ui/views/counter2_view.dart';

class DoubleCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text("Go to counter 1"),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => Counter1View())),
        ),
        RaisedButton(
          child: Text("Go to counter 2"),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => Counter2View())),
        ),
        Divider(),
        Expanded(
          child: Markdown(data: _firstExample),
        )
      ],
    );
  }
}

final String _firstExample = """

Each counter view has its own viewModel. They do not share the counter value.

""";
