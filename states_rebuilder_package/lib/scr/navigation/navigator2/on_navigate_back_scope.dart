part of '../injected_navigator.dart';

// TODO test and comment
class OnNavigateBackScope extends StatefulWidget {
  const OnNavigateBackScope({
    Key? key,
    required this.onNavigateBack,
    required this.child,
  }) : super(key: key);
  final bool? Function() onNavigateBack;
  final Widget child;

  @override
  State<OnNavigateBackScope> createState() => _OnNavigateBackScopeState();
}

class _OnNavigateBackScopeState extends State<OnNavigateBackScope> {
  late final VoidCallback disposer;
  @override
  void initState() {
    super.initState();
    disposer = RouterObjects._addToCanNavigateCallBack(widget.onNavigateBack);
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
