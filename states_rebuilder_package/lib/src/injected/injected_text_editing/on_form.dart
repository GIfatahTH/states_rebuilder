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
    ReactiveModel<bool?>? isEnabled,
    ReactiveModel<bool?>? isReadOnly,
  }) {
    return StateBuilderBase<_OnFormWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        VoidCallback? isEnabledDisposer;
        VoidCallback? isReadOnlyDisposer;
        final inj = injected as InjectedFormImp;
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = inj.reactiveModelState.listeners.addListenerForRebuild(
              (snap) {
                if (!snap!.isWaiting) {
                  setState();
                }

                // assert(() {
                //   if (debugPrintWhenRebuild != null) {
                //     StatesRebuilerLogger.log('REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                //   }
                //   return true;
                // }());
              },
              clean: () => inj.dispose(),
            );
            if (isEnabled != null) {
              isEnabledDisposer =
                  isEnabled.reactiveModelState.listeners.addListenerForRebuild(
                (snap) {
                  setState();
                },
                clean: () => isEnabled.dispose(),
              );
            }

            if (isReadOnly != null) {
              isReadOnlyDisposer =
                  isReadOnly.reactiveModelState.listeners.addListenerForRebuild(
                (snap) {
                  setState();
                },
                clean: () => isReadOnly.dispose(),
              );
            }
          },
          dispose: (_) {
            disposer();
            isEnabledDisposer?.call();
            isReadOnlyDisposer?.call();
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            // final newInj = newWidget.inject as InjectedFormImp;
            // final oldInj = oldWidget.inject as InjectedFormImp;
            // if (newInj.reactiveModelState != oldInj.reactiveModelState) {
            //   newInj.reactiveModelState.dispose();
            //   newInj.setReactiveModelState(oldInj.reactiveModelState);
            // }
          },
          builder: (ctx, widget) {
            // return widget.on.builder();
            final cached = InjectedFormImp._currentInitializedForm;
            InjectedFormImp._currentInitializedForm = inj
              .._isEnabled = isEnabled?.state
              .._isReadOnly = isReadOnly?.state;
            return Stack(
              children: [
                widget.on.builder(),
                Builder(
                  builder: (_) {
                    InjectedFormImp._currentInitializedForm = cached;
                    inj
                      .._isEnabled = null
                      .._isReadOnly = null;
                    return const SizedBox(height: 0, width: 0);
                  },
                ),
              ],
            );
          },
        );
      },
      widget: _OnFormWidget<Widget>(
        inject: injected,
        on: this,
      ),
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

class OnFormBuilder extends StatelessWidget {
  const OnFormBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
    this.isEnabledRM,
    this.isReadOnlyRM,
  }) : super(key: key);
  final InjectedForm listenTo;
  final Widget Function() builder;

  /// ReactiveState of type bool. It is used to set the value of `isEnabled` of
  /// all child input fields.
  ///
  /// Example: Disabling inputs while the form is submitting:
  /// ```dart
  ///  final isEnabledRM = true.inj();
  ///  final formRM =  RM.injectForm(
  ///    submissionSideEffects: SideEffects.onOrElse(
  ///      onWaiting: ()=> isEnabledRM = false,
  ///      orElse: (_)=> isEnabledRM = true,
  ///      submit: () => repository.submitForm( ... ),
  ///    ),
  ///  );
  ///
  ///  // In the widget tree
  ///  OnFormBuilder(
  ///    listenTo: formRM,
  ///    // Adding this all child input's enabled and readOnly properties are controlled.
  ///    isEnabledRM: isEnabledRM,
  ///
  ///    builder: () => Column(
  ///        children: [
  ///          TextField(
  ///            controller: myText.controller,
  ///            enabled: myText.isEnabled,
  ///          ),
  ///          OnFormFieldBuilder<bool>(
  ///            listenTo: myCheckBox,
  ///            builder: (value, onChanged){
  ///              return CheckBoxListTile(
  ///                value: value,
  ///                onChanged: onChanged,
  ///                title: Text('Accept me'),
  ///              );
  ///            }
  ///          )
  ///        ]
  ///    ),
  ///  )
  /// ```
  final ReactiveModel<bool?>? isEnabledRM;

  /// ReactiveState of type bool. It is used to set the value of `isReadOnly` of
  /// all child input fields.
  ///
  /// Example: Make inputs readOnly while the form is submitting:
  /// ```dart
  ///  final isReadOnlyRM = false.inj();
  ///  final formRM =  RM.injectForm(
  ///    submissionSideEffects: SideEffects.onOrElse(
  ///      onWaiting: ()=> isReadOnlyRM = true,
  ///      orElse: (_)=> isReadOnlyRM = false,
  ///      submit: () => repository.submitForm( ... ),
  ///    ),
  ///  );
  ///
  ///  // In the widget tree
  ///  OnFormBuilder(
  ///    listenTo: formRM,
  ///    // Adding this all child input's enabled and readOnly properties are controlled.
  ///    isReadOnlyRM: isReadOnlyRM,
  ///
  ///    builder: () => Column(
  ///        children: [
  ///          TextField(
  ///            controller: myText.controller,
  ///          ),
  ///          OnFormFieldBuilder<bool>(
  ///            listenTo: myCheckBox,
  ///            builder: (value, onChanged){
  ///              return CheckBoxListTile(
  ///                value: value,
  ///                onChanged: onChanged,
  ///                title: Text('Accept me'),
  ///              );
  ///            }
  ///          )
  ///        ]
  ///    ),
  ///  )
  /// ```
  final ReactiveModel<bool?>? isReadOnlyRM;
  @override
  Widget build(BuildContext context) {
    return OnForm(builder).listenTo(
      listenTo,
      isEnabled: isEnabledRM,
      isReadOnly: isReadOnlyRM,
      key: key,
    );
  }
}
