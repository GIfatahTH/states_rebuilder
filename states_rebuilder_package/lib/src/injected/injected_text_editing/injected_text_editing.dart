import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';
part 'injected_Form.dart';
part 'on_form.dart';
part 'on_form_submission.dart';

///Inject a TextEditingController
abstract class InjectedTextEditing implements InjectedBaseState<String> {
  TextEditingControllerImp? _controller;

  String get _state => getInjectedState(this);

  ///A controller for an editable text field.
  TextEditingControllerImp get controller;

  ///The current text being edited.
  String get text => state;

  ///The range of text that is currently selected.
  TextSelection get selection => _controller!.value.selection;

  ///The range of text that is still being composed.
  TextRange get composing => _controller!.value.composing;

  ///Input text validator
  String? Function(String? text)? _validator;

  ///Get the error text (as String)
  @override
  dynamic get error;
  // String? get errorText => _errorText;
  set error(dynamic error) {
    assert(error is String?);
    if (error != null && error.isNotEmpty) {
      snapState = snapState.copyToHasError(error, data: this.text);
    } else {
      snapState = snapState.copyToHasData(this.text);
    }
    notify();
  }

  bool? _validateOnLoseFocus;

  ///Whether it passes the validation test
  bool get isValid => hasData;

  ///Get Validator to be used with TextFormField
  // String? Function(String? text)? get validator {
  //   return (_) => error;
  // }

  ///Validate the input text by invoking its validator.
  bool validate() {
    error = _validator?.call(this.text);
    (this as InjectedTextEditingImp).form?.notify();
    return isValid;
  }

  ///Set the field to its initialValue
  void reset();

  FocusNode? _focusNode;

  ///Creates a focus node for this TextField
  FocusNode get focusNode {
    if (_focusNode != null) {
      return _focusNode!;
    }

    _focusNode ??= FocusNode();
    //To cache the auto focused TextField
    SchedulerBinding.instance!.endOfFrame.then((_) {
      final form = (this as InjectedTextEditingImp).form as InjectedFormImp?;
      if (form != null) {
        if (_focusNode?.hasFocus == true) {
          form.autoFocusedNode = _focusNode;
        }
      }
      if (_validateOnLoseFocus == true) {
        _listenToFocusNode();
      }
    });

    return _focusNode!;
  }

  void _listenToFocusNode() {
    var fn;
    fn = () {
      if (!_focusNode!.hasFocus) {
        if (!validate()) {
          //After the first lose of focus and if field is not valid,
          // turn validateOnTyping to true and remove listener
          (this as InjectedTextEditingImp).validateOnTyping = true;
          // _focusNode!.removeListener(fn);// removed (issue 187)
        }
      }
    };
    _focusNode!.addListener(fn);
  }
}

/// InjectedTextEditing implementation
class InjectedTextEditingImp extends InjectedBaseBaseImp<String>
    with InjectedTextEditing {
  InjectedTextEditingImp({
    String text = '',
    TextSelection selection = const TextSelection.collapsed(offset: -1),
    TextRange composing = TextRange.empty,
    String? Function(String?)? validator,
    this.validateOnTyping,
    this.autoDispose = true,
    this.onTextEditing,
    bool? validateOnLoseFocus,
  })  : _validator = validator,
        initialValue = text,
        _initialValidateOnTyping = validateOnTyping,
        _composing = composing,
        _selection = selection,
        super(
          creator: () => text,
          autoDisposeWhenNotUsed: autoDispose,
        ) {
    _validateOnLoseFocus = validateOnLoseFocus;
  }

  final TextSelection _selection;
  final TextRange _composing;
  final bool? _initialValidateOnTyping;
  bool? validateOnTyping;
  bool _formIsSet = false;
  final bool autoDispose;
  final void Function(InjectedTextEditing textEditing)? onTextEditing;
  TextEditingControllerImp get controller {
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
          if (_validateOnLoseFocus == null && validateOnTyping != true) {
            //If the TextField is inside a On.form, set _validateOnLoseFocus to
            //true if it is not
            _validateOnLoseFocus = true;
            // if (_focusNode != null) {
            //   _listenToFocusNode();
            // }
          }
        }
      }
    }
    if (_controller != null) {
      return _controller!;
    }
    _removeFromInjectedList = addToInjectedModels(this);

    _controller ??= TextEditingControllerImp.fromValue(
      TextEditingValue(
        text: initialValue,
        selection: _selection,
        composing: _composing,
      ),
      inj: this,
    );
    if (_validator == null) {
      //If the field is not validate then set its snapshot to hasData, so that
      //in the [InjectedForm.isValid] consider it as a valid field
      snapState = snapState.copyToHasData(text);
    }

    // else {
    //   //IF there is a validator, then set with idle flag so that isValid
    //   //is false unless validator is called
    //   snapState = snapState.copyToIsIdle(this.text);
    // }
    _controller!.addListener(() {
      onTextEditing?.call(this);
      if (_state == _controller!.text) {
        //if only selection is changed notify and return
        notify();
        return;
      }
      snapState = snapState.copyWith(data: _controller!.text);
      if (form != null && validateOnTyping != true) {
        //If form is not null than override the autoValidate of this Injected
        validateOnTyping = form!.autovalidateMode != AutovalidateMode.disabled;
      }
      if (validateOnTyping ?? !(_validateOnLoseFocus ?? false)) {
        validate(); //will be notified in error setter
      } else {
        notify();
      }

      // else {
      //   // if (_validator == null) {
      //   //   snapState = snapState.copyToHasData(this.text);
      //   // } else {
      //   //   //IF there is a validator, then set with idle flag so that isValid
      //   //   //is false unless validator is called
      //   //   snapState = snapState.copyToIsIdle(this.text);
      //   // }
      //   // notify();
      // }
    });

    return _controller!;
  }

  VoidCallback? _removeFromInjectedList;

  ///The associated [InjectedForm]
  InjectedForm? form;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  VoidCallback? formTextFieldDisposer;

  ///The initial value
  final String initialValue;
  @override
  final String? Function(String? text)? _validator;

  @override
  void reset() {
    _controller?.text = initialValue;
    if (_validator == null) {
      snapState = snapState.copyToHasData(initialValue);
    } else {
      //IF there is a validator, then set with idle flag so that isValid
      //is false unless validator is called
      snapState = snapState.copyToIsIdle(initialValue);
    }
    notify();
  }

  @override
  void dispose() {
    super.dispose();
    _removeFromInjectedList?.call();
    _controller?.dispose();
    _controller = null;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      //Dispose after the associated TextField remove its listeners to _focusNode
      _focusNode?.dispose();
      _focusNode = null;
    });
    _formIsSet = false;
    form = null;
    validateOnTyping = _initialValidateOnTyping;
    formTextFieldDisposer?.call();
  }
}

///Custom extension of [TextEditingController]
///
///Used to dispose the associated [InjectedEditingText] if the associated
///Text field is removed from the widget tree.
class TextEditingControllerImp extends TextEditingController {
  TextEditingControllerImp.fromValue(
    TextEditingValue? value, {
    required this.inj,
  }) : super.fromValue(value);
  int _numberOfAddListener = 0;
  final InjectedTextEditingImp inj;
  @override
  void addListener(listener) {
    _numberOfAddListener++;
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    if (inj._controller == null) {
      return;
    }
    _numberOfAddListener--;
    if (_numberOfAddListener < 3) {
      if (inj.autoDispose) {
        inj.dispose();
        return;
      }
    }

    super.removeListener(listener);
  }
}
