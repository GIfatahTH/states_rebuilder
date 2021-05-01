part of 'injected_text_editing.dart';

///Inject a Form state.
///
///Used in conjunction with [On.form].
abstract class InjectedForm implements Injected<String> {
  ///Validate the text fields and return true if they are all valid
  bool validate();

  ///True if all text fields of the form are valid.
  bool get isValid;

  /// Resets the fields to their initial values.
  ///
  /// If any TextField is autoFocused, than it gets focused after reset.
  void reset();

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
class InjectedFormImp extends ReactiveModel<String> with InjectedForm {
  InjectedFormImp({
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : super(creator: () => '');
  @override
  AutovalidateMode autovalidateMode;
  final List<InjectedTextEditingImp> _textFields = [];
  VoidCallback addTextFieldToForm(InjectedTextEditingImp field) {
    _textFields.add(field);
    return () => _textFields.remove(field);
  }

  static InjectedFormImp? _currentInitializedForm;
  FocusNode? _autoFocusedNode;
  @override
  bool get isValid => _textFields.every((e) => e.hasData);

  @override
  bool validate() {
    bool isNotValid = false;
    for (var field in _textFields) {
      isNotValid = !field.validate() || isNotValid;
    }
    return !isNotValid;
  }

  @override
  void reset() {
    for (var field in _textFields) {
      field.reset();
    }
    if (_autoFocusedNode != null) {
      _autoFocusedNode!.requestFocus();
    }
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
