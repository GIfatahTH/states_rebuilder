part of 'injected_page_tab.dart';

/// Extension on InjectedTabPageView
extension InjectedTabPageViewX on InjectedTabPageView {
  /// listen to InjectedTabPageView
  _Rebuild get rebuild => _Rebuild(this);
}

class _Rebuild {
  final InjectedTabPageView inj;
  _Rebuild(this.inj);
  OnTabPageViewBuilder onTabPageView(
    Widget Function(int) builder, {
    Key? key,
  }) {
    return OnTabPageViewBuilder(
      key: key,
      listenTo: inj,
      builder: builder,
    );
  }

  call(Widget Function() builder) {
    return OnBuilder(
      listenTo: inj,
      builder: builder,
    );
  }
}

/// Listen to [InjectedTabPageView].
///
/// In most cases, the [InjectedTabPageView] can be inferred implicitly. If it
/// can not It must be explicitly defined using `listenTo` parameter.
class OnTabPageViewBuilder extends StatefulWidget {
  /// Listen to [InjectedTabPageView].
  ///
  /// In most cases, the [InjectedTabPageView] can be inferred implicitly. If it
  /// can not It must be explicitly defined using `listenTo` parameter.
  const OnTabPageViewBuilder({
    Key? key,
    this.listenTo,
    required this.builder,
  }) : super(key: key);

  /// [InjectedTabPageView] to listen to. If not defined, the
  /// [InjectedTabPageView] is deduced implicitly. If it is not, it throws.
  final InjectedTabPageView? listenTo;

  /// The builder callback, it exposes the current index.
  final Widget Function(int index) builder;

  @override
  _OnTabPageViewBuilderState createState() => _OnTabPageViewBuilderState();
}

class _OnTabPageViewBuilderState extends State<OnTabPageViewBuilder>
    with TickerProviderStateMixin {
  InjectedPageTabImp? _injected;
  static void Function(InjectedTabPageView)? _addToTabObs;
  late VoidCallback removeFromContextSet;
  late VoidCallback disposer;

  @override
  void initState() {
    super.initState();
    removeFromContextSet = addToContextSet(context);

    _injected = widget.listenTo as InjectedPageTabImp?;
    if (_injected != null) {
      _injected?.initializer(this);
      if (_injected!.autoDisposeWhenNotUsed) {
        // ignore: unused_result
        _injected!.addCleaner(() {
          _injected!.dispose();
        });
      }
      disposer = _injected!.addObserver(
        isSideEffects: false,
        listener: (_) {
          setState(() {});
        },
        shouldAutoClean: _injected!.autoDisposeWhenNotUsed,
      );
      return;
    }

    void _addToObs(InjectedTabPageView inj) {
      if (_injected != null) {
        return;
      }
      _injected = inj as InjectedPageTabImp;
      _injected?.initializer(this);
      if (inj.autoDisposeWhenNotUsed) {
        // ignore: unused_result
        inj.addCleaner(() {
          inj.dispose();
        });

        disposer = inj.addObserver(
          isSideEffects: false,
          listener: (rm) {
            setState(() {});
          },
          shouldAutoClean: inj.autoDisposeWhenNotUsed,
        );
      }
    }

    _addToTabObs = _addToObs;
    widget.builder(widget.listenTo?.index ?? 0);
    _addToTabObs = null;
    assert(() {
      if (_injected == null) {
        StatesRebuilerLogger.log(
          '`OnTabViewBuilder` can not implicitly defined any `InjectedTabPage`',
          'Use `OnTabViewBuilder.listenTo` param to explicitly define the `InjectedTabPage`',
        );
        return false;
      }
      return true;
    }());
  }

  @override
  void dispose() {
    disposer();
    removeFromContextSet();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_injected!.index);
  }
}
