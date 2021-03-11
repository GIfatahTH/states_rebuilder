part of '../reactive_model.dart';

class _InheritedState<T> extends StatefulWidget {
  const _InheritedState({
    Key? key,
    required this.builder,
    required this.globalInjected,
    this.state,
    this.reInheritedInjected,
    this.connectWithGlobal = false,
    this.debugPrintWhenNotifiedPreMessage,
  }) : super(key: key);
  final Widget Function(BuildContext) builder;
  final FutureOr<T> Function()? state;
  final Injected<T> globalInjected;
  final Injected<T>? reInheritedInjected;
  final bool connectWithGlobal;
  final String? debugPrintWhenNotifiedPreMessage;

  @override
  __InheritedStateState<T> createState() => __InheritedStateState<T>();
}

class __InheritedStateState<T> extends State<_InheritedState<T>> {
  late Injected<T> inheritedInjected;
  late Injected<T> globalInjected;
  Disposer? removeInheritedInjectFromGlobal;
  Disposer? removeListeners;
  bool _isDirty = true;
  @override
  void initState() {
    //  widget.globalInjected._isInitialized = true;
    // widget.globalInjected._isFirstInitialized = true;
    globalInjected = widget.globalInjected;
    if (widget.reInheritedInjected == null) {
      inheritedInjected = InjectedImp<T>(
        creator: (_) => widget.state!(),
        debugPrintWhenNotifiedPreMessage:
            widget.debugPrintWhenNotifiedPreMessage,
        on: On.data(
          () => globalInjected._previousSnapState =
              inheritedInjected._previousSnapState,
        ),
      );

      if (widget.connectWithGlobal) {
        removeInheritedInjectFromGlobal =
            globalInjected._addToInheritedInjects(inheritedInjected);
      }
    } else {
      inheritedInjected = widget.reInheritedInjected!;
    }

    inheritedInjected._initialize();
    removeListeners =
        inheritedInjected._listenToRMForStateFulWidget((rm, tags, _) {
      if (!_isDirty) {
        _isDirty = true;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Future.microtask(() => removeListeners?.call());
    if (widget.reInheritedInjected == null) {
      removeInheritedInjectFromGlobal?.call();
      // inheritedInjected.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isDirty = false;
    return _InheritedInjected(
      injected: inheritedInjected,
      globalInjected: globalInjected,
      context: context,
      child: Builder(builder: (context) => widget.builder(context)),
    );
  }
}

class _InheritedInjected<T> extends InheritedWidget {
  const _InheritedInjected({
    Key? key,
    required Widget child,
    required this.injected,
    required this.globalInjected,
    required this.context,
  }) : super(key: key, child: child);
  final Injected<T> injected;
  final Injected<T> globalInjected;
  final BuildContext context;

  @override
  bool updateShouldNotify(_InheritedInjected _) {
    return true;
  }
}
