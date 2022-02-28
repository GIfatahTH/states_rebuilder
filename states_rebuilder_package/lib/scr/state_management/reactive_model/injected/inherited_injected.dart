part of '../../rm.dart';

class _InheritedInjected<T> extends InheritedWidget {
  _InheritedInjected({
    Key? key,
    required Widget child,
    required this.injected,
    required this.globalInjected,
    required this.context,
  }) : super(key: key, child: child) {
    final data = injected._snapState.data;
    state = data;
  }
  final InjectedImp<T> injected;
  late final T? state;
  final Injected<T> globalInjected;
  final BuildContext context;

  @override
  bool updateShouldNotify(_InheritedInjected _) {
    return _.state != state;
  }
}
