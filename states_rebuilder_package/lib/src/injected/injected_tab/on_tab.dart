part of 'injected_page_tab.dart';

class OnTabPageViewBuilder extends StatefulWidget {
  const OnTabPageViewBuilder({
    Key? key,
    this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedTabPageView? listenTo;
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
      _injected?.initialize(this);
      disposer = _injected!.reactiveModelState.listeners.addListenerForRebuild(
        (_) {
          setState(() {});
        },
        clean: _injected!.autoDisposeWhenNotUsed
            ? () => _injected!.dispose()
            : null,
      );
      return;
    }

    void _addToObs(InjectedTabPageView inj) {
      if (_injected != null) {
        return;
      }
      _injected = inj as InjectedPageTabImp;
      _injected?.initialize(this);
      disposer = inj.observeForRebuild(
        (rm) {
          setState(() {});
        },
        clean: inj.autoDisposeWhenNotUsed ? () => inj.dispose() : null,
      );
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
