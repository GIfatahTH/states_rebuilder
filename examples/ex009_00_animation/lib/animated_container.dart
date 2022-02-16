import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/// Inspired form https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html

final animation = RM.injectAnimation(
  duration: Duration(seconds: 2),
  curve: Curves.fastOutSlowIn,
);

class AnimatedContainerDemo extends StatelessWidget {
  const AnimatedContainerDemo({Key? key}) : super(key: key);

  static const String _title = 'Implicit Animation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: const MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
        });
      },
      child: Column(
        children: [
          Text('Flutter AnimatedContainer'),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: AnimatedContainer(
                width: selected ? 200.0 : 100.0,
                height: selected ? 100.0 : 200.0,
                color: selected ? Colors.red : Colors.blue,
                alignment: selected
                    ? Alignment.center
                    : AlignmentDirectional.topCenter,
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                child: const FlutterLogo(size: 75),
              ),
            ),
          ),
          Text('Using InjectedAnimation'),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: OnAnimationBuilder(
                listenTo: animation,
                builder: (animate) {
                  final width = animate(selected ? 200.0 : 100.0);
                  final height = animate(selected ? 100.0 : 200.0, 'height');
                  final alignment = animate(
                    selected
                        ? Alignment.center
                        : AlignmentDirectional.topCenter,
                  );
                  final Color? color = animate(
                    selected ? Colors.red : Colors.blue,
                  );
                  return Container(
                    width: width,
                    height: height,
                    color: color,
                    alignment: alignment,
                    child: const FlutterLogo(size: 75),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
