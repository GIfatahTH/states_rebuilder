import 'package:flutter/material.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

///{@template InjectedTheme}
/// Injection of a state that handle app theme switching.
///
/// This injected state abstracts the best practices of the clean
/// architecture to come out with a simple, clean, and testable approach
/// to manage app theming.
///
/// The approach consists of the following steps:
/// * Instantiate an [InjectedTheme] object using [RM.injectTheme] method.
/// * we use the [TopAppWidget] that must be on top of the MaterialApp widget.
///   ```dart
///    void main() {
///      runApp(MyApp());
///    }
///
///    class MyApp extends StatelessWidget {
///      // This widget is the root of your application.
///      @override
///      Widget build(BuildContext context) {
///        return TopAppWidget(//Use TopAppWidget
///          injectedTheme: themeRM, //Set te injectedTheme
///          builder: (context) {
///            return MaterialApp(
///              theme: themeRM.lightTheme, //light theme
///              darkTheme: themeRM.darkTheme, //dark theme
///              themeMode: themeRM.themeMode, //theme mode
///              home: HomePage(),
///            );
///          },
///        );
///      }
///    }
///   ```
///  {@endtemplate}

abstract class InjectedTheme<KEY> {
  // KEY get state => getInjectedState(this);
  KEY get state;
  set state(KEY value);

  ///Get supported light themes
  Map<KEY, ThemeData> get supportedLightThemes;

  ///Get supported dark themes
  Map<KEY, ThemeData> get supportedDarkThemes;

  ///Get the current light theme.
  ThemeData get lightTheme;

  ///Get the current dark theme.
  ThemeData? get darkTheme;
  ThemeData get activeTheme => isDarkTheme ? darkTheme! : lightTheme;

  ///The current [ThemeMode]
  late ThemeMode themeMode;

  ///Wether the current mode is dark.
  ///
  ///If the current [ThemeMode] is system, the darkness is calculated from the
  ///brightness of the system ([MediaQuery.platformBrightnessOf]).
  bool get isDarkTheme;
  void toggle();
  void dispose();
}

class InjectedThemeImp<KEY> with InjectedTheme<KEY> {
  InjectedThemeImp({
    required this.lightThemes,
    required this.darkThemes,
    required ThemeMode themeModel,
    required String? persistKey,
    //
    required StateInterceptor<KEY>? stateInterceptor,
    // SnapState<KEY>? Function(MiddleSnapState<KEY> middleSnap)? middleSnapState,
    // void Function(KEY? s)? onInitialized,
    // void Function(KEY s)? onDisposed,
    // On<void>? onSetState,
    required SideEffects<KEY>? sideEffects,
    //
    required DependsOn<KEY>? dependsOn,
    required int undoStackLength,
    //
    required bool autoDisposeWhenNotUsed,
    // required bool isLazy = true,
    required String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(KEY?)? toDebugString,
  }) : _themeMode = themeModel
  // super(
  //   creator: () => lightThemes.keys.first,
  //   initialState: lightThemes.keys.first,
  //   onInitialized: onInitialized,

  //   //
  //   middleSnapState: middleSnapState,
  //   onSetState: onSetState,
  //   onDisposed: onDisposed,
  //   //
  //   dependsOn: dependsOn,
  //   undoStackLength: undoStackLength,
  //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
  //   isLazy: isLazy,
  // debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
  // toDebugString: toDebugString,
  // )

  {
    final persist = persistKey == null
        ? null
        : PersistState(
            key: persistKey,
            fromJson: (json) {
              ///json is of the form key#|#1
              final s = json.split('#|#');
              assert(s.length <= 2);
              final KEY key = lightThemes.keys.firstWhere(
                (k) => s.first == '$k',
                orElse: () => lightThemes.keys.first,
              );
              //
              if (s.last == '0') {
                _themeMode = ThemeMode.light;
              } else if (s.last == '1') {
                _themeMode = ThemeMode.dark;
              } else {
                _themeMode = ThemeMode.system;
              }
              return key;
            },
            toJson: (key) {
              String th = '';
              if (_themeMode == ThemeMode.light) {
                th = '0';
              } else if (_themeMode == ThemeMode.dark) {
                th = '1';
              }

              ///json is of the form key#|#1
              return '$key#|#$th';
            },
            // debugPrintOperations: true,
          );
    injected = Injected<KEY>(
      creator: () => lightThemes.keys.first,
      initialState: lightThemes.keys.first,
      sideEffects: SideEffects<KEY>(
        initState: sideEffects?.initState,
        dispose: () {
          sideEffects?.dispose?.call();
          dispose();
        },
        onAfterBuild: sideEffects?.onAfterBuild,
        onSetState: sideEffects?.onSetState != null
            ? (snap) {
                //For InjectedI18N and InjectedTheme schedule side effects
                //for the next frame.

                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) => sideEffects!.onSetState!(snap),
                );
              }
            : null,
      ),
      stateInterceptor: stateInterceptor,
      persist: persist != null ? () => persist : null,
      undoStackLength: undoStackLength,
      dependsOn: dependsOn,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    ) as InjectedImp<KEY>;
    _resetDefaultState = () {
      _isDarkTheme = false;
      _themeMode = ThemeMode.system;
      isLinkedToTopStatelessWidget = false;
    };
    _resetDefaultState();

    // if (onSetState != null) {
    //   //For InjectedI18N and InjectedTheme schedule side effects
    //   //for the next frame.
    //   subscribeToRM(
    //     (_) {
    //       WidgetsBinding.instance?.addPostFrameCallback(
    //         (_) => onSetState.call(snapState),
    //       );
    //     },
    //   );
    // }
  }

  late InjectedImp<KEY> injected;

  final Map<KEY, ThemeData> lightThemes;
  final Map<KEY, ThemeData>? darkThemes;
  late ThemeMode _themeMode;
  bool _isDarkTheme = false;
  late bool isLinkedToTopStatelessWidget;

  late final VoidCallback _resetDefaultState;

  @override
  Map<KEY, ThemeData> get supportedLightThemes {
    return {...lightThemes};
  }

  @override
  Map<KEY, ThemeData> get supportedDarkThemes {
    if (darkThemes != null) {
      return {...darkThemes!};
    }
    return {};
  }

  bool _onTopWidgetObserverAdded() {
    isLinkedToTopStatelessWidget = true;
    return false;
  }

  @override
  ThemeData get lightTheme {
    TopStatelessWidget.addToObs?.call(
      injected,
      _onTopWidgetObserverAdded,
      null,
    );

    var theme = lightThemes[state];
    theme ??= darkThemes?[state];
    assert(theme != null);
    return theme!;
  }

  @override
  ThemeData? get darkTheme {
    TopStatelessWidget.addToObs?.call(
      injected,
      _onTopWidgetObserverAdded,
      null,
    );
    return darkThemes?[state] ?? lightThemes[state];
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  KEY get state => injected.snapValue.state;
  @override
  set state(KEY value) {
    assert(() {
      _assertIsLinkedToTopStatelessWidget();
      return true;
    }());
    injected.state = value;
  }

  @override
  set themeMode(ThemeMode mode) {
    assert(() {
      _assertIsLinkedToTopStatelessWidget();
      return true;
    }());
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;

    if (injected is InjectedImpRedoPersistState) {
      injected.persistState();
    }

    injected.notify();
  }

  @override
  bool get isDarkTheme {
    if (_themeMode == ThemeMode.system) {
      if (RM.context != null) {
        final brightness = MediaQuery.platformBrightnessOf(RM.context!);
        _isDarkTheme = brightness == Brightness.dark;
      } else {
        _isDarkTheme = false;
      }
    } else {
      _isDarkTheme = _themeMode == ThemeMode.dark;
    }
    ReactiveStatelessWidget.addToObs?.call(injected);
    return _isDarkTheme;
  }

  ///Toggle the current theme between dark and light
  ///
  ///If the current theme has only light (or dark) implementation, the
  ///toggle method will have no effect
  @override
  void toggle() {
    injected.initialize();
    if (isDarkTheme) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }

  void _assertIsLinkedToTopStatelessWidget() {
    if (!isLinkedToTopStatelessWidget) {
      throw ('No Parent InheritedWidget of type [TopReactiveStateless ] is found.\n'
          'Make sure to use [TopReactiveStateless] widget on top of MaterialApp '
          'Widget.\n');
    }
  }

  @override
  void dispose() {
    _resetDefaultState();
  }
}
