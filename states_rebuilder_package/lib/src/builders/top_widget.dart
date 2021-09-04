import 'package:flutter/material.dart';
import '../injected/injected_i18n/injected_i18n.dart';
import '../injected/injected_theme/injected_theme.dart';
import '../injected/injected_auth/injected_auth.dart';
import '../rm.dart';

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
/// {@endtemplate}
class TopAppWidget extends StatefulWidget {
  ///```dart
  ///Called when the system puts the app in the background or returns the
  ///app to the foreground.
  ///
  final void Function(AppLifecycleState state)? didChangeAppLifecycleState;

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
  ///      onWaiting: () => MaterialApp(
  ///        home: Scaffold(
  ///          body: Center(
  ///            child: CircularProgressIndicator(),
  ///          ),
  ///        ),
  ///      ),
  ///      builder: (context) {
  ///        return MaterialApp(
  ///          //Defining locale and localeResolutionCallback is more than
  ///          //enough for the app to get the right locale.
  ///          locale: i18n.locale,
  ///          localeResolutionCallback: i18n.localeResolutionCallback,
  ///
  ///          //For more elaborate locale resolution algorithm use
  ///          //supportedLocales and localeListResolutionCallback.
  ///          // supportedLocales: i18n.supportedLocales,
  ///          // localeListResolutionCallback: (List<Locale>? locales, Iterable<Locale> supportedLocales){
  ///          //   //your algorithm
  ///          //   } ,
  ///          localizationsDelegates: [
  ///            GlobalMaterialLocalizations.delegate,
  ///            GlobalWidgetsLocalizations.delegate,
  ///            GlobalCupertinoLocalizations.delegate,
  ///          ],
  ///          home: const HomePage(),//Notice const here
  ///        );
  ///      },
  ///    );
  ///  }
  ///}
  ///```
  final InjectedI18N? injectedI18N;
  final InjectedAuth? injectedAuth;

  ///Widget (Splash Screen) to display while it is waiting for dependencies to
  ///initialize.
  final Widget Function()? onWaiting;
  final Widget Function(dynamic error, void Function() refresh)? onError;

  ///List of future (plugins initialization) to wait for, and display a waiting screen while waiting
  final List<Future> Function()? ensureInitialization;

  @Deprecated('Use ensureInitialization instead')
  final List<Future> Function()? waiteFor;

  ///{@macro topWidget}
  const TopAppWidget({
    Key? key,
    this.didChangeAppLifecycleState,
    this.injectedTheme,
    this.injectedI18N,
    this.onWaiting,
    this.ensureInitialization,
    this.waiteFor,
    this.onError,
    this.injectedAuth,
    required this.builder,
  })  : assert(
          ensureInitialization == null || onWaiting != null,
          'You have to define a waiting splash screen '
          'using onWaiting parameter',
        ),
        super(key: key);

  @override
  _TopAppWidgetState createState() {
    if (didChangeAppLifecycleState != null || injectedI18N != null) {
      return _TopWidgetWidgetsBindingObserverState();
    } else {
      return _TopAppWidgetState();
    }
  }
}

class _TopAppWidgetState extends State<TopAppWidget> {
  Widget Function(Widget Function(BuildContext) builder)? _builderTheme;
  Widget Function(Widget Function(BuildContext) builder)? _builderI18N;
  late Widget child;
  bool _isWaiting = false;
  bool _hasError = false;
  dynamic error;
  bool _hasWaiteFor = false;
  void initState() {
    super.initState();
    _startWaiting();

    if (widget.injectedTheme != null) {
      _builderTheme = (builder) {
        return On(
          () => Builder(
            builder: (context) => builder(context),
          ),
        ).listenTo(widget.injectedTheme!);
      };
    }
    if (widget.injectedI18N != null) {
      _builderI18N = (builder) {
        return widget.injectedI18N!.inherited(
          builder: (context) {
            if (_isWaiting || widget.injectedI18N!.isWaiting) {
              return widget.onWaiting!();
            }
            return _builderTheme?.call(builder) ?? builder(context);
          },
        );
      };
    }
    if (!_hasWaiteFor) {
      child = _builderI18N?.call(widget.builder) ??
          _builderTheme?.call(widget.builder) ??
          widget.builder(context);
    }
  }

  Future<void> _startWaiting() async {
    List<Future> waiteFor = widget.ensureInitialization?.call() ?? [];
    waiteFor.addAll(widget.waiteFor?.call() ?? []);
    _hasWaiteFor = waiteFor.isNotEmpty ||
        widget.injectedI18N?.isWaiting == true ||
        widget.injectedAuth?.isWaiting == true;
    if (!_hasWaiteFor) {
      // if (widget.injectedI18N != null) {
      //   waiteFor.add(widget.injectedI18N!.stateAsync);
      // } else {
      //   return;
      // }
      return;
    }

    _isWaiting = true;
    _hasError = false;
    try {
      for (var future in waiteFor) {
        await future;
      }
      var i18n = widget.injectedI18N?.stateAsync;
      var auth = widget.injectedAuth?.stateAsync;

      await i18n;
      await auth;

      setState(() {
        _isWaiting = false;
      });
    } catch (e) {
      setState(() {
        _isWaiting = false;
        _hasError = true;
        error = e;
      });
    } finally {
      child = _builderI18N?.call(widget.builder) ??
          _builderTheme?.call(widget.builder) ??
          widget.builder(context);
    }
  }

  @override
  void dispose() {
    RM.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isWaiting || widget.injectedI18N?.isWaiting == true) {
      if (widget.onWaiting == null) {
        throw Exception('TopWidget is waiting for dependencies to initialize. '
            'you have to define a waiting screen using the onWaiting '
            'parameter of the TopWidget');
      }
      return widget.onWaiting!();
    }
    if (_hasError && widget.onError != null) {
      return widget.onError!.call(error, () {
        setState(() {
          _isWaiting = true;
          _hasError = false;
        });
        _startWaiting();
      });
    }
    (widget.injectedAuth as InjectedAuthImp?)?.initialize();
    // (widget.injectedI18N as InjectedI18NImp?)?.initialize();
    return child;
  }
}

class _TopWidgetWidgetsBindingObserverState extends _TopAppWidgetState
    with WidgetsBindingObserver {
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
    widget.didChangeAppLifecycleState?.call(state);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    (widget.injectedI18N as InjectedI18NImp).didChangeLocales(locales);
  }
}
