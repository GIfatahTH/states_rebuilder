part of '../reactive_model.dart';

///{@template topWidget}
///Widget to put on top of the app.
///
///It disposes all non auto disposed injected model when the app closes.
///
///Useful also to dispose resources and reset injected states for test.
///
///It has two optional methods:
///
///   * [didChangeAppLifecycleState] : Called when the system puts the app in
/// the background or returns the app to the foreground.
///   * [didChangeLocales] : Called when the system tells the app that the
/// user's locale has changed. For example, if the user changes the system language settings..
/// {@endtemplate}
class TopWidget extends StatefulWidget {
  ///```dart
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  final void Function(AppLifecycleState state)? didChangeAppLifecycleState;

  ///Called when the system tells the app that the user's locale has changed.
  ///For example, if the user changes the system language settings.
  ///* Required parameters:
  ///   * [List<Locale>] (positional parameter): List of system Locales as defined in
  /// the system language settings
  final void Function(List<Locale>? locale)? didChangeLocales;

  ///Child widget to render
  final Widget Function(BuildContext) builder;

  final InjectedTheme? injectedTheme;
  final InjectedI18N? injectedI18N;

  ///{@macro topWidget}
  const TopWidget({
    Key? key,
    this.didChangeAppLifecycleState,
    this.didChangeLocales,
    this.injectedTheme,
    this.injectedI18N,
    required this.builder,
  }) : super(key: key);

  @override
  _TopWidgetState createState() {
    if (didChangeAppLifecycleState != null ||
        didChangeLocales != null ||
        injectedI18N != null) {
      return _TopWidgetWidgetsBindingObserverState();
    } else {
      return _TopWidgetState();
    }
  }
}

class _TopWidgetState extends State<TopWidget> {
  Widget Function(Widget Function(BuildContext) builder)? _builderTheme;
  Widget Function(Widget Function(BuildContext) builder)? _builderI18N;

  void initState() {
    super.initState();
    if (widget.injectedTheme != null) {
      _builderTheme = (builder) {
        return On(
          () => Builder(
            builder: (context) => builder(context),
          ),
        ).listenTo(widget.injectedTheme!);
      };
    }
    if (widget.injectedI18N != null) {
      _builderI18N = (builder) {
        return widget.injectedI18N!.inherited(
          builder: (context) {
            return _builderTheme?.call(builder) ?? builder(context);
          },
        );
      };
    }
  }

  @override
  void dispose() {
    RM.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _builderI18N?.call(widget.builder) ??
        _builderTheme?.call(widget.builder) ??
        widget.builder(context);
  }
}

class _TopWidgetWidgetsBindingObserverState extends _TopWidgetState
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.didChangeAppLifecycleState?.call(state);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (widget.injectedI18N?.locale is SystemLocale && locales != null) {
      widget.injectedI18N!.locale = locales.first;
    }

    widget.didChangeLocales?.call(locales);
  }
}
