import 'package:flutter/material.dart';

import '../injected/injected_i18n/injected_i18n.dart';
import '../injected/injected_theme/injected_theme.dart';
import '../rm.dart';
import 'on_reactive.dart';
import 'reactive_state_less_widget.dart';

/// Used instead of [StatelessWidget] on top of [MaterialApp] widget to listen
/// to [InjectedI18N] and [InjectedTheme]
///
/// It disposes all non auto disposed injected model when the app closes.
///
/// Useful also to dispose resources and reset injected states for test.
///
///
/// It can also be used to display a splash screen while initialization plugins.
///
/// These are the Hooks offered by this widget:
/// [TopStatelessWidget.ensureInitialization], [TopStatelessWidget.splashScreen],
/// [TopStatelessWidget.errorScreen], [TopStatelessWidget.didMountWidget],
/// [TopStatelessWidget.didUnmountWidget] and
/// [TopStatelessWidget.didChangeAppLifecycleState]
///
///
/// Example of TopAppWidget used to provide [InjectedTheme] and [InjectedI18N]
///
/// ```dart
///  void main() {
///    runApp(MyApp());
///  }
///
///  class MyApp extends TopStatelessWidget {
///    // This widget is the root of your application.
///    @override
///    Widget build(BuildContext context) {
///      return MaterialApp(
///        //
///        theme: themeRM.lightTheme, //light theme
///        darkTheme: themeRM.darkTheme, //dark theme
///        themeMode: themeRM.themeMode, //theme mode
///        //
///        locale: i18nRM.locale,
///        localeResolutionCallback: i18nRM.localeResolutionCallback,
///        localizationsDelegates: i18nRM.localizationsDelegates,
///        home: HomePage(),
///      );
///    }
///  }
///  ```
///
/// Example of initializing plugins
///
/// In Flutter it is common to initialize plugins inside the main method:
/// ```dart
/// void main()async{
///  WidgetsFlutterBinding.ensureInitialized();
///
///  await initializeFirstPlugin();
///  await initializeSecondPlugin();
///  runApp(MyApp());
/// }
/// ```
///
/// If you want to initialize plugins and display splash screen while waiting
/// for them to initialize and display an error screen if any of them fails to
/// initialize or request for permission with the ability to retry the
/// initialization you can use [TopStatelessWidget]:
///
/// ```dart
/// class MyApp extends TopStatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   List<Future<void>>? ensureInitialization() {
///     return [
///       initializeFirstPlugin(),
///       initializeSecondPlugin(),
///     ];
///   }
///
///   @override
///   Widget? splashScreen() {
///     return Material(
///       child: Scaffold(
///         body: Center(
///           child: CircularProgressIndicator(),
///         ),
///       ),
///     );
///   }
///
///   @override
///   Widget? errorScreen(error, void Function() refresh) {
///     return ElevatedButton.icon(
///       onPressed: () => refresh(),
///       icon: Icon(Icons.refresh),
///       label: Text('Retry again'),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MyHomePage();
///   }
/// }
/// ```
///
/// To invoke side effects depending on the app life cycle,
/// ```dart
/// class MyApp extends TopStatelessWidget {
///   @override
///   void didChangeAppLifecycleState(AppLifecycleState state) {
///     print(state);
///   }
///
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Container();
///   }
/// }
/// ```
abstract class TopStatelessWidget extends MyStatefulWidget {
  const TopStatelessWidget({Key? key}) : super(key: key);
  Widget build(BuildContext context);

  /// Hook to be called while waiting for plugins initialization.
  Widget? splashScreen() {}

  /// Hook to be called if initialization fails.
  Widget? errorScreen(dynamic error, void Function() refresh) {}

  ///List of future (plugins initialization) to wait for, and display a
  ///waiting screen while waiting
  List<Future<void>>? ensureInitialization() {}

  ///Called when the widget is first inserted in the widget tree
  void didMountWidget() {}

  ///Called when the widget is  removed from the widget tree
  void didUnmountWidget() {}

  /// Called when the system puts the app in the background or returns
  /// the app to the foreground.
  ///
  /// An example of implementing this method is provided in the class-level
  /// documentation for the [WidgetsBindingObserver] class.
  ///
  /// This method exposes notifications from [SystemChannels.lifecycle].
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  _TopStatelessWidgetState createState() {
    return _TopStatelessWidgetStateWidgetsBindingObserverState();
  }
}

class _TopStatelessWidgetState extends ExtendedState<TopStatelessWidget> {
  AddObsCallback? cachedAddToObs;
  final Map<InjectedBaseState, VoidCallback> _obs = {};
  bool isWaiting = false;
  dynamic error;
  InjectedI18N? injectedI18N;
  bool isInitialized = false;
  void _addToObs(InjectedBaseState inj) {
    if (inj is! InjectedTheme && inj is! InjectedI18N) {
      return;
    }
    if (inj is InjectedI18N) {
      injectedI18N = inj;
    }
    if (inj is InjectedThemeImp) {
      inj.isLinkedToTopStatelessWidget = true;
    }

    if (!_obs.containsKey(inj)) {
      _obs[inj] = inj.observeForRebuild(
        (rm) {
          setState(() {});
        },
        clean: inj.autoDisposeWhenNotUsed ? () => inj.dispose() : null,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    OnReactiveState.addToTopStatelessObs = _addToObs;
    widget.didMountWidget();
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
      await Future.wait(toInitialize, eagerError: true);
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
    for (var disposer in _obs.values) {
      disposer();
    }
    widget.didUnmountWidget();
    RM.disposeAll();
    super.dispose();
  }

  Widget getOnWaitingWidget() {
    final child = widget.splashScreen();
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
      return widget.errorScreen(error, _ensureInitialization) ??
          widget.build(context);
    }
    Widget? child;
    if (!isInitialized) {
      isInitialized = true;
      child = widget.build(context);
      OnReactiveState.addToTopStatelessObs = null;
    }
    if (injectedI18N != null) {
      if (injectedI18N!.isWaiting == true) {
        return getOnWaitingWidget();
      }
      return injectedI18N!.inherited(
        stateOverride: null,
        builder: (context) {
          return child ?? widget.build(context);
        },
      );
    }
    return child ?? widget.build(context);
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
    widget.didChangeAppLifecycleState.call(state);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    (injectedI18N as InjectedI18NImp?)?.didChangeLocales(locales);
  }
}
