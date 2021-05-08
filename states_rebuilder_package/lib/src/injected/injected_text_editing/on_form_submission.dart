part of 'injected_text_editing.dart';

class OnFormSubmission {
  final Widget Function() onSubmitting;
  final Widget Function(dynamic error, VoidCallback refresh)? onSubmissionError;
  final Widget child;
  OnFormSubmission({
    required this.onSubmitting,
    required this.onSubmissionError,
    required this.child,
  });
  Widget listenTo(
    InjectedForm injected, {
    Key? key,
  }) {
    return StateBuilderBase<_OnFormSubmissionWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        final inj = injected as InjectedFormImp;
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = inj.reactiveModelState.listeners.addListenerForRebuild(
              (snap) {
                if (inj.isWaiting) {
                  inj.onSubmitting?.call();
                } else if (inj.hasError) {
                  // inj.onSubmissionError?.call(inj.error, inj.refresh);
                }
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
            // SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            //   inj.notify();
            // });
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
            final newInj = newWidget.inject as InjectedFormImp;
            final oldInj = oldWidget.inject as InjectedFormImp;
            if (newInj.reactiveModelState != oldInj.reactiveModelState) {
              newInj.reactiveModelState.dispose();
              newInj.setReactiveModelState(oldInj.reactiveModelState);
            }
          },
          builder: (ctx, widget) {
            if (inj.isWaiting) {
              return widget.on.onSubmitting();
            }
            if (inj.hasError && widget.on.onSubmissionError != null) {
              return widget.on.onSubmissionError!(
                  inj.error, inj.onErrorRefresher);
            }
            return widget.on.child;
            // // return widget.on.builder();
            // final cached = InjectedFormImp._currentInitializedForm;
            // InjectedFormImp._currentInitializedForm = inj;
            // return Stack(
            //   children: [
            //     widget.on.builder(),
            //     Builder(
            //       builder: (_) {
            //         InjectedFormImp._currentInitializedForm = cached;
            //         return const SizedBox(height: 0, width: 0);
            //       },
            //     ),
            //   ],
            // );
          },
        );
      },
      widget: _OnFormSubmissionWidget<Widget>(inject: injected, on: this),
      key: key,
    );
  }
}

class _OnFormSubmissionWidget<T> {
  final InjectedForm inject;
  final OnFormSubmission on;
  _OnFormSubmissionWidget({
    required this.inject,
    required this.on,
  });
}
