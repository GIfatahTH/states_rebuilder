part of '../../reactive_model.dart';

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
    //
  })  : _themes = themes,
        _darkThemes = darkThemes,
        _themeMode = themeMode,
        super(
          creator: (_) => themes.keys.first,
          onInitialized: onInitialized,
          onDisposed: onDisposed,

          on: onSetState,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          //
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        );

  Map<Key, ThemeData> _themes;
  Map<Key, ThemeData> get supportedLightThemes {
    return {..._themes};
  }

  Map<Key, ThemeData>? _darkThemes;

  Map<Key, ThemeData>? get supportedDarkThemes {
    if (_darkThemes != null) {
      return {..._darkThemes!};
    }
    return null;
  }

  ThemeMode _themeMode;

  ThemeData get lightTheme => _themes[state]!;
  ThemeData? get darkTheme => _darkThemes?[state] ?? lightTheme;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    if (_coreRM.persistanceProvider != null) {
      persistState();
    }
    notify();
  }

  bool get isDarkTheme {
    if (_themeMode == ThemeMode.system) {
      if (RM.context != null) {
        final brightness = MediaQuery.platformBrightnessOf(RM.context!);
        return brightness == Brightness.dark;
      }
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  @override
  void toggle() {
    if (isDarkTheme) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
  }
}
