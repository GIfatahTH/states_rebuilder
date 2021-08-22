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
    return On.form(builder).listenTo(
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
    return On.formSubmission(
      onSubmitting: onSubmitting,
      onSubmissionError: onSubmissionError,
      child: child,
    ).listenTo(
      _injected,
      key: key,
    );
  }
}

///Inject a Form state.
///
///Used in conjunction with [On.form].
abstract class InjectedForm implements InjectedBaseState<bool?> {
  ///Listen to the [InjectedForm] and rebuild when it is notified.
  late final rebuild = _RebuildForm(this);

  ///Validate the text fields and return true if they are all valid
  bool validate();

  ///True if all text fields of the form are valid.
  bool get isValid;

  /// Resets the fields to their initial values.
  ///
  /// If any TextField is autoFocused, than it gets focused after reset.
  void reset();

  void submit([Future<void> Function()? fn]);

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
  FocusNode? _submitFocusNode;

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
    this.autovalidateMode = AutovalidateMode.disabled,
    this.autoFocusOnFirstError = true,
    this.onSubmitting,
    this.onSubmitted,
    Future<void> Function()? submit,
  })  : _submit = submit,
        super(creator: () => null);
  @override
  AutovalidateMode autovalidateMode;

  final void Function()? onSubmitting;
  final void Function()? onSubmitted;
  Future<void> Function()? _submit;
  // final void Function(dynamic error, VoidCallback refresh)? onSubmissionError;

  ///After form is validate, get focused on the first non valid TextField, if any.
  final bool autoFocusOnFirstError;
  final List<InjectedTextEditingImp> _textFields = [];
  VoidCallback addTextFieldToForm(InjectedTextEditingImp field) {
    _textFields.add(field);
    return () => _textFields.remove(field);
  }

  static InjectedFormImp? _currentInitializedForm;
  FocusNode? autoFocusedNode;
  @override
  bool get isValid => _textFields.every((e) => e.hasData);

  @override
  bool validate() {
    bool isNotValid = false;
    InjectedTextEditingImp? firstErrorField;
    for (var field in _textFields) {
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
    for (var field in _textFields) {
      field.reset();
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
          notify();
          await result;
        }
        snapState = snapState.copyToHasData(null);
        onSubmitted?.call();
        if (autoFocusOnFirstError) {
          InjectedTextEditingImp? firstErrorField;
          for (var field in _textFields) {
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
        snapState = snapState.copyToHasError(e,
            stackTrace: s, onErrorRefresher: () => submit(fn));
        notify();
      }
    }

    await setState(
      () => fn == null ? _submit?.call() : fn(),
    );

    // Future<void> Function() call;
    // call = () async {
    //   try {
    //     snapState = snapState.copyToIsWaiting();
    //     notify();
    //     await (fn == null ? _submit?.call() : fn());
    //     snapState = snapState.copyToHasData(null);
    //     if (autoFocusOnFirstError) {
    //       InjectedTextEditingImp? firstErrorField;
    //       for (var field in _textFields) {
    //         if (field.hasError) {
    //           firstErrorField = field;
    //           break;
    //         }
    //       }
    //       if (firstErrorField != null) {
    //         firstErrorField._focusNode?.requestFocus();
    //       }
    //     }
    //     onSubmitted?.call();
    //     notify();
    //   } catch (e) {
    //     if (e is Error) {
    //       rethrow;
    //     }
    //     snapState = snapState.copyToHasData(null);
    //   }
    // };
    // await call();
  }

  @override
  void dispose() {
    super.dispose();
    _submitFocusNode?.dispose();
    _submitFocusNode = null;
    for (var field in [..._textFields]) {
      if (field.autoDispose && !field.hasObservers) {
        field.dispose();
      }
    }
  }
}
