part of 'injected_scrolling.dart';

///Listen to an InjectedScrolling
class OnScroll<T> {
  final T Function(InjectedScrolling scroll) onScroll;
  OnScroll(this.onScroll);

  T? call(InjectedScrollingImp scroll) {
    return onScroll(scroll);
  }

  ///Listen to an InjectedScrolling
  Widget listenTo(
    InjectedScrolling injected, {
    Key? key,
  }) {
    return StateBuilderBase<_OnScrollWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        final inj = injected as InjectedScrollingImp;
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = inj.reactiveModelState.listeners.addListenerForRebuild(
              (snap) {
                setState();
                // assert(() {
                //   if (debugPrintWhenRebuild != null) {
                //     StatesRebuilerLogger.log('REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                //   }
                //   return true;
                // }());
              },
              clean: () => inj.dispose(),
            );
            // assert(() {
            //   if (debugPrintWhenRebuild != null) {
            //     StatesRebuilerLogger.log('INITIAL BUILD<' +
            //         debugPrintWhenRebuild +
            //         '>: ${injected.snapState}');
            //   }
            //   return true;
            // }());
          },
          dispose: (_) {
            disposer();
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            // final newInj = newWidget.inject as InjectedScrollingImp;
            // final oldInj = oldWidget.inject as InjectedScrollingImp;
            // if (newInj.reactiveModelState != oldInj.reactiveModelState) {
            //   newInj.reactiveModelState.dispose();
            //   newInj.setReactiveModelState(oldInj.reactiveModelState);
            // }
          },
          builder: (ctx, widget) {
            return widget.on.call(injected)!;
          },
        );
      },
      widget: _OnScrollWidget<Widget>(
        inject: injected,
        on: this as OnScroll<Widget>,
      ),
      key: key,
    );
  }
}

class _OnScrollWidget<T> {
  final InjectedScrolling inject;
  final OnScroll<T> on;
  _OnScrollWidget({
    required this.inject,
    required this.on,
  });
}

class OnScrollBuilder extends StatelessWidget {
  const OnScrollBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedScrolling listenTo;
  final Widget Function(InjectedScrolling) builder;
  @override
  Widget build(BuildContext context) {
    return On.scroll(builder).listenTo(
      listenTo,
      key: key,
    );
  }
}
