part of 'injected_scrolling.dart';

class OnScroll<T> {
  final T Function()? onTop;
  final T Function()? onBottom;
  final T Function(InjectedScrolling scroll)? onScrolling;
  OnScroll._({
    this.onTop,
    this.onBottom,
    required this.onScrolling,
  });

  factory OnScroll.onTop(T Function() onTop) {
    return OnScroll._(onTop: onTop, onBottom: null, onScrolling: null);
  }

  factory OnScroll.onBottom(T Function() onBottom) {
    return OnScroll._(onTop: null, onBottom: onBottom, onScrolling: null);
  }

  factory OnScroll({
    T Function()? onTop,
    T Function()? onBottom,
    required T Function(InjectedScrolling scroll) onScrolling,
  }) {
    return OnScroll._(
      onTop: onTop,
      onBottom: onBottom,
      onScrolling: onScrolling,
    );
  }

  T? call(InjectedScrollingImp scroll) {
    if (scroll._isOnTop) {
      if (onTop == null) {
        return onScrolling?.call(scroll);
      }
      return onTop!();
    }
    if (scroll._isOnBottom) {
      if (onBottom == null) {
        return onScrolling?.call(scroll);
      }

      return onBottom!();
    }

    return onScrolling!(scroll);
  }
}

extension OnScrollX on OnScroll<Widget> {
  Widget listenTo(
    InjectedScrolling injected, {
    Key? key,
  }) {
    assert(onScrolling != null);
    return StateBuilderBase<_OnScrollWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        final inj = injected as InjectedScrollingImp;
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = inj.reactiveModelState.listeners.addListener(
              (snap) {
                setState();
                // assert(() {
                //   if (debugPrintWhenRebuild != null) {
                //     print('REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                //   }
                //   return true;
                // }());
              },
              clean: () => inj.dispose(),
            );
            // assert(() {
            //   if (debugPrintWhenRebuild != null) {
            //     print('INITIAL BUILD <' +
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
            final newInj = newWidget.inject as InjectedScrollingImp;
            final oldInj = oldWidget.inject as InjectedScrollingImp;
            if (newInj.reactiveModelState != oldInj.reactiveModelState) {
              newInj.reactiveModelState.dispose();
              newInj.setReactiveModelState(oldInj.reactiveModelState);
            }
          },
          builder: (ctx, widget) {
            return widget.on.call(injected)!;
          },
        );
      },
      widget: _OnScrollWidget<Widget>(inject: injected, on: this),
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
