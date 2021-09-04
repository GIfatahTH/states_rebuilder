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

class OnTabBuilder extends StatefulWidget {
  const OnTabBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedPageTab listenTo;
  final Widget Function(int index) builder;

  @override
  _OnTabBuilderState createState() => _OnTabBuilderState();
}

class _OnTabBuilderState extends State<OnTabBuilder>
    with TickerProviderStateMixin {
  late InjectedTabImp _injected = widget.listenTo as InjectedTabImp;
  late VoidCallback disposer;
  @override
  void initState() {
    super.initState();
    if (_injected._tabController == null) {
      _injected.initialize(this);
    }

    disposer = _injected.reactiveModelState.listeners.addListenerForRebuild(
      (_) {
        setState(() {});
      },
      clean:
          _injected.autoDisposeWhenNotUsed ? () => _injected.dispose() : null,
    );
  }

  @override
  void dispose() {
    disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_injected.index);
  }
}
