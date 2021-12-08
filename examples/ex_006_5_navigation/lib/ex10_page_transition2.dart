import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Re-implementation of ResoCoder demo example
// https://resocoder.com/2020/05/26/flutter-custom-staggered-page-transition-animation-tutorial/
void main() => runApp(const MyApp());

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const FirstPage(),
    '/secondPage': (data) => const SecondPage(),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Custom Page Transitions',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
      theme: ThemeData.light().copyWith(
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigator.to(
            'secondPage',
            transitionsBuilder: RM.transitions.none(
              duration: 1.seconds,
            ),
          );
        },
        child: const Icon(Icons.keyboard_arrow_right),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Column(
        children: const [
          Expanded(
            child: SlidingContainer(
              color: Colors.red,
              initialOffsetX: 1,
              intervalStart: 0,
              intervalEnd: 0.5,
            ),
          ),
          Expanded(
            child: SlidingContainer(
              color: Colors.green,
              initialOffsetX: -1,
              intervalStart: 0.5,
              intervalEnd: 1,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pop();
        },
        label: const Text('Navigate Back'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class SlidingContainer extends StatelessWidget {
  final double initialOffsetX;
  final double intervalStart;
  final double intervalEnd;
  final Color color;

  const SlidingContainer({
    Key? key,
    required this.initialOffsetX,
    required this.intervalStart,
    required this.intervalEnd,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = context.animation!;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(initialOffsetX, 0),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              curve: Interval(
                intervalStart,
                intervalEnd,
                curve: Curves.easeOutCubic,
              ),
              parent: animation,
            ),
          ),
          child: child,
        );
      },
      child: Container(
        color: color,
      ),
    );
  }
}
