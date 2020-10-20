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
  final Injected<T> reInheritedInjected;
  final bool connectWithGlobal;
  final String debugPrintWhenNotifiedPreMessage;

  @override
  __InheritedStateState<T> createState() => __InheritedStateState<T>();
}

class __InheritedStateState<T> extends State<_InheritedState<T>> {
  Injected<T> _injected;
  Disposer _disposer1;
  Disposer _disposer2;
  ReactiveModel<T> _rm;
  List<Injected<dynamic>> get _inheritedInjects =>
      (_rm as ReactiveModelInternal).inheritedInjected;
  void initState() {
    _rm = widget.globalInjected.getRM;
    _injected = widget.reInheritedInjected != null
        ? widget.reInheritedInjected
        : RM.inject(
            () => widget.state(),
            debugPrintWhenNotifiedPreMessage:
                widget.debugPrintWhenNotifiedPreMessage,
          );
    assert(_injected != null);
    if (widget.state != null) {
      _inheritedInjects.add(_injected);
    }
    if (widget.connectWithGlobal) {
      _disposer1 =
          (_injected.getRM as ReactiveModelInternal).listenToRMInternal(
        (rm) {
          bool isWaiting = false;
          bool hasError = false;

          _inheritedInjects.forEach((inj) {
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
        debugListener: 'CONNECT_WITH_GLOBAL_INHERITED',
      );
    }
    _disposer2 = (_injected.getRM as ReactiveModelInternal).listenToRMInternal(
      (rm) {
        setState(() {});
      },
      debugListener: 'SET_STATE_INHERITED',
    );
    (_rm as ReactiveModelInternal).numberOfFutureAndStreamBuilder++;
    super.initState();
  }

  dispose() {
    _disposer1?.call();
    _disposer2();
    if (widget.state != null) {
      _inheritedInjects.remove(_injected);
    }

    if (_injected._rm?.hasObservers == false) {
      _injected.dispose();
    }
    (_rm as ReactiveModelInternal).numberOfFutureAndStreamBuilder--;
    if (!_rm.hasObservers &&
        (_rm as ReactiveModelInternal).numberOfFutureAndStreamBuilder < 1) {
      widget.globalInjected.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedInjected(
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
    return true;
  }
}
