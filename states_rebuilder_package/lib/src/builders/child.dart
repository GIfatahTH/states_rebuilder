import 'package:flutter/material.dart';

///Use Child in combination of other widget listeners, to control
///the part of the widget tree to rebuild.
class Child extends StatelessWidget {
  ///Returns widget that is intended to rebuild.
  ///It exposes the defined child widget.
  final Widget Function(Widget child) builder;

  ///Widget that is not intended tor rebuild.
  final Widget child;

  const Child({
    required this.builder,
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return builder(child);
  }
}

class Child2 extends StatelessWidget {
  ///Returns widget that is intended to rebuild.
  ///It exposes the defined child widget.
  final Widget Function(Widget child1, Widget child2) builder;

  ///Widget that is not intended tor rebuild.
  final Widget child1;
  final Widget child2;

  const Child2({
    required this.builder,
    Key? key,
    required this.child1,
    required this.child2,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return builder(child1, child2);
  }
}

class Child3 extends StatelessWidget {
  ///Returns widget that is intended to rebuild.
  ///It exposes the defined child widget.
  final Widget Function(Widget child1, Widget child2, Widget child3) builder;

  ///Widget that is not intended tor rebuild.
  final Widget child1;
  final Widget child2;
  final Widget child3;

  const Child3({
    required this.builder,
    Key? key,
    required this.child1,
    required this.child2,
    required this.child3,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return builder(child1, child2, child3);
  }
}
