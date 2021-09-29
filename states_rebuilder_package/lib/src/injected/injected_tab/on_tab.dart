part of 'injected_page_tab.dart';

// class OnTab {
//   final Widget Function(int index) _on;
//   OnTab(this._on);

//   Widget listenTo(
//     InjectedTab inj, {
//     // void Function()? onInitialized,
//     Key? key,
//   }) {
//     final _injected = inj as InjectedTabImp;
//     // if (_injected._tabController == null) {
//     //   return StateWithMixinBuilder.tickerProvider(
//     //     observe: () => _injected,
//     //     initState: (context, injected, ticker) {
//     //       _injected.initialize(ticker);
//     //     },
//     //     dispose: (context, injected, ticker) {
//     //       _injected.dispose();
//     //     },
//     //     builder: (_, __) {
//     //       return _on(_injected.index);
//     //     },
//     //   );
//     // }
//     // return On.data(() => _on(_injected.index)).listenTo(_injected);

//     return StateBuilderBaseWithTicker<_OnTabWidget>(
//       (widget, setState, ticker) {
//         late VoidCallback disposer;

//         return LifeCycleHooks(
//           mountedState: (_) {
//             if (ticker != null) {
//               _injected.initialize(ticker);
//             }

//             disposer =
//                 _injected.reactiveModelState.listeners.addListenerForRebuild(
//               (_) {
//                 setState();
//               },
//             );
//           },
//           dispose: (_) {
//             if (ticker != null) {
//               _injected.dispose();
//             }
//             disposer();
//           },
//           builder: (context, widget) {
//             // return DefaultTabController(
//             //   initialIndex: _injected.initialIndex,
//             //   length: _injected.length!,
//             //   child: Builder(builder: (context) {
//             // _injected.tabController = DefaultTabController.of(context)!;
//             return widget.on(_injected.index);
//             //   }),
//             // );
//           },
//         );
//       },
//       widget: _OnTabWidget(on: _on),
//       withTicker: () {
//         return _injected._tabController == null;
//       },
//       key: key,
//     );
//   }
// }

// class _OnTabWidget {
//   final Widget Function(int index) on;
//   _OnTabWidget({
//     required this.on,
//   });
// }

class OnTabViewBuilder extends StatefulWidget {
  const OnTabViewBuilder({
    Key? key,
    this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedPageTab? listenTo;
  final Widget Function(int index) builder;

  @override
  _OnTabViewBuilderState createState() => _OnTabViewBuilderState();
}

class _OnTabViewBuilderState extends State<OnTabViewBuilder>
    with TickerProviderStateMixin {
  InjectedPageTabImp? _injected;
  static void Function(InjectedPageTab)? _addToTabObs;
  late VoidCallback removeFromContextSet;
  late VoidCallback disposer;
  bool isWaiting = false;
  dynamic error;
  bool isInitialized = false;
  void _addToObs(InjectedPageTab inj) {
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
    _addToTabObs = _addToObs;
    widget.builder(widget.listenTo?.index ?? 0);
    _addToTabObs = null;
    assert(_injected != null);
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
