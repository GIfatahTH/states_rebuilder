part of '../reactive_model.dart';

final _navigate = _Navigate();

class _Navigate {
  ///get the NavigatorState
  NavigatorState get navigatorState {
    final navigatorState = _navigatorKey.currentState;
    assert(navigatorState != null, '''
The MaterialApp has no defined navigatorKey.

To fix:
MaterialApp(
   navigatorKey: RM.navigate.navigatorKey,
   //
   //
)
''');

    return navigatorState!;
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey;
  }

  ///navigate to the given page.
  ///
  ///Equivalent to: [NavigatorState.push]
  Future<T?> to<T extends Object?>(Widget page) {
    return navigatorState.push<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
    );
  }

  ///Navigate to the page with the given named route.
  ///
  ///Equivalent to: [NavigatorState.pushNamed]
  Future<T?> toNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorState.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  ///Navigate to the given page, and remove the current route and replace it
  ///with the new one.
  ///
  ///Equivalent to: [NavigatorState.pushReplacement]
  Future<T?> toReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return navigatorState.pushReplacement<T, TO>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
      result: result,
    );
  }

  ///Navigate to the page with the given named route, and remove the current
  ///route and replace it with the new one.
  ///
  ///Equivalent to: [NavigatorState.pushReplacementNamed]
  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments}) {
    return navigatorState.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Navigate to the given page, and then remove all the previous routes until
  ///meeting the route with defined route name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///Equivalent to: [NavigatorState.pushAndRemoveUntil]
  Future<T?> toAndRemoveUntil<T extends Object?>(
    Widget page, {
    String? untilRouteName,
  }) {
    return navigatorState.pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
    );
  }

  ///Navigate to the page with the given named route (first argument), and then
  ///remove all the previous routes until meeting the route with defined route
  ///name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///Equivalent to: [NavigatorState.pushNamedAndRemoveUntil]
  Future<T?> toNamedAndRemoveUntil<T extends Object?>(String newRouteName,
      {String? untilRouteName, Object? arguments}) {
    return navigatorState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
      arguments: arguments,
    );
  }

  ///Navigate back to the last page, ie
  ///Pop the top-most route off the navigator.
  ///
  ///Equivalent to: [NavigatorState.pop]
  void back<T extends Object>([T? result]) {
    navigatorState.pop<T>(result);
  }

  ///Navigate back and remove all the previous routes until meeting the route
  ///with defined name
  ///
  ///Equivalent to: [NavigatorState.popUntil]
  void backUntil(String untilRouteName) {
    return navigatorState.popUntil(
      ModalRoute.withName(untilRouteName),
    );
  }

  ///Navigate back than to the page with the given named route
  ///
  ///Equivalent to: [NavigatorState.popAndPushNamed]
  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorState.popAndPushNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Displays a Material dialog above the current contents of the app, with
  ///Material entrance and exit animations, modal barrier color, and modal
  ///barrier behavior (dialog is dismissible with a tap on the barrier).
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is true.
  ///  * [barrierColor]: the color of the modal barrier that darkens everything
  /// the dialog. If null the default color Colors.black54 is used.
  ///  * [useSafeArea]: Whether the dialog should only display in 'safe' areas
  /// of the screen. Default value is true.
  ///
  ///Equivalent to: [showDialog].
  Future<T?> toDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    return showDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
    );
  }

  ///Displays an iOS-style dialog above the current contents of the app, with
  ///iOS-style entrance and exit animations, modal barrier color, and modal
  ///barrier behavior
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is false.
  ///
  ///Equivalent to: [showCupertinoDialog].
  Future<T?> toCupertinoDialog<T>(
    Widget dialog, {
    bool barrierDismissible = false,
  }) {
    return showCupertinoDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
    );
  }

  ///Shows a modal material design bottom sheet that prevents the user from
  ///interacting with the rest of the app.
  ///
  ///A closely related widget is the persistent bottom sheet, which allows
  ///the user to interact with the rest of the app. Persistent bottom sheets
  ///can be created and displayed with the (RM.scaffoldShow.bottomSheet) or
  ///[showBottomSheet] Methods.
  ///
  ///
  ///* Required parameters:
  ///  * [bottomSheet]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [isDismissible]: whether the bottom sheet will be dismissed when user
  /// taps on the scrim. Default value is true.
  ///  * [enableDrag]: whether the bottom sheet can be dragged up and down and
  /// dismissed by swiping downwards. Default value is true.
  ///  * [isScrollControlled]: whether this is a route for a bottom sheet that
  /// will utilize [DraggableScrollableSheet]. If you wish to have a bottom
  /// sheet that has a scrollable child such as a [ListView] or a [GridView]
  /// and have the bottom sheet be draggable, you should set this parameter
  /// to true.Default value is false.
  ///  * [backgroundColor], [elevation], [shape], [clipBehavior] and
  /// [barrierColor]: used to customize the appearance and behavior of modal
  /// bottom sheets
  ///
  ///Equivalent to: [showModalBottomSheet].
  Future<T?> toBottomSheet<T>(
    Widget bottomSheet, {
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorState.context,
      builder: (_) => bottomSheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  ///Shows a modal iOS-style popup that slides up from the bottom of the screen.
  ///* Required parameters:
  ///  * [cupertinoModalPopup]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [filter]:
  ///  * [semanticsDismissible]: whether the semantics of the modal barrier are
  /// included in the semantics tree
  Future<T?> toCupertinoModalPopup<T>(
    Widget cupertinoModalPopup, {
    ImageFilter? filter,
    bool? semanticsDismissible,
  }) {
    return showCupertinoModalPopup<T>(
      context: navigatorState.context,
      builder: (_) => cupertinoModalPopup,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
    );
  }
}
