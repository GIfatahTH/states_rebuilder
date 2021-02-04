part of '../../reactive_model.dart';

///Used to represent the locale of the system.
class SystemLocale extends Locale {
  const SystemLocale() : super('systemLocale');
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

  ///Get lists of supported locales
  List<Locale> get supportedLocales => _i18n.keys.toList();

  ///The current locale
  Locale get locale => _locale!;
  Locale? _locale;
  set locale(Locale l) {
    if (_locale == l) {
      return;
    }
    final lan = _getLanguage(l);
    setState((s) => lan);
  }

  @override
  void _onDisposeState() {
    super._onDisposeState();
    _locale = null;
  }

  ///If an exact match for the device locale isn’t found,
  ///then the first supported locale with a matching languageCode is used.
  ///If that fails, then the first element of the supportedLocales list is used.
  FutureOr<I18N> _getLanguage(Locale locale) {
    if (locale is SystemLocale) {
      final l = WidgetsBinding.instance!.window.locales.first;
      _resolvedLocale = _localeResolution(l);
      _locale = SystemLocale();
    } else {
      _resolvedLocale = _localeResolution(locale);
      _locale = locale;
    }

    final lan = _i18n[_resolvedLocale]?.call();
    print(_i18n.keys);
    print(lan);
    return lan!;
  }

  Locale _localeResolution(Locale locale) {
    if (_i18n.keys.contains(locale)) {
      return locale;
    }
    final l = _i18n.keys
        .firstWhereOrNull((l) => locale.languageCode == l.languageCode);
    if (l != null) {
      return l;
    }
    return _i18n.keys.first;
  }

  //_resolvedLocale vs _local :
  //_locale may be equal SystemLocale which is not a recognized locale
  //_resolvedLocale is a valid locale from the supported locale list
  late Locale _resolvedLocale;

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
            return _resolvedLocale;
          };
}
