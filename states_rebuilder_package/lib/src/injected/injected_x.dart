part of '../reactive_model.dart';

///An extension of List<Injected>
extension InjectedX on List<Injected> {
  ///{@macro inherited}
  Widget inherited({
    Key? key,
    required Widget Function(BuildContext) builder,
  }) {
    final lastWidget =
        this[length - 1].inherited(builder: (ctx) => builder(ctx));
    if (length == 1) {
      return lastWidget;
    }

    Widget? widget;
    for (var i = length - 2; i >= 0; i--) {
      var temp = widget ?? lastWidget;
      widget = this[i].inherited(builder: (ctx) => temp);
    }
    return widget!;
  }
}
