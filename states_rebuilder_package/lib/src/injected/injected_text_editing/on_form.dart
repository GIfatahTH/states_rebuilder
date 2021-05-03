part of 'injected_text_editing.dart';

///Used to listen to [InjectedForm] state.
///
///It associates child TextFiled or TextFormField to the [InjectedForm] state.
class OnForm {
  final Widget Function() builder;
  OnForm(this.builder);

  ///Listen to to [InjectedForm] state, and associate the child TextFields to the
  ///[InjectedForm] state
  Widget listenTo(
    InjectedForm injected, {
    Key? key,
  }) {
    return StateBuilderBase<_OnFormWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        final inj = injected as InjectedFormImp;
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
            // return widget.on.builder();
            final cached = InjectedFormImp._currentInitializedForm;
            InjectedFormImp._currentInitializedForm = inj;
            return Stack(
              children: [
                widget.on.builder(),
                Builder(
                  builder: (_) {
                    InjectedFormImp._currentInitializedForm = cached;
                    return const SizedBox(height: 0, width: 0);
                  },
                ),
              ],
            );
          },
        );
      },
      widget: _OnFormWidget<Widget>(inject: injected, on: this),
      key: key,
    );
  }
}

class _OnFormWidget<T> {
  final InjectedForm inject;
  final OnForm on;
  _OnFormWidget({
    required this.inject,
    required this.on,
  });
}
