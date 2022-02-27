part of '../injected_navigator.dart';

/// Creates a widget that registers a callback to veto attempts by the user
/// to navigate back.
class OnNavigateBackScope extends StatefulWidget {
  /// Creates a widget that registers a callback to veto attempts by the user
  /// to navigate back.
  const OnNavigateBackScope({
    Key? key,
    required this.onNavigateBack,
    required this.child,
  }) : super(key: key);

  /// Callback to be fired when this page is popping out.
  ///
  /// Returning false popping is canceled
  final bool? Function() onNavigateBack;

  /// The child widget
  final Widget child;

  @override
  State<OnNavigateBackScope> createState() => _OnNavigateBackScopeState();
}

class _OnNavigateBackScopeState extends State<OnNavigateBackScope> {
  late final VoidCallback disposer;
  @override
  void initState() {
    super.initState();
    disposer = RouterObjects._addToCanNavigateCallBack(
      widget.onNavigateBack,
      context.routeData.location,
    );
  }

  @override
  void dispose() {
    disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
