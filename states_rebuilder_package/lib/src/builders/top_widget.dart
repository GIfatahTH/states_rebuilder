import 'package:flutter/material.dart';

import '../../states_rebuilder.dart';

///# Prefer using [TopStatelessWidget] instead.
///
///{@template topWidget}
///Widget to put on top of the app.
///
///It disposes all non auto disposed injected model when the app closes.
///
///Useful also to dispose resources and reset injected states for test.
///
///It is also use to provide and listen to [InjectedTheme], [InjectedI18N]
///
///It can also be used to display a splash screen while initialization plugins.
///
/// Example of TopAppWidget used to provide [InjectedTheme] and [InjectedI18N]
///
///Provide and listen to the [InjectedTheme].
///
///```dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   // This widget is the root of your application.
///   @override
///   Widget build(BuildContext context) {
///     return TopAppWidget(//Use TopAppWidget
///       injectedTheme: themeRM, //Set the injectedTheme
///       injectedI18N: i18nRM, //Set the injectedI18N
///       builder: (context) {
///         return MaterialApp(
///           //
///           theme: themeRM.lightTheme, //light theme
///           darkTheme: themeRM.darkTheme, //dark theme
///           themeMode: themeRM.themeMode, //theme mode
///           //
///           locale: i18nRM.locale,
///           localeResolutionCallback: i18nRM.localeResolutionCallback,
///           localizationsDelegates: i18n.localizationsDelegates,,
///           home: HomePage(),
///         );
///       },
///     );
///   }
/// }
/// ```
/// {@endtemplate}
class TopAppWidget extends TopStatelessWidget {
  ///```dart
  ///Called when the system puts the app in the background or returns the
  ///app to the foreground.
  ///
  final void Function(AppLifecycleState state)? _didChangeAppLifecycleState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _didChangeAppLifecycleState?.call(state);
  }

  ///Child widget to render
  final Widget Function(BuildContext) builder;

  ///Provide and listen to the [InjectedTheme].
  ///
  ///```dart
  /// void main() {
  ///   runApp(MyApp());
  /// }
  ///
  /// class MyApp extends StatelessWidget {
  ///   // This widget is the root of your application.
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return TopAppWidget(//Use TopAppWidget
  ///       injectedTheme: theme, //Set te injectedTheme
  ///       builder: (context) {
  ///         return MaterialApp(
  ///           theme: theme.lightTheme, //light theme
  ///           darkTheme: theme.darkTheme, //dark theme
  ///           themeMode: theme.themeMode, //theme mode
  ///           home: HomePage(),
  ///         );
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  final InjectedTheme? injectedTheme;

  ///Provide and listen to the [InjectedI18N].
  ///Example:
  ///```dart
  ///import 'package:flutter_localizations/flutter_localizations.dart';
  ///
  ///class MyApp extends StatelessWidget {
  ///  // This widget is the root of your application.
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    return TopAppWidget(
  ///      //Provide and listen to i18n state
  ///      injectedI18N: i18n,
  ///      //If the translation is obtained asynchronously, we must define
  ///      //the onWaiting widget.
  ///      onWaiting: () =>  Scaffold(
  ///          body: Center(
  ///            child: CircularProgressIndicator(),
  ///          ),
  ///      ),
  ///      builder: (context) {
  ///        return MaterialApp(
  ///          //Defining locale, localeResolutionCallback and localizationsDelegates
  ///          //is more than enough for the app to get the right locale.
  ///          locale: i18n.locale,
  ///          localeResolutionCallback: i18n.localeResolutionCallback,
  ///          localizationsDelegates: i18n.localizationsDelegates,
  ///
  ///          //For more elaborate locale resolution algorithm use
  ///          //supportedLocales and localeListResolutionCallback.
  ///          // supportedLocales: i18n.supportedLocales,
  ///          // localeListResolutionCallback: (List<Locale>? locales, Iterable<Locale> supportedLocales){
  ///          //   //your algorithm
  ///          //   } ,
  ///          home: const HomePage(),//Notice const here
  ///        );
  ///      },
  ///    );
  ///  }
  ///}
  ///```
  final InjectedI18N? injectedI18N;
  // final InjectedAuth? injectedAuth;

  ///Widget (Splash Screen) to display while it is waiting for dependencies to
  ///initialize.
  final Widget Function()? _onWaiting;
  @override
  Widget? splashScreen() {
    return _onWaiting?.call();
  }

  final Widget Function(dynamic error, void Function() refresh)? _onError;
  @override
  Widget? errorScreen(error, void Function() refresh) {
    return _onError?.call(error, refresh);
  }

  ///List of future (plugins initialization) to wait for, and display a waiting screen while waiting
  final List<Future> Function()? _ensureInitialization;
  @override
  List<Future>? ensureInitialization() {
    return _ensureInitialization?.call();
  }

  ///{@macro topWidget}
  const TopAppWidget({
    Key? key,
    Function(AppLifecycleState)? didChangeAppLifecycleState,
    this.injectedTheme,
    this.injectedI18N,
    Widget Function()? onWaiting,
    List<Future> Function()? ensureInitialization,
    Widget Function(dynamic error, void Function() refresh)? onError,
    // this.injectedAuth,
    required this.builder,
  })  : _onWaiting = onWaiting,
        _onError = onError,
        _ensureInitialization = ensureInitialization,
        _didChangeAppLifecycleState = didChangeAppLifecycleState,
        assert(
          ensureInitialization == null || onWaiting != null,
          'You have to define a waiting splash screen '
          'using onWaiting parameter',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    injectedI18N?.locale;
    return builder(context);
  }
}
