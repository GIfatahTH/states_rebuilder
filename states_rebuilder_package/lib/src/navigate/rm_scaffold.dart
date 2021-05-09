part of '../rm.dart';

final _scaffold = _Scaffold();

class _Scaffold {
  BuildContext? _context;

  ///The closest [ScaffoldMessengerState ]
  ScaffoldMessengerState get scaffoldMessengerState {
    final ctx = _context ?? RM.context ?? RM.navigate.navigatorState.context;
    return ScaffoldMessenger.of(ctx);
  }

  ///The closest [ScaffoldState]
  ScaffoldState get scaffoldState {
    final ctx = _context ?? RM.context;
    try {
      return Scaffold.of(ctx!);
    } catch (e) {
      throw Exception(
        '''
No valid BuildContext is defined yet

  Before calling any method a decedent BuildContext of Scaffold must be set.
  This can be done either:
  
  * ```dart
     onPressed: (){
      RM.scaffold.context= context;
      RM.scaffold.showBottomSheet(...);
     }
    ```
  * ```dart
     onPressed: (){
      modelRM.setState(
       (s)=> doSomeThing(),
       context:context,
       onData: (_,__){
          RM.scaffold.showBottomSheet(...);
        )
      }
     }
    ```
''',
      );
    }
  }

  set context(BuildContext context) => _context = context;

  ///Shows a material design persistent bottom sheet in the nearest [Scaffold].
  ///
  ///The new bottom sheet becomes a [LocalHistoryEntry] for the enclosing
  ///[ModalRoute] and a back button is added to the app bar of the [Scaffold]
  ///that closes the bottom sheet.
  ///
  ///To create a persistent bottom sheet that is not a [LocalHistoryEntry] and
  ///does not add a back button to the enclosing Scaffold's app bar, use the
  ///[scaffold.showBottomSheet] constructor parameter.
  ///
  ///A closely related widget is a modal bottom sheet, which is an alternative
  ///to a menu or a dialog and prevents the user from interacting with the
  ///rest of the app. Modal bottom sheets can be created and displayed with
  ///the [_Navigate.toBottomSheet] or [showModalBottomSheet] Methods.
  ///
  ///Returns a controller that can be used to close and otherwise manipulate
  ///the bottom sheet.
  ///
  ///
  ///* Required parameters:
  ///  * [bottomSheet]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [backgroundColor], [elevation], [shape], and [clipBehavior] : used to
  /// customize the appearance and behavior of bottom sheet
  ///
  ///Equivalent to: [ScaffoldState.showBottomSheet].
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffold.context= context;
  ///    RM.scaffold.showBottomSheet(...);
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffold.showBottomSheet(...);
  ///      )
  ///    }
  ///   }
  ///  ```
  PersistentBottomSheetController<T> showBottomSheet<T>(
    Widget bottomSheet, {
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  }) {
    final r = scaffoldState.showBottomSheet<T>(
      (_) => bottomSheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
    _context = null;
    return r;
  }

  ///Shows a [SnackBar] at the bottom of the scaffold.
  ///
  ///By default any current SnackBar will be hidden.
  ///
  ///* Required parameters:
  ///  * [snackBar]:  (positional parameter) The SnackBar to display.
  /// * optional parameters:
  ///  * [hideCurrentSnackBar]: Whether to hide the current SnackBar (if any).
  /// Default value is true.
  ///
  ///Equivalent to: [ScaffoldMessengerState.showSnackBar].
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffold.context= context;
  ///    RM.scaffold.showSnackBar(...);
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffold.showSnackBar(...);
  ///      )
  ///    }
  ///   }
  ///  ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar<T>(
    SnackBar snackBar, {
    bool hideCurrentSnackBar = true,
  }) {
    if (hideCurrentSnackBar) {
      scaffoldMessengerState.hideCurrentSnackBar();
    }
    final r = scaffoldMessengerState.showSnackBar(snackBar);
    _context = null;
    return r;
  }

  ///Removes the current [SnackBar] by running its normal exit animation.
  ///
  ///Similar to [ScaffoldMessengerState.hideCurrentSnackBar].
  void hideCurrentSnackBar({
    SnackBarClosedReason reason = SnackBarClosedReason.hide,
  }) {
    scaffoldMessengerState.hideCurrentSnackBar(reason: reason);
  }

  ///Removes the current [SnackBar] (if any) immediately from
  ///registered [Scaffold]s.
  ///
  ///Similar to [ScaffoldMessengerState.removeCurrentSnackBar].
  void removeCurrentSnackBarm({
    SnackBarClosedReason reason = SnackBarClosedReason.remove,
  }) {
    scaffoldMessengerState.removeCurrentSnackBar(reason: reason);
  }

  ///Opens the [Drawer] (if any).
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///Equivalent to: [ScaffoldState.openDrawer].
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffold.context= context;
  ///    RM.scaffold.openDrawer();
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffold.openDrawer();
  ///      )
  ///    }
  ///   }
  ///  ```
  void openDrawer<T>() {
    scaffoldState.openDrawer();
    _context = null;
  }

  ///Opens the end side [Drawer] (if any).
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  //Equivalent to: [ScaffoldState.openEndDrawer].
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffold.context= context;
  ///    RM.scaffold.openEndDrawer();
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffold.openEndDrawer();
  ///      )
  ///    }
  ///   }
  ///  ```
  void openEndDrawer<T>() {
    scaffoldState.openEndDrawer();
    _context = null;
  }
}
