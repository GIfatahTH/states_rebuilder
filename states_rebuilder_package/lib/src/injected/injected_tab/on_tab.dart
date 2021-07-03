part of 'injected_tab.dart';

class OnTab {
  final Widget Function() _on;
  OnTab(this._on);

  Widget listenTo(
    InjectedTab inj, {
    // void Function()? onInitialized,
    Key? key,
  }) {
    final _injected = inj as InjectedTabImp;

    return StateBuilderBaseWithTicker<_OnTabWidget>(
      (widget, setState, ticker) {
        late VoidCallback disposer;

        return LifeCycleHooks(
          mountedState: (_) {
            if (ticker != null) {
              _injected.initialize(ticker);
            }

            disposer = _injected.reactiveModelState.listeners
                .addListenerForRebuild((_) {
              setState();
            });
          },
          dispose: (_) {
            if (ticker != null) {
              _injected.dispose();
            }
            disposer();
          },
          builder: (_, widget) {
            return widget.on();
          },
        );
      },
      widget: _OnTabWidget(on: _on),
      withTicker: () {
        return _injected._controller == null;
      },
      key: key,
    );
  }
}

class _OnTabWidget {
  final Widget Function() on;
  _OnTabWidget({
    required this.on,
  });
}
