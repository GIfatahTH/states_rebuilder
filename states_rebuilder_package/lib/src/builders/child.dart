part of '../reactive_model.dart';

///Use Child in combination of other widget listeners, to control
///the part of the widget tree to rebuild.
class Child extends StatelessWidget {
  ///Returns widget that is intended to rebuild.
  ///It exposes the defined child widget.
  final Widget Function(Widget child) builder;

  ///Widget that is not intended tor rebuild.
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
