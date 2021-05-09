import 'package:flutter/material.dart';
import '../../rm.dart';

abstract class InjectedTheme<KEY> implements Injected<KEY> {
  ///Get supported light themes
  Map<KEY, ThemeData> get supportedLightThemes;

  ///Get supported dark themes
  Map<KEY, ThemeData> get supportedDarkThemes;

  ///Get the current light theme.
  ThemeData get lightTheme;

  ///Get the current dark theme.
  ThemeData? get darkTheme;

  ///The current [ThemeMode]
  late ThemeMode themeMode;

  ///Wether the current mode is dark.
  ///
  ///If the current [ThemeMode] is system, the darkness is calculated from the
  ///brightness of the system ([MediaQuery.platformBrightnessOf]).
  bool get isDarkTheme;
}

class InjectedThemeImp<KEY> extends InjectedImp<KEY> with InjectedTheme<KEY> {
  InjectedThemeImp({
    required this.lightThemes,
    this.darkThemes,
    ThemeMode themeModel = ThemeMode.system,
    String? persistKey,
    //
    SnapState<KEY>? Function(MiddleSnapState<KEY> middleSnap)? middleSnapState,
    void Function(KEY? s)? onInitialized,
    void Function(KEY s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<KEY>? dependsOn,
    int undoStackLength = 0,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(KEY?)? toDebugString,
  })  : _themeMode = themeModel,
        super(
          creator: () => lightThemes.keys.first,
          initialState: lightThemes.keys.first,
          onInitialized: onInitialized,

          //
          middleSnapState: middleSnapState,
          onSetState: onSetState,
          onDisposed: onDisposed,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
        ) {
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

    if (undoStackLength > 0 || persist != null) {
      undoRedoPersistState = UndoRedoPersistState<KEY>(
        undoStackLength: undoStackLength,
        persistanceProvider: persist,
      );
    }

    if (onSetState != null) {
      //For InjectedI18N and InjectedTheme schedule side effects
      //for the next frame.
      subscribeToRM(
        (_) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onSetState.call(snapState),
          );
        },
      );
    }
  }

  final Map<KEY, ThemeData> lightThemes;
  final Map<KEY, ThemeData>? darkThemes;
  ThemeMode _themeMode = ThemeMode.system;

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

  @override
  ThemeData get lightTheme {
    var theme = lightThemes[state];
    if (theme == null) {
      theme = darkThemes?[state];
    }
    assert(theme != null);
    return theme!;
  }

  @override
  ThemeData? get darkTheme => darkThemes?[state] ?? lightThemes[state];

  @override
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;

    persistState();

    notify();
  }

  bool _isDarkTheme = false;
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
    return _isDarkTheme;
  }

  ///Toggle the current theme between dark and light
  ///
  ///If the current theme has only light (or dark) implementation, the
  ///toggle method will have no effect
  @override
  void toggle() {
    initialize();
    if (isDarkTheme) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isDarkTheme = false;
    _themeMode = ThemeMode.system;
  }
}
