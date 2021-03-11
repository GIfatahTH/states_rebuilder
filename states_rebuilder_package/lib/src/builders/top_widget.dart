part of '../reactive_model.dart';

///{@template topWidget}
///Widget to put on top of the app.
///
///It disposes all non auto disposed injected model when the app closes.
///
///Useful also to dispose resources and reset injected states for test.
///
///It is also use to provide and listen to [InjectedTheme], [InjectedI18N]
///
///It can also be used to display a splash screen while initialization plugins.
/// {@endtemplate}
class TopAppWidget extends StatefulWidget {
  ///```dart
  ///Called when the system puts the app in the background or returns the
  ///app to the foreground.
  ///
  final void Function(AppLifecycleState state)? didChangeAppLifecycleState;

  ///Child widget to render
  final Widget Function(BuildContext) builder;

  ///Provide and listen to the [InjectedTheme].
  final InjectedTheme? injectedTheme;

  ///Provide and listen to the [InjectedI18N].
  final InjectedI18N? injectedI18N;
  final InjectedAuth? injectedAuth;

  ///Widget (Splash Screen) to display while it is waiting for dependencies to
  ///initialize.
  final Widget Function()? onWaiting;
  final Widget Function(dynamic error, void Function() refresh)? onError;

  ///List of future to wait for, and display a waiting screen while waiting
  final List<Future> Function()? waiteFor;

  ///{@macro topWidget}
  const TopAppWidget({
    Key? key,
    this.didChangeAppLifecycleState,
    this.injectedTheme,
    this.injectedI18N,
    this.onWaiting,
    this.waiteFor,
    this.onError,
    this.injectedAuth,
    required this.builder,
  })   : assert(
          waiteFor == null || onWaiting != null,
          'You have to define a waiting splash screen '
          'using onWaiting parameter',
        ),
        super(key: key);

  @override
  _TopAppWidgetState createState() {
    if (didChangeAppLifecycleState != null || injectedI18N != null) {
      return _TopWidgetWidgetsBindingObserverState();
    } else {
      return _TopAppWidgetState();
    }
  }
}

class _TopAppWidgetState extends State<TopAppWidget> {
  Widget Function(Widget Function(BuildContext) builder)? _builderTheme;
  Widget Function(Widget Function(BuildContext) builder)? _builderI18N;
  late Widget child;
  bool _isWaiting = false;
  bool _hasError = false;
  dynamic error;
  bool _hasWaiteFor = false;
  void initState() {
    super.initState();
    if (widget.waiteFor != null) {
      _startWaiting();
    }
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
            if (_isWaiting || widget.injectedI18N!.isWaiting) {
              if (widget.onWaiting == null) {
                throw Exception(
                    'TopWidget is waiting for dependencies to initialize. '
                    'you have to define a waiting screen using the onWaiting '
                    'parameter of the TopWidget');
              } else {
                return widget.onWaiting!();
              }
            }
            return _builderTheme?.call(builder) ?? builder(context);
          },
        );
      };
    }
    if (!_hasWaiteFor) {
      child = _builderI18N?.call(widget.builder) ??
          _builderTheme?.call(widget.builder) ??
          widget.builder(context);
    }
  }

  Future<void> _startWaiting() async {
    List<Future> waiteFor = widget.waiteFor!();
    _hasWaiteFor = waiteFor.isNotEmpty;
    if (!_hasWaiteFor) {
      return;
    }

    _isWaiting = true;
    _hasError = false;
    try {
      for (var future in waiteFor) {
        await future;
      }
      setState(() {
        _isWaiting = false;
      });
    } catch (e) {
      setState(() {
        _isWaiting = false;
        _hasError = true;
        error = e;
      });
    } finally {
      child = _builderI18N?.call(widget.builder) ??
          _builderTheme?.call(widget.builder) ??
          widget.builder(context);
    }
  }

  @override
  void dispose() {
    Future.microtask(() => RM.disposeAll());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isWaiting) {
      return widget.onWaiting!();
    }
    if (_hasError && widget.onError != null) {
      return widget.onError!.call(error, () {
        setState(() {
          _isWaiting = true;
          _hasError = false;
        });
        _startWaiting();
      });
    }
    widget.injectedAuth?._initialize();
    widget.injectedI18N?._initialize();
    return child;
  }
}

class _TopWidgetWidgetsBindingObserverState extends _TopAppWidgetState
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
    super.didChangeLocales(locales);
    if (widget.injectedI18N?._locale is SystemLocale && locales != null) {
      widget.injectedI18N!._locale = locales.first;
      widget.injectedI18N!.locale = SystemLocale._(locales.first);
    }
  }
}
