part of '../reactive_model.dart';

class Child extends StatelessWidget {
  final Widget Function(Widget child) builder;
  final Widget child;

  const Child(
    this.builder, {
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return builder(child);
  }
}
