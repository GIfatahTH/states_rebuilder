import 'package:flutter/material.dart';

import '../injected/injected_i18n/injected_i18n.dart';
import '../injected/injected_theme/injected_theme.dart';
import '../rm.dart';
import 'on_reactive.dart';
import 'reactive_state_less_widget.dart';

abstract class AppLifecycle {
  void didChangeAppLifecycleState(AppLifecycleState state) {}
}

abstract class TopStatelessWidget extends MyStatefulWidget {
  const TopStatelessWidget({Key? key}) : super(key: key);
  Widget build(BuildContext context);

  // void Function(AppLifecycleState state)? didChangeAppLifecycleState;
  Widget? onWaiting() {}
  Widget? onError(dynamic error, void Function() refresh) {}

  ///List of future (plugins initialization) to wait for, and display a waiting screen while waiting
  List<Future>? ensureInitialization() {}

  ///Called when the widget is first inserted in the widget tree
  void didMountWidget() {}

  ///Called when the widget is  removed from the widget tree
  void didUnmountWidget() {}

  @override
  _TopStatelessWidgetState createState() {
    if (this is AppLifecycle) {
      return _TopStatelessWidgetStateWidgetsBindingObserverState();
    }
    return _TopStatelessWidgetState();
  }
}

class _TopStatelessWidgetState extends ExtendedState<TopStatelessWidget> {
  AddObsCallback? cachedAddToObs;
  late VoidCallback removeFromContextSet;
  Map<InjectedBaseState, VoidCallback> _obs1 = {};
  Map<InjectedBaseState, VoidCallback>? _obs2 = {};
  bool isWaiting = false;
  dynamic error;
  InjectedI18N? injectedI18N;
  void _addToObs(InjectedBaseState inj) {
    if (inj is! InjectedTheme && inj is! InjectedI18N) {
      return;
    }
    if (inj is InjectedI18N) {
      injectedI18N = inj;
    }
    final value = _obs1.remove(inj);
    if (value != null) {
      _obs2![inj] = value;
      return;
    }
    if (!_obs2!.containsKey(inj)) {
      _obs2![inj] = inj.observeForRebuild(
        (rm) {
          setState(() {});
        },
        clean: inj.autoDisposeWhenNotUsed ? () => inj.dispose() : null,
      );
    }
  }

  @override
  void afterBuild() {
    for (var disposer in _obs1.values) {
      disposer();
    }
    _obs1 = _obs2 ?? {};
    _obs2 = null;
    _obs2 = {};
    OnReactiveState.addToObs = cachedAddToObs;
  }

  @override
  void initState() {
    super.initState();
    OnReactiveState.addToTopStatelessObs = _addToObs;
    widget.didMountWidget();
    removeFromContextSet = addToContextSet(context);
    _ensureInitialization();
  }

  void _ensureInitialization() async {
    final toInitialize = widget.ensureInitialization();
    if (toInitialize == null || toInitialize.isEmpty) {
      return;
    }
    setState(() {
      isWaiting = true;
      error = null;
    });
    try {
      await Future.wait(toInitialize);
      setState(() {
        isWaiting = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        isWaiting = false;
        error = e;
      });
    }
  }

  @override
  void dispose() {
    for (var disposer in _obs1.values) {
      disposer();
    }
    removeFromContextSet();
    widget.didUnmountWidget();
    super.dispose();
  }

  Widget getOnWaitingWidget() {
    final child = widget.onWaiting();
    if (child == null) {
      throw Exception('TopWidget is waiting for dependencies to initialize. '
          'you have to define a waiting screen using the onWaiting '
          'parameter of the TopWidget');
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    if (isWaiting || injectedI18N?.isWaiting == true) {
      return getOnWaitingWidget();
    }

    if (error != null) {
      return widget.onError(error, _ensureInitialization) ??
          widget.build(context);
    }
    cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = _addToObs;
    OnReactiveState.addToTopStatelessObs = _addToObs;
    // late Widget child;
    // if (injectedI18N != null) {
    //   return injectedI18N!.inherited(
    //     builder: (ctx) {
    //       return widget.build(ctx);
    //     },
    //   );
    // }
    // try {
    final child = widget.build(context);
    // } catch (e) {}
    if (injectedI18N != null) {
      if (injectedI18N?.isWaiting == true) {
        return getOnWaitingWidget();
      }

      return injectedI18N!.inherited(
        builder: (ctx) {
          return child;
        },
      );
    }

    return child;
  }
}

class _TopStatelessWidgetStateWidgetsBindingObserverState
    extends _TopStatelessWidgetState with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    (widget as AppLifecycle).didChangeAppLifecycleState.call(state);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    (injectedI18N as InjectedI18NImp?)?.didChangeLocales(locales);
  }
}
