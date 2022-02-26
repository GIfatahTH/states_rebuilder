import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final animation = RM.injectAnimation(
  duration: 3.seconds,
  curve: Curves.fastOutSlowIn,
  reverseCurve: Curves.bounceInOut,
  repeats: 0,
  shouldReverseRepeats: true,
  //If you want the animation to auto restart uncomment the line below
  // shouldAutoStart: true,
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExplicitAnimationDemo(),
    );
  }
}

class ExplicitAnimationDemo extends StatelessWidget {
  const ExplicitAnimationDemo({Key? key}) : super(key: key);

  static const String _title = 'Explicit Animation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        animation.triggerAnimation();
      },
      child: Center(
        child: OnAnimationBuilder(
          listenTo: animation,
          builder: (animate) {
            final width = animate.fromTween(
              (currentValue) => Tween(
                begin: 200.0,
                end: 100.0,
              ),
            );
            final height = animate.fromTween(
              (currentValue) => 100.0.tweenTo(200.0),
              'height',
            );

            final alignment = animate.fromTween(
              (currentValue) => AlignmentGeometryTween(
                begin: Alignment.center,
                end: AlignmentDirectional.topCenter,
              ),
            );

            final Color? color = animate.fromTween(
              (currentValue) => Colors.red.tweenTo(Colors.blue),
              'height',
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
    );
  }
}
