part of 'injected_text_editing.dart';

///{@template InjectedFormField}
/// Inject form inputs other than for text editing
///
/// This injected state abstracts the best practices to come out with a
/// simple, clean, and testable approach deal with form inputs and form
/// validation.
///
/// See also :
/// * [OnFormFieldBuilder] to listen to the injected input.
/// * [InjectedTextEditing] to inject a [TextEditingController],
/// * [InjectedForm] and [OnFormBuilder] to work with form.
///
/// Example:
///
/// In most cases, any input form widget have a value and onChanged
/// properties. You must set these properties to the exposed value and
/// onChanged of [OnFormFieldBuilder].
/// This is an example of CheckBox input field
/// ```dart
///   final myCheckBox = RM.injectFormField<bool>(false);
///
///   //In the widget tree
///   OnFormFieldBuilder<bool>(
///    listenTo: myCheckBox,
///    builder: (value, onChanged) {
///      return CheckboxListTile(
///        value: value,
///        onChanged: onChanged,
///        title: Text('I accept the licence'),
///      );
///    },
///   ),
/// ```
///  {@endtemplate}

abstract class InjectedFormField<T> implements IObservable<T> {
  late final _baseFormField = this as _BaseFormField;

  ///Whether it passes the validation test
  bool get isValid;

  /// The value of the Field
  T get value => snapState.state;
  set value(T v);

  /// Set the error
  set error(dynamic error);

  /// reset the field
  void reset() {
    _baseFormField.resetField();
  }

  /// Called when the value of the field changed
  // ignore: prefer_function_declarations_over_variables
  late void Function(T? v) onChanged = (T? v) {
    value = v as T;
  };

  ///Get the focus node for this FormField
  FocusNode get focusNode {
    if (_baseFormField._focusNode != null) {
      return _baseFormField._focusNode as _FocusNode;
    }
    final focus = _baseFormField._focusNode ??= _FocusNode();
    focus.addListener(() {
      if (focus.hasFocus && !isEnabled) {
        Future.microtask(() {
          _canChildRequestFocus(focus.children, false);
          focus.nextFocus();
        });
      }
    });
    return _baseFormField.__focusNode as _FocusNode;
  }

  /// Invoke field validators and return true if the field is valid.
  bool validate();

  /// is the field dirty (its value changed and not submitted yet)
  bool get isDirty;

  /// If true the [TextField] is clickable and selectable but not editable.
  late bool isReadOnly;
  late bool _isEnabled;

  /// If false the associated [TextField] is disabled.
  bool get isEnabled {
    ReactiveStatelessWidget.addToObs?.call(this as ReactiveModelImp);
    return _isEnabled;
  }

  void _canChildRequestFocus(
    Iterable<FocusNode>? children,
    bool canRequestFocus,
  ) {
    try {
      void fn(FocusNode node, bool canRequestFocus) {
        node.canRequestFocus = canRequestFocus;

        for (var e in node.children) {
          fn(e, canRequestFocus);
        }
      }

      for (var e in (children ?? const <FocusNode>[])) {
        fn(e, canRequestFocus);
      }
    } catch (e) {
      rethrow;
    }
  }

  set isEnabled(bool val) {
    _isEnabled = val;
    (this as ReactiveModel).notify();
  }
}

class InjectedFormFieldImp<T> extends ReactiveModelImp<T>
    with InjectedFormField<T>, _BaseFormField<T> {
  InjectedFormFieldImp(
    T initialValue, {
    List<String? Function(T value)>? validator,
    bool? validateOnValueChange,
    bool? validateOnLoseFocus,
    this.onValueChange,
    this.autoDispose = true,
    bool isReadOnly = false,
    bool isEnabled = true,
  }) : super(
          creator: () => initialValue,
          autoDisposeWhenNotUsed: autoDispose,
          initialState: initialValue,
          stateInterceptorGlobal: null,
        ) {
    _resetDefaultState = () {
      this.initialValue = initialValue;
      form = null;
      _formIsSet = false;
      _removeFromInjectedList = null;
      formFieldDisposer = null;
      _validateOnLoseFocus = validateOnLoseFocus;
      _isValidOnLoseFocusDefined = false;
      _validator = validator;
      _validateOnValueChange = validateOnValueChange;
      _focusNode = null;
      _hasFocus = null;
      this.isReadOnly = _initialIsReadOnly = isReadOnly;
      this.isEnabled = _initialIsEnabled = isEnabled;
      isDirty = false;
      _initialIsDirtyText = initialValue;
    };
    _resetDefaultState();
    _validator = validator;
  }
  @override
  final bool autoDispose;
  final void Function(InjectedFormField formField)? onValueChange;
  late bool _formIsSet;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  late VoidCallback? formFieldDisposer;
  late VoidCallback? _removeFromInjectedList;

  late bool? _hasFocus;
  late bool _initialIsEnabled;
  late bool _initialIsReadOnly;
  late final VoidCallback _resetDefaultState;

  T get getState {
    if (form == null) {
      return snapValue.state;
    }
    final _isEnabled = (form as InjectedFormImp)._isEnabled;
    if (_isEnabled != null) {
      this._isEnabled = _isEnabled;
      (form as InjectedFormImp?)?._isEnabled = null;
    } else {
      this._isEnabled = _initialIsEnabled;
    }
    if (_isEnabled != true) {
      final isReadOnly = (form as InjectedFormImp?)?._isReadOnly;
      if (isReadOnly != null) {
        this.isReadOnly = isReadOnly;
      } else {
        this.isReadOnly = _initialIsReadOnly;
      }
    }
    return snapValue.state;
  }

  void linkToForm() {
    if (_formIsSet) return;

    form ??= InjectedFormImp._currentInitializedForm;
    if (form != null) {
      _formIsSet = true;
      formFieldDisposer = (form as InjectedFormImp).addTextFieldToForm(this);

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

    // _removeFromInjectedList = addToInjectedModels(this);
    if (_validator == null) {
      //If the field is not validate then set its snapshot to hasData, so that
      //in the [InjectedForm.isValid] consider it as a valid field
      snapValue = snapValue.copyToHasData(snapState.data);
    }
  }

  @override
  set value(T v) {
    if (isReadOnly) {
      return;
    }

    if (v == value) {
      return;
    }
    isDirty = v != _initialIsDirtyText;
    snapValue = snapValue.copyToHasData(v);
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
    formFieldDisposer?.call();
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
