part of 'injected_auth.dart';

extension InjectedAuthX<T, P> on InjectedAuth<T, P> {
  _Rebuild<T, P> get rebuild => _Rebuild<T, P>(this);
}

class _Rebuild<T, P> {
  final InjectedAuth<T, P> inj;
  _Rebuild(this.inj);
  Widget onAuth({
    Key? key,
    required Widget Function() onUnsigned,
    required Widget Function() onSigned,
    Widget Function()? onInitialWaiting,
    Widget Function()? onWaiting,
    bool useRouteNavigation = false,
    SideEffects<T>? sideEffects,
    GlobalKey<NavigatorState>? navigatorKey,
    String? debugPrintWhenRebuild,
  }) {
    return OnAuthBuilder(
      key: key,
      listenTo: inj,
      onSigned: onSigned,
      onUnsigned: onUnsigned,
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      useRouteNavigation: useRouteNavigation,
      navigatorKey: navigatorKey,
      sideEffects: sideEffects,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

/// Listen to an [InjectedAuth] and define the appropriate view for each case
class OnAuthBuilder<T, P> extends MyStatefulWidget<T> {
  OnAuthBuilder({
    Key? key,
    required this.listenTo,
    required this.onUnsigned,
    required this.onSigned,
    this.onInitialWaiting,
    this.onWaiting,
    this.useRouteNavigation = false,
    SideEffects<T>? sideEffects,
    this.navigatorKey,
    String? debugPrintWhenRebuild,
  }) : super(
          key: key,
          observers: (context) {
            NavigatorState? navigatorState;
            if (navigatorKey == null && useRouteNavigation == true) {
              navigatorState = RM.navigate.navigatorKey.currentState;
            } else if (navigatorKey != null) {
              navigatorState = navigatorKey.currentState;
            }
            if (navigatorState != null) {
              (listenTo as ReactiveModelImp).initialize();
              listenTo.addObserver(
                listener: (rm) {
                  if (!rm.hasData) return;
                  navigatorState!.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) {
                        return (listenTo as InjectedAuthImp).isSigned
                            ? onSigned()
                            : onUnsigned();
                      },
                    ),
                    (route) => false,
                  );
                },
                shouldAutoClean: false,
              );
            }
            return [listenTo as InjectedAuthImp];
          },
          debugPrintWhenRebuild: debugPrintWhenRebuild,
          sideEffects: sideEffects,
          shouldRebuild: (old, current) {
            if (navigatorKey != null || useRouteNavigation) {
              return false;
            }
            return true;
          },
          builder: null,
        );

  /// [InjectedAuth] to listen to.
  final InjectedAuth<T, P> listenTo;

  ///Widget to display while waiting for the first signing when app starts
  final Widget Function()? onInitialWaiting;

  ///Widget to display while waiting for signing
  final Widget Function()? onWaiting;

  ///Widget to display if use is signed
  final Widget Function() onUnsigned;

  ///Widget to display if use is unsigned
  final Widget Function() onSigned;

  ///Whether to use navigation transition between onSigned and onUnsigned
  ///widgets or simply use widget replacement
  ///
  ///If you set useRouteNavigation you have to set [RM.navigate.navigatorKey]
  ///in the MaterialApp.
  ///
  ///```dart
  ///MaterialApp(
  ///  navigatorKey : RM.navigate.navigatorKey,
  ///)
  ///```
  ///
  final bool useRouteNavigation;
  final GlobalKey<NavigatorState>? navigatorKey;
  final _map = {
    'onInitialWaiting': true,
  };

  @override
  Widget builder(context, snap, rm) {
    final inj = rm as InjectedAuth;
    Widget getWidget() => inj.isSigned ? onSigned() : onUnsigned();
    if (snap.isWaiting) {
      if (onInitialWaiting != null && _map['onInitialWaiting'] == true) {
        _map['onInitialWaiting'] = false;
        return onInitialWaiting!();
      }
      return onWaiting?.call() ?? getWidget();
    }
    // onInitialWaiting = null;
    return getWidget();
  }
}
