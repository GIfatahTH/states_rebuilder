part of 'injected_text_editing.dart';

class _RebuildForm {
  final InjectedForm _injected;
  _RebuildForm(this._injected);

  ///Listen to the [InjectedForm] and rebuild when it is notified.
  ///
  ///The first positional parameter is a callback the return a widget that must
  ///contains all the [TextField] related to this form associated with their
  ///[InjectedTextEditing].
  Widget onForm(
    Widget Function() builder, {
    Key? key,
  }) {
    return OnForm(builder).listenTo(
      _injected,
      key: key,
    );
  }

  ///Listen to the [InjectedForm] and rebuild when it is submitted.
  ///
  ///[onSubmitting] defined the widget to display when the form is waiting for
  ///submission
  ///
  ///[onSubmissionError] defines the widget to display when the form submission
  ///fails. It exposes the error and a callback to resubmit the form again with
  ///the last valid data.
  Widget onFormSubmission({
    required Widget Function() onSubmitting,
    Widget Function(dynamic, void Function())? onSubmissionError,
    required Widget child,
    Key? key,
  }) {
    return OnFormSubmission(
      onSubmitting: onSubmitting,
      onSubmissionError: onSubmissionError,
      child: child,
    ).listenTo(
      _injected,
      key: key,
    );
  }
}

///{@template InjectedForm}
/// Inject a form that controls all [TextField] and [OnFormFieldBuilder]
/// instantiated inside its builder method.
///
/// If the application you are working on contains dozens of TextFields,
/// it becomes tedious to process each field individually. `Form` helps us
/// collect many TextFields and manage them as a unit.
///
/// With [InjectedForm] you can validate all input fields in the front end,
/// submit them and do server side validation.
///
/// Example: Supposing we have already defined email and password
/// [InjectedTextEditing]
///
/// ```dart
///  final form = RM.injectForm(
///    submit: () async {
///      //This is the default submission logic,
///      //It may be override when calling form.submit( () async { });
///      //It may contains server validation.
///     await serverError =  authRepository.signInWithEmailAndPassword(
///        email: email.text,
///        password: password.text,
///      );
///
///      //after server validation
///      if(serverError == 'Invalid-Email'){
///        email.error = 'Invalid email';
///      }
///      if(serverError == 'Weak-Password'){
///        email.error = 'Password must have more the 6 characters';
///      }
///    },
///  );
/// ```
///
/// Once [InjectedForm.submit] is invoked, input field are first validate in
/// the front end. If they are valid, submit is called. After waiting for
/// submission, if it ends with server error we set it our field to display
/// the server validation.
///
/// See also :
/// * [OnFormBuilder]  to listen to [InjectedForm].
/// * [OnFormFieldBuilder] to listen to the injected input.
/// * [InjectedTextEditing] to inject a [TextEditingController],
///  {@endtemplate}

abstract class InjectedForm implements InjectedBaseState<bool?> {
  ///Listen to the [InjectedForm] and rebuild when it is notified.
  late final rebuild = _RebuildForm(this);

  /// Used to enable/disable this form field auto validation and update its
  /// error text.
  ///
  ///
  /// If [AutovalidateMode.onUserInteraction] this form fields will only
  /// auto-validate after its content changes, if [AutovalidateMode.always] they
  /// will auto validate even without user interaction and
  /// if [AutovalidateMode.disabled] the auto validation will be disabled.
  ///
  /// It defaults to [AutovalidateMode.disabled].
  late AutovalidateMode autovalidateMode;
  late FocusNode? _submitFocusNode;

  ///Validate the text fields and return true if they are all valid
  bool validate();

  ///True if all text fields of the form are valid.
  bool get isValid;

  /// Resets the fields to their initial values.
  ///
  /// If any TextField is autoFocused, than it gets focused after reset.
  void reset();

  void submit([Future<void> Function()? fn]);

  ///Creates a focus node to be used with submit button
  FocusNode get submitFocusNode => _submitFocusNode ??= FocusNode();

  // ///Requests the primary focus for this node (Submit button),
  // void requestSubmitFocus() {
  //   submitFocusNode.requestFocus();
  // }
}

///Implementation of [InjectedForm]
class InjectedFormImp extends InjectedBaseBaseImp<bool?> with InjectedForm {
  InjectedFormImp({
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    this.autoFocusOnFirstError = true,
    this.onSubmitting,
    this.onSubmitted,
    this.sideEffects,
    Future<void> Function()? submit,
  })  : _submit = submit,
        super(creator: () => null) {
    _resetDefaultState = () {
      this.autovalidateMode = autovalidateMode;
      _submitFocusNode = null;
      _currentInitializedForm = null;
      autoFocusedNode = null;
      _isEnabled = null;
      _isReadOnly = null;
    };
    _resetDefaultState();
  }

  final void Function()? onSubmitting;
  final void Function()? onSubmitted;
  final SideEffects? sideEffects;
  final Future<void> Function()? _submit;
  // final void Function(dynamic error, VoidCallback refresh)? onSubmissionError;

  ///After form is validate, get focused on the first non valid TextField, if any.
  final bool autoFocusOnFirstError;
  final List<_BaseFormField> _fields = [];
  VoidCallback addTextFieldToForm(_BaseFormField field) {
    _fields.add(field);
    return () => _fields.remove(field);
  }

  static InjectedFormImp? _currentInitializedForm;
  late FocusNode? autoFocusedNode;
  late bool? _isEnabled;
  late bool? _isReadOnly;
  late final VoidCallback _resetDefaultState;

  @override
  bool get isValid => _fields.every((e) => e.isValid);

  @override
  bool validate() {
    bool isNotValid = false;
    _BaseFormField? firstErrorField;
    for (var field in _fields) {
      isNotValid = !field.validate() || isNotValid;
      firstErrorField ??= isNotValid ? field : null;
    }
    if (autoFocusOnFirstError) {
      firstErrorField?._focusNode?.requestFocus();
    }
    return !isNotValid;
  }

  @override
  void reset() {
    for (var field in _fields) {
      if (field is InjectedTextEditing) {
        (field as InjectedTextEditing).reset();
      } else {
        field.resetField();
      }
    }
    autoFocusedNode?.requestFocus();
    if (autovalidateMode == AutovalidateMode.always) {
      validate();
    } else {
      notify();
    }
  }

  @override
  void submit([Future<void> Function()? fn]) async {
    if (!validate()) {
      return;
    }
    Future<void> setState(Function()? call) async {
      dynamic result = call?.call();
      try {
        if (result is Future) {
          snapState = snapState.copyToIsWaiting();
          sideEffects
            ?..onSetState?.call(snapState)
            ..onAfterBuild?.call();
          notify();
          await result;
        }
        snapState = snapState.copyToHasData(null);
        onSubmitted?.call();
        sideEffects
          ?..onSetState?.call(snapState)
          ..onAfterBuild?.call();
        if (autoFocusOnFirstError) {
          _BaseFormField? firstErrorField;
          for (var field in _fields) {
            if (field.hasError) {
              firstErrorField = field;
              break;
            }
          }
          if (firstErrorField != null) {
            firstErrorField._focusNode?.requestFocus();
          }
        }
        notify();
      } catch (e, s) {
        snapState = snapState.copyToHasError(
          e,
          stackTrace: s,
          onErrorRefresher: () => submit(fn),
        );
        sideEffects
          ?..onSetState?.call(snapState)
          ..onAfterBuild?.call();
        notify();
      }
    }

    await setState(
      () => fn == null ? _submit?.call() : fn(),
    );
  }

  void enableFields(bool isEnabled) {
    for (var field in _fields) {
      field._isEnabled = isEnabled;
    }
  }

  void readOnlyFields(bool isReadOnly) {
    for (var field in _fields) {
      field.isReadOnly = isReadOnly;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _submitFocusNode?.dispose();
    for (var field in [..._fields]) {
      if (field.autoDispose && !field.hasObservers) {
        field.dispose();
      }
    }
    _resetDefaultState();
  }
}
