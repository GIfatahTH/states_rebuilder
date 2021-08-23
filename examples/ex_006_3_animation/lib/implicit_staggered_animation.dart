import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final animation = RM.injectAnimation(
  duration: const Duration(milliseconds: 2000),
);

final _selected = RM.inject<bool>(
  () => true,
  onData: (_) {
    animation.refresh();
  },
);

class ImplicitStaggeredDemo extends StatelessWidget {
  const ImplicitStaggeredDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit Staggered Animation')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _selected.toggle();
        },
        child: OnReactive(
          () => Column(
            children: [
              Text('Using AnimateWidget'),
              SizedBox(height: 20),
              Expanded(
                child: OnAnimationBuilder(
                  listenTo: animation,
                  builder: (animate) {
                    final padding = animate
                        .setCurve(Interval(0.250, 0.375, curve: Curves.ease))
                        .call(
                          _selected.state
                              ? const EdgeInsets.only(bottom: 16.0)
                              : const EdgeInsets.only(bottom: 75.0),
                        );
                    final opacity = animate
                        .setCurve(Interval(0.0, 0.100, curve: Curves.ease))
                        .call(
                          _selected.state ? 0.5 : 1.0,
                        )!;
                    final containerWidget = animate
                        .setCurve(Interval(0.125, 0.250, curve: Curves.ease))
                        .call(
                            _selected.state ? 50.0 : 150.0, 'containerWidget')!;
                    final containerHeight = animate
                        .setCurve(Interval(0.250, 0.375, curve: Curves.ease))
                        .call(
                            _selected.state ? 50.0 : 150.0, 'containerHeight')!;
                    final color = animate
                        .setCurve(Interval(0.500, 0.750, curve: Curves.ease))
                        .call(
                          _selected.state
                              ? Colors.indigo[100]
                              : Colors.orange[400],
                        );
                    final borderRadius = animate
                        .setCurve(Interval(0.375, 0.500, curve: Curves.ease))
                        .call(
                          _selected.state
                              ? BorderRadius.circular(4.0)
                              : BorderRadius.circular(75.0),
                        );
                    return Center(
                      child: Container(
                        width: 300.0,
                        height: 300.0,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        child: Container(
                          padding: padding,
                          alignment: Alignment.bottomCenter,
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: containerWidget,
                              height: containerHeight,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: Colors.indigo[300]!,
                                  width: 3.0,
                                ),
                                borderRadius: borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          debugPrintWhenObserverAdd: '',
        ),
      ),
    );
  }
}
