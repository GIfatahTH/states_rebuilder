part of 'injected_text_editing.dart';

/// Extension on InjectedForm
extension InjectedFormX on InjectedForm {
  /// listen to InjectedForm
  _Rebuild get rebuild => _Rebuild(this);
}

class _Rebuild {
  final InjectedForm inj;
  _Rebuild(this.inj);

  OnFormBuilder onForm(
    Widget Function() builder, {
    Key? key,
    ReactiveModel<bool?>? isEnabledRM,
    ReactiveModel<bool?>? isReadOnlyRM,
  }) {
    return OnFormBuilder(
      key: key,
      listenTo: inj,
      builder: builder,
      isEnabledRM: isEnabledRM,
      isReadOnlyRM: isReadOnlyRM,
    );
  }

  OnFormSubmissionBuilder onFormSubmission({
    Key? key,
    required Widget Function() onSubmitting,
    Widget Function(dynamic, void Function())? onSubmissionError,
    required Widget child,
  }) {
    return OnFormSubmissionBuilder(
      key: key,
      listenTo: inj,
      onSubmitting: onSubmitting,
      onSubmissionError: onSubmissionError,
      child: child,
    );
  }
}

/// Build a form from its child fields
class OnFormBuilder extends MyStatefulWidget {
  /// Build a form from its child fields
  OnFormBuilder({
    Key? key,
    required this.listenTo,
    required Widget Function() builder,
    this.isEnabledRM,
    this.isReadOnlyRM,
    //TODO test and document
    WillPopCallback? onWillPop,
  }) : super(
          key: key,
          observers: (_) {
            return [];
          },
          dispose: (_, __) {
            isEnabledRM?.disposeIfNotUsed();
            isReadOnlyRM?.disposeIfNotUsed();
          },
          shouldRebuild: (old, current) {
            return !current.isWaiting;
          },
          builder: (context, snap, rm) {
            final inj = listenTo as InjectedFormImp;
            final child = OnReactive(() {
              final cached = InjectedFormImp._currentInitializedForm;
              InjectedFormImp._currentInitializedForm = inj
                .._isEnabled = isEnabledRM?.state ?? inj._isEnabled
                .._isReadOnly = isReadOnlyRM?.state ?? inj._isReadOnly;
              return Stack(
                children: [
                  builder(),
                  Builder(
                    builder: (_) {
                      InjectedFormImp._currentInitializedForm = cached;
                      // inj
                      //   .._isEnabled = null
                      //   .._isReadOnly = null;
                      return const SizedBox(height: 0, width: 0);
                    },
                  ),
                ],
              );
            });

            if (onWillPop != null) {
              return WillPopScope(child: child, onWillPop: onWillPop);
            }
            return child;
          },
        );

  /// the InjectedForm to listen to
  final InjectedForm listenTo;
  @override
  List<ReactiveModelImp> Function(BuildContext context) get observers => (_) {
        InjectedFormImp._currentInitializedForm = (listenTo as InjectedFormImp)
          .._isEnabled =
              isEnabledRM?.state ?? (listenTo as InjectedFormImp)._isEnabled
          .._isReadOnly =
              isReadOnlyRM?.state ?? (listenTo as InjectedFormImp)._isReadOnly;
        if (isEnabledRM != null) {
          final disposer = isEnabledRM!.addObserver(
            isSideEffects: false,
            listener: (rm) {
              (listenTo as ReactiveModel).notify();
            },
            shouldAutoClean: true,
          );
          cleaners.add(disposer);
        }

        if (isReadOnlyRM != null) {
          final disposer = isReadOnlyRM!.addObserver(
            isSideEffects: false,
            listener: (rm) {
              (listenTo as ReactiveModel).notify();
            },
            shouldAutoClean: true,
          );
          cleaners.add(disposer);
        }
        return [listenTo as ReactiveModelImp];
      };

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
}
