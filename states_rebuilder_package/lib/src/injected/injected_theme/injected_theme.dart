part of '../../reactive_model.dart';

///Injected state that handle the app theme switching.
class InjectedTheme<Key> extends InjectedImp<Key> {
  InjectedTheme({
    required Map<Key, ThemeData> themes,
    required Map<Key, ThemeData>? darkThemes,
    ThemeMode themeMode = ThemeMode.system,
    //
    void Function(Key s)? onInitialized,
    void Function(Key s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<Key>? dependsOn,
    int undoStackLength = 0,
    PersistState<Key> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<Key>? Function(SnapState<Key> state, SnapState<Key> nextState)?
        middleSnapState,

    //
  })  : _themes = themes,
        _darkThemes = darkThemes,
        _themeMode = themeMode,
        super(
          creator: (_) => themes.keys.first,
          onInitialized: onInitialized,
          onDisposed: onDisposed,

          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          //
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          middleSnapState: middleSnapState,
        ) {
    if (onSetState != null) {
      //For InjectedI18N and InjectedTheme schedule side effects
      //for the next frame.
      subscribeToRM(
        (_) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onSetState._call(snapState),
          );
        },
      );
    }
  }

  Map<Key, ThemeData> _themes;

  ///Get supported light themes
  Map<Key, ThemeData> get supportedLightThemes {
    return {..._themes};
  }

  Map<Key, ThemeData>? _darkThemes;

  ///Get supported dark themes
  Map<Key, ThemeData> get supportedDarkThemes {
    if (_darkThemes != null) {
      return {..._darkThemes!};
    }
    return {};
  }

  ThemeMode _themeMode;

  ///Get the current light theme.
  ThemeData get lightTheme {
    var theme = _themes[state];
    if (theme == null) {
      theme = _darkThemes?[state];
    }
    assert(theme != null);
    return theme!;
  }

  ///Get the current dark theme.
  ThemeData? get darkTheme => _darkThemes?[state] ?? _themes[state];

  ///The current [ThemeMode]
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    if (_coreRM.persistanceProvider != null) {
      persistState();
    }
    notify();
  }

  bool _isDarkTheme = false;

  ///Wether the current mode is dark.
  ///
  ///If the current [ThemeMode] is system, the darkness is calculated from the
  ///brightness of the system ([MediaQuery.platformBrightnessOf]).
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
    _initialize();
    if (isDarkTheme) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }

  @override
  void _onDisposeState() {
    super._onDisposeState();
    _isDarkTheme = false;
    _themeMode = ThemeMode.system;
  }
}
