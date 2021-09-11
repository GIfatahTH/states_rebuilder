part of 'injected_text_editing.dart';

abstract class InjectedFormField<T> implements InjectedBaseState<T> {
  late final _baseFormField = this as _BaseFormField;

  T get _state => getInjectedState(this);

  ///Whether it passes the validation test
  bool get isValid;

  T get value => state;
  set value(T v);

  set error(dynamic error);

  void reset() {
    _baseFormField.resetField();
  }

  // ignore: prefer_function_declarations_over_variables
  late void Function(T? v) onChanged = (T? v) {
    value = v as T;
  };

  ///Get the focus node for this FormField
  FocusNode get focusNode {
    if (_baseFormField._focusNode != null) {
      return _baseFormField._focusNode as _FocusNode;
    }
    _baseFormField._focusNode ??= _FocusNode();

    return _baseFormField.__focusNode as _FocusNode;
  }
}

class InjectedFormFieldImp<T> extends InjectedBaseBaseImp<T>
    with InjectedFormField<T>, _BaseFormField<T> {
  InjectedFormFieldImp(
    T initialValue, {
    List<String? Function(T value)>? validator,
    bool? validateOnValueChange,
    bool? validateOnLoseFocus,
    this.onValueChange,
    this.autoDispose = true,
  }) : super(
          creator: () => initialValue,
          autoDisposeWhenNotUsed: autoDispose,
        ) {
    _resetDefaultState = () {
      this.initialValue = initialValue;
      form = null;
      _formIsSet = false;
      _removeFromInjectedList = null;
      formTextFieldDisposer = null;
      _validateOnLoseFocus = validateOnLoseFocus;
      _isValidOnLoseFocusDefined = false;
      _validator = validator;
      _validateOnValueChange = validateOnValueChange;
      _focusNode = null;
      _hasFocus = null;
    };
    _resetDefaultState();
    _validator = validator;
  }
  @override
  final bool autoDispose;
  final void Function(InjectedFormField formField)? onValueChange;
  late bool _formIsSet;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  late VoidCallback? formTextFieldDisposer;
  late VoidCallback? _removeFromInjectedList;

  late final VoidCallback _resetDefaultState;
  late bool? _hasFocus;
  void linkToForm() {
    if (!_formIsSet) {
      form ??= InjectedFormImp._currentInitializedForm;
      if (form != null) {
        _formIsSet = true;
        formTextFieldDisposer =
            (form as InjectedFormImp).addTextFieldToForm(this);

        if (form!.autovalidateMode == AutovalidateMode.always) {
          //When initialized and always auto validated, then validate in the next
          //frame
          WidgetsBinding.instance!.addPostFrameCallback(
            (timeStamp) {
              form!.validate();
            },
          );
        } else {
          if (_validateOnLoseFocus == null && _validateOnValueChange != true) {
            //If the TextField is inside a On.form, set _validateOnLoseFocus to
            //true if it is not
            _validateOnLoseFocus = true;
            if (!_isValidOnLoseFocusDefined) {
              _listenToFocusNodeForValidation();
            }
          }
        }
      }
    }

    _removeFromInjectedList = addToInjectedModels(this);
    if (_validator == null) {
      //If the field is not validate then set its snapshot to hasData, so that
      //in the [InjectedForm.isValid] consider it as a valid field
      snapState = snapState.copyToHasData(initialValue);
    }
  }

  @override
  set value(T v) {
    if (v == value) {
      return;
    }
    snapState = snapState.copyToHasData(v);
    onValueChange?.call(this);

    if (form != null && _validateOnValueChange != true) {
      //If form is not null than override the autoValidate of this Injected
      _validateOnValueChange =
          form!.autovalidateMode != AutovalidateMode.disabled;
    }
    if (_validateOnValueChange ?? !(_validateOnLoseFocus ?? false)) {
      validate(); //will be notified in error setter
    } else {
      notify();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeFromInjectedList?.call();
    _resetDefaultState();
  }
}

class _FocusNode extends FocusNode {
  FocusNode? get childFocusNode {
    Iterable<FocusNode> children = this.children;
    while (true) {
      if (children.isEmpty) {
        break;
      }
      if (children.first.canRequestFocus) {
        break;
      }
      children = children.first.children;
    }
    return children.isNotEmpty ? children.first : null;
  }

  @override
  void requestFocus([FocusNode? node]) {
    super.requestFocus(childFocusNode);
  }

  @override
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) {
    childFocusNode?.unfocus();
  }
}
