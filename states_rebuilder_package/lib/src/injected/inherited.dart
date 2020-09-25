part of '../injected.dart';

class _InheritedState<T> extends StatefulWidget {
  const _InheritedState({
    Key key,
    @required this.builder,
    @required this.globalInjected,
    this.state,
    this.reInheritedInjected,
    this.connectWithGlobal = false,
    this.debugPrintWhenNotifiedPreMessage,
  }) : super(key: key);
  final Widget Function(BuildContext) builder;
  final T Function() state;
  final Injected<T> globalInjected;
  final Injected<T> Function() reInheritedInjected;
  final bool connectWithGlobal;
  final String debugPrintWhenNotifiedPreMessage;

  @override
  __InheritedStateState<T> createState() => __InheritedStateState<T>();
}

class __InheritedStateState<T> extends State<_InheritedState<T>> {
  Injected<T> _injected;
  Disposer _disposer1;

  void initState() {
    final _rm = widget.globalInjected.getRM;
    _injected = widget.reInheritedInjected != null
        ? widget.reInheritedInjected()
        : RM.inject(
            () => widget.state(),
            debugPrintWhenNotifiedPreMessage:
                widget.debugPrintWhenNotifiedPreMessage,
          );
    (_rm as ReactiveModelInternal).inheritedInjected.add(_injected);
    if (widget.connectWithGlobal) {
      _disposer1 = _injected.getRM.listenToRM(
        (rm) {
          bool isWaiting = false;
          bool hasError = false;

          (_rm as ReactiveModelInternal).inheritedInjected.forEach((inj) {
            if (inj.isWaiting) {
              isWaiting = true;
              return;
            }
            if (inj.hasError) {
              hasError = true;
              return;
            }
          });

          if (isWaiting) {
            _rm
              ..resetToIsWaiting()
              ..notify();
          } else if (hasError) {
            _rm
              ..resetToHasError(rm.error)
              ..notify();
          } else {
            _rm
              ..resetToHasData(rm.state)
              ..notify();
          }
        },
        listenToOnDataOnly: false,
      );
    }
    super.initState();
  }

  dispose() {
    _disposer1?.call();
    final _rm = widget.globalInjected.getRM;
    (_rm as ReactiveModelInternal).inheritedInjected.remove(_injected);

    if (_injected._rm?.hasObservers == false) {
      _injected.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedInjected(
      key: Key("${_injected.hashCode}"),
      child: Builder(
        builder: (context) => widget.builder(context),
      ),
      injected: _injected,
      globalInjected: widget.globalInjected,
      context: context,
    );
  }
}

class _InheritedInjected<T> extends InheritedWidget {
  const _InheritedInjected({
    Key key,
    @required Widget child,
    @required this.injected,
    @required this.globalInjected,
    @required this.context,
  })  : assert(child != null),
        super(key: key, child: child);
  final Injected<T> injected;
  final Injected<T> globalInjected;
  final BuildContext context;

  @override
  bool updateShouldNotify(_InheritedInjected _) {
    return false;
  }
}
