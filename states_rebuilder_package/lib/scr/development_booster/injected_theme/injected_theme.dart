import 'package:flutter/material.dart';
import '../../state_management/rm.dart';

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

  /// Get the active [ThemeData] depending on [ThemeMode].
  ///
  /// If themeName is not given the current themeName is used.
  ///
  /// If there is no dark theme, the corresponding light theme is return
  ThemeData activeTheme([KEY? themeName]);

  ///The current [ThemeMode]
  ///
  /// Use [isDarkTheme] to check if the current theme is dark.
  late ThemeMode themeMode;

  ///Wether the current mode is dark.
  ///
  ///If the current [ThemeMode] is system, the darkness is calculated from the
  ///brightness of the system ([MediaQuery.platformBrightnessOf]).
  bool get isDarkTheme;

  /// Toggle the [ThemeMode] between light and dark mode
  void toggle();

  /// Dispose the state
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
    required SideEffects<KEY>? sideEffects,
    //
    required DependsOn<KEY>? dependsOn,
    required int undoStackLength,
    //
    required bool autoDisposeWhenNotUsed,
    required String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(KEY?)? toDebugString,
  }) : _initialThemeMode = themeModel {
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
          _resetDefaultState();
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
      _themeMode = _initialThemeMode;
      isLinkedToTopStatelessWidget = false;
    };
    _resetDefaultState();
  }

  late InjectedImp<KEY> injected;

  final Map<KEY, ThemeData> lightThemes;
  final Map<KEY, ThemeData>? darkThemes;
  late final ThemeMode _initialThemeMode;
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

  bool _onTopWidgetObserverAdded(context) {
    isLinkedToTopStatelessWidget = true;
    return false;
  }

  @override
  ThemeData get lightTheme {
    return _getTheme(state, false);
  }

  @override
  ThemeData get darkTheme {
    return _getTheme(state, true);
  }

  ThemeData _getTheme(KEY key, bool? isGetDark) {
    injected.initialize();
    TopStatelessWidget.addToObs?.call(
      injected,
      _onTopWidgetObserverAdded,
      null,
    );
    if (isGetDark ?? isDarkTheme) {
      var theme = darkThemes?[key];
      if (theme != null) {
        return theme;
      }
    }
    var theme = lightThemes[key];
    theme ??= darkThemes?[key];
    assert(theme != null);
    return theme!;
  }

  @override
  ThemeMode get themeMode {
    ReactiveStatelessWidget.addToObs?.call(injected);
    return _themeMode;
  }

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
      _isDarkTheme = _getSystemBrightness() == Brightness.dark;
    } else {
      _isDarkTheme = _themeMode == ThemeMode.dark;
    }
    ReactiveStatelessWidget.addToObs?.call(injected);
    return _isDarkTheme;
  }

  Brightness _getSystemBrightness() {
    return WidgetsBinding.instance!.window.platformBrightness;
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

  @override
  ThemeData activeTheme([KEY? themeName]) {
    return _getTheme(themeName ?? state, null);
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
    injected.dispose();
  }
}
