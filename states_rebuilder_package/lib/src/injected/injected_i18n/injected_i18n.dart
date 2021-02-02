part of '../../reactive_model.dart';

class SystemLocale extends Locale {
  const SystemLocale() : super('systemLocale');
}

class InjectedI18N<I18N> extends InjectedImp<I18N> {
  InjectedI18N({
    required Map<Locale, I18N> i18n,
    //
    void Function(I18N s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    PersistState<I18N> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    //
  })  : _i18n = i18n,
        super(
          creator: (inj) {
            final sysLocal = WidgetsBinding.instance!.window.locales.first;
            return (inj as InjectedI18N)._getLanguage(sysLocal);
          },
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

  Map<Locale, I18N> _i18n;
  List<Locale> get supportedLocales => _i18n.keys.toList();
  Locale get locale => _i18n.keys.firstWhere(
        (key) => _i18n[key] == state,
      );
  Locale? _locale;
  set locale(Locale l) {
    _locale = l;
    setState((s) {
      final lan = _getLanguage(l);
      if (state == lan && l is SystemLocale) {
        //If the system language equal the actual language
        //return null to ensure state persistence.
        return null;
      }
      return lan;
    });
  }

  @override
  void _onDisposeState() {
    super._onDisposeState();
    _locale = null;
  }

  I18N _getLanguage(Locale locale) {
    if (locale is SystemLocale) {
      final sysLocal = WidgetsBinding.instance!.window.locales.first;
      return _getLanguage(sysLocal);
    }

    I18N? l = _i18n[locale];
    if (l != null) {
      return l;
    }

    for (final localeEntry in _i18n.entries) {
      if (localeEntry.key.languageCode == locale.languageCode) {
        return localeEntry.value;
      }
    }
    return _i18n.values.first;
  }
}
