import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import '../../rm.dart';

import 'package:collection/collection.dart';

abstract class InjectedI18N<I18N> implements Injected<I18N> {
  ///Get lists of supported locales
  List<Locale> get supportedLocales;

  ///The current locale
  Locale? locale;

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
      get localeResolutionCallback;
}

class InjectedI18NImp<I18N> extends InjectedImp<I18N> with InjectedI18N<I18N> {
  InjectedI18NImp({
    required this.i18Ns,
    String? persistKey,
    //
    SnapState<I18N>? Function(MiddleSnapState<I18N> middleSnap)?
        middleSnapState,
    void Function(I18N? s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    //
    bool autoDisposeWhenNotUsed = true,
    // bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) : super(
          creator: null,
          onInitialized: onInitialized,
          //
          middleSnapState: middleSnapState,
          // onSetState: onSetState,
          onDisposed: onDisposed,
          //
          dependsOn: dependsOn,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          // isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        ) {
    final persist = persistKey == null
        ? null
        : PersistState<I18N>(
            key: persistKey,
            fromJson: (json) {
              final s = json.split('#|#');
              assert(s.length <= 3);
              if (s.first.isEmpty) {
                return _getLanguage(SystemLocale());
              }
              final l = Locale.fromSubtags(
                languageCode: s.first,
                scriptCode: s.length > 2 ? s[1] : null,
                countryCode: s.last.isNotEmpty ? s.last : null,
              );

              return _getLanguage(l);
            },
            toJson: (key) {
              String l = '';
              if (_locale is SystemLocale) {
                l = '#|#';
              } else {
                l = '${_resolvedLocale!.languageCode}#|#' +
                    (_locale?.scriptCode != null
                        ? '${_resolvedLocale!.scriptCode}#|#'
                        : '') +
                    '${_resolvedLocale!.countryCode}';
              }
              return l;
            },
          );
    if (undoStackLength > 0 || persist != null) {
      undoRedoPersistState = UndoRedoPersistState<I18N>(
        undoStackLength: undoStackLength,
        persistanceProvider: persist,
      );
    }

    reactiveModelState = ReactiveModelBase<I18N>(
      creator: () {
        return _getLanguage(SystemLocale());
      },
      initializer: initialize,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );

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

  final Map<Locale, FutureOr<I18N> Function()> i18Ns;

  Locale? _locale;

  //_resolvedLocale vs _local :
  //_locale may be equal SystemLocale which is not a recognized locale
  //_resolvedLocale is a valid locale from the supported locale list
  Locale? _resolvedLocale;

  @override
  List<Locale> get supportedLocales => i18Ns.keys.toList();

  @override
  Locale? get locale {
    initialize();
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

    return i18Ns[_resolvedLocale]!.call();
  }

  Locale _localeResolution(Locale locale, [bool tryWithSystemLocale = true]) {
    if (i18Ns.keys.contains(locale)) {
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

    final l = i18Ns.keys
        .firstWhereOrNull((l) => locale.languageCode == l.languageCode);
    if (l != null) {
      return l;
    }
    return i18Ns.keys.first;
  }

  Locale _getSystemLocale() {
    return WidgetsBinding.instance!.platformDispatcher.locale;
  }

  @override
  Locale Function(Locale? locale, Iterable<Locale> supportedLocales)
      get localeResolutionCallback => (locale, __) {
            return _resolvedLocale!;
          };

  void didChangeLocales(List<Locale>? locales) {
    if (_locale is SystemLocale && locales != null) {
      _locale = locales.first;
      locale = SystemLocale._(locales.first);
    }
  }

  // @override
  // void initialize() {
  //   super.initialize();
  // }

  @override
  void dispose() {
    super.dispose();
    _locale = null;
    _resolvedLocale = null;
  }
}

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
