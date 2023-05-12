import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../state_management/rm.dart';

/// Used to manage app localization and internationalization
abstract class InjectedI18N<I18N> {
  ///Get lists of supported locales
  List<Locale> get supportedLocales;

  // I18N get state {
  //   OnReactiveState.addToTopStatelessObs?.call(this);
  //   return getInjectedState(this);
  // }
  /// get the current
  I18N get state;

  ///The current locale language translation
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

  /// return a list of prebuilt LocalizationsDelegates:
  /// [GlobalMaterialLocalizations], [GlobalWidgetsLocalizations] and
  /// [GlobalCupertinoLocalizations]
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates =
      const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Use [of] instead
  Injected<I18N> call(
    BuildContext context, {
    bool defaultToGlobal = false,
  });

  /// Obtain the current translation using [inherited].
  I18N of(
    BuildContext context, {
    bool defaultToGlobal = false,
  });

  /// dispose the state
  void dispose();
}

class InjectedI18NImp<I18N> with InjectedI18N<I18N> {
  InjectedI18NImp({
    required this.i18Ns,
    String? persistKey,
    //
    required StateInterceptor<I18N>? stateInterceptor,
    required SideEffects<I18N>? sideEffects,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    //
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(I18N?)? toDebugString,
  }) {
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
                l = '${_locale!.languageCode}#|#' +
                    (_locale?.scriptCode != null
                        ? '${_locale!.scriptCode}#|#'
                        : '') +
                    '${_locale!.countryCode}';
              }
              return l;
            },
          );
    injected = Injected<I18N>.generic(
      creator: () => _getLanguage(SystemLocale()),
      initialState: null,
      sideEffects: SideEffects<I18N>(
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
                WidgetsBinding.instance.addPostFrameCallback(
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
    ) as InjectedImp<I18N>;
    _resetDefaultState = () {
      _locale = null;
    };
    _resetDefaultState();
  }
  late InjectedImp<I18N> injected;
  final Map<Locale, FutureOr<I18N> Function()> i18Ns;

  Locale? _locale;

  late final VoidCallback _resetDefaultState;
  bool _onTopWidgetObserverAdded(BuildContext context) {
    return true;
  }

  @override
  List<Locale> get supportedLocales {
    TopStatelessWidget.addToObs?.call(
      injected,
      _onTopWidgetObserverAdded,
      didChangeLocales,
    );

    return i18Ns.keys.toList();
  }

  @override
  I18N get state => injected.snapValue.state;
  @override
  Locale? get locale {
    injected.initialize();
    TopStatelessWidget.addToObs?.call(
      injected,
      _onTopWidgetObserverAdded,
      didChangeLocales,
    );

    return _locale;
  }

  @override
  set locale(Locale? l) {
    if (l == null) {
      return;
    }
    if (l is SystemLocale && _locale is SystemLocale) {
      if (l.runtimeType == SystemLocale || _locale == l) {
        return;
      }
    } else if (l is! SystemLocale && _locale is! SystemLocale) {
      if (_locale == l) {
        return;
      }
    }

    final lan = _getLanguage(l);

    injected.setState((s) => lan);
  }

  ///If an exact match for the device locale isn’t found,
  ///then the first supported locale with a matching languageCode is used.
  ///If that fails, then the first element of the supportedLocales list is used.
  FutureOr<I18N> _getLanguage(Locale locale) {
    final l = locale.runtimeType == SystemLocale ? _getSystemLocale() : locale;

    final _resolvedLocale = _localeResolution(l);
    if (locale is SystemLocale) {
      _locale = SystemLocale._(_resolvedLocale);
    } else {
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
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  @override
  Locale Function(Locale? locale, Iterable<Locale> supportedLocales)
      get localeResolutionCallback => (locale, __) {
            return _locale!;
          };

  void didChangeLocales(List<Locale>? locales) {
    if (_locale is SystemLocale && locale != null) {
      locale = _SystemLocaleInternal(locales!.first);
    }
  }

  // @override
  // void initialize() {
  //   super.initialize();
  // }
  @override
  I18N of(
    BuildContext context, {
    bool defaultToGlobal = false,
  }) {
    try {
      return injected.of(
        context,
        defaultToGlobal: defaultToGlobal,
      );
    } catch (e) {
      final widget = context.widget;
      if (widget is TopStatelessWidget) {
        throw ('No Parent InheritedWidget of type [TopStatelessWidget] is found.\n'
            'There are several ways to avoid this problem. The simplest is to '
            'use a Builder to get a context that is "under" the [TopReactiveStateless].\n'
            'A more efficient solution is to split your build function into several widgets. This '
            'introduces a new context from which you can obtain the [TopReactiveStateless].\n'
            '${context.describeElement('The context used was')}');
      }
      throw ('No Parent InheritedWidget of type [TopReactiveStateless ] is found.\n'
          'Make sure to use [TopReactiveStateless] widget on top of MaterialApp '
          'Widget.\n'
          '${context.describeElement('The context used was')}');
    }
  }

  @override
  Injected<I18N> call(
    BuildContext context, {
    bool defaultToGlobal = false,
  }) {
    throw Exception(
      'Use of(context) method instead',
    );
  }

  @override
  void dispose() {
    _resetDefaultState();
  }
}

///Used to represent the locale of the system.
class SystemLocale extends Locale {
  SystemLocale._(Locale locale)
      : super.fromSubtags(
          languageCode: locale.languageCode,
          countryCode:
              locale.countryCode?.isEmpty == true ? null : locale.countryCode,
          scriptCode: locale.scriptCode,
        );
  factory SystemLocale() {
    return SystemLocale._(const Locale('systemLocale'));
  }
}

class _SystemLocaleInternal extends SystemLocale {
  _SystemLocaleInternal(Locale locale) : super._(locale);
}
