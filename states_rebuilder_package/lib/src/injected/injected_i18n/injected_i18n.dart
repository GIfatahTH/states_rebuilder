part of '../../reactive_model.dart';

///Used to represent the locale of the system.
class SystemLocale extends Locale {
  final Locale? _locale;

  const SystemLocale._(this._locale) : super('systemLocale');

  factory SystemLocale() {
    return const SystemLocale._(null);
  }
  bool operator ==(Object o) {
    return o is SystemLocale;
  }

  @override
  int get hashCode => 0;
}

///Injected state that handles app internationalization and localization
class InjectedI18N<I18N> extends InjectedImp<I18N> {
  InjectedI18N({
    required Map<Locale, FutureOr<I18N> Function()> i18n,
    //
    void Function(I18N s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    PersistState<I18N> Function()? persist,
    //
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    //
  })  : _i18n = i18n,
        super(
          creator: (inj) {
            return (inj as InjectedI18N)._getLanguage(SystemLocale());
          },
          onInitialized: onInitialized,
          onDisposed: onDisposed,

          on: onSetState,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          //
          autoDisposeWhenNotUsed: false,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        );

  Map<Locale, FutureOr<I18N> Function()> _i18n;

  Locale? _locale;

  //_resolvedLocale vs _local :
  //_locale may be equal SystemLocale which is not a recognized locale
  //_resolvedLocale is a valid locale from the supported locale list
  Locale? _resolvedLocale;

  ///Get lists of supported locales
  List<Locale> get supportedLocales => _i18n.keys.toList();

  ///The current locale
  Locale? get locale {
    _initialize();
    return _locale is SystemLocale ? _resolvedLocale : _locale;
  }

  set locale(Locale? l) {
    if (l == null || _locale == l) {
      return;
    }
    final lan = _getLanguage(l);
    setState((s) => lan);
  }

  ///If an exact match for the device locale isn’t found,
  ///then the first supported locale with a matching languageCode is used.
  ///If that fails, then the first element of the supportedLocales list is used.
  FutureOr<I18N> _getLanguage(Locale locale) {
    if (locale is SystemLocale) {
      var l = locale._locale != null ? locale._locale! : _getSystemLocale();
      _resolvedLocale = _localeResolution(l);
      _locale = SystemLocale();
    } else {
      _resolvedLocale = _localeResolution(locale);
      _locale = _resolvedLocale;
    }

    return _i18n[_resolvedLocale]!.call();
  }

  Locale _localeResolution(Locale locale, [bool tryWithSystemLocale = true]) {
    if (_i18n.keys.contains(locale)) {
      return locale;
    }
    //If locale is not supported,
    //check if it has the same language code as the system local
    if (tryWithSystemLocale) {
      final sys = _getSystemLocale();
      if (locale.languageCode == sys.languageCode) {
        return _localeResolution(sys, false);
      }
    }

    final l = _i18n.keys
        .firstWhereOrNull((l) => locale.languageCode == l.languageCode);
    if (l != null) {
      return l;
    }
    return _i18n.keys.first;
  }

  Locale _getSystemLocale() {
    return WidgetsBinding.instance!.window.locales.first;
  }

  ///Default locale resolution used by states_rebuilder.
  ///
  ///It first research for an exact match of the chosen locale in the list
  ///of supported locales, if no match exists, it search for the language
  ///code match, if it fails the first language is the supported language
  ///will be used.
  ///
  ///for more elaborate logic, use [MaterialApp.localeListResolutionCallback]
  ///and define your logic.
  Locale Function(Locale? locale, Iterable<Locale> supportedLocales)
      get localeResolutionCallback => (locale, __) {
            return _resolvedLocale!;
          };

  @override
  void _onDisposeState() {
    super._onDisposeState();
    _locale = null;
    _resolvedLocale = null;
  }
}
