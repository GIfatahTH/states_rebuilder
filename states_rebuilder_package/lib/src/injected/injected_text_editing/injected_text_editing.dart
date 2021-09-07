import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';

part 'on_form_field.dart';
part 'injected_Form.dart';
part 'injected_form_field.dart';
part 'on_form.dart';
part 'on_form_submission.dart';

abstract class _BaseFormField<T> {
  ///The associated [InjectedForm]
  InjectedForm? form;
  T get value;
  bool get hasData;
  bool get hasError;
  bool get autoDispose;
  bool get hasObservers;
  late T? initialValue;
  bool? _validateOnLoseFocus;

  ///Input text validator
  List<String? Function(T value)>? _validator;

  late final _inj = this as InjectedBaseState<T>;

  set error(dynamic error) {
    assert(error is String?);
    if (error != null && error.isNotEmpty) {
      _inj.snapState = _inj.snapState.copyToHasError(error, data: this.value);
    } else {
      _inj.snapState = _inj.snapState.copyToHasData(this.value);
    }
    _inj.notify();
  }

  bool? _validateOnValueChange;
  bool get isValid => hasData;

  ///Validate the input text by invoking its validator.
  bool validate() {
    _inj.snapState = _inj.snapState.copyToHasData(this.value);

    if (_validator != null) {
      for (var e in _validator!) {
        final error = e.call(value);
        if (error != null) {
          _inj.snapState =
              _inj.snapState.copyToHasError(error, data: this.value);
          break;
        }
      }
    }
    if (form != null) {
      form?.notify();
    } else {
      _inj.notify();
    }
    return isValid;
  }

  FocusNode? _focusNode;

  ///Creates a focus node for this TextField
  FocusNode get __focusNode {
    _listenToFocusNode();
    //To cache the auto focused TextField
    SchedulerBinding.instance!.endOfFrame.then((_) {
      final form = this.form as InjectedFormImp?;
      if (form != null) {
        if (_focusNode?.hasFocus == true) {
          form.autoFocusedNode = _focusNode;
        }
      }
    });

    return _focusNode!;
  }

  void _listenToFocusNode() {
    var fn;
    fn = () {
      if (!_focusNode!.hasFocus) {
        validate();
        //After the first lose of focus and if field is not valid,
        // turn _validateOnValueChange to true and remove listener
        _validateOnValueChange = true;
        // _focusNode!.removeListener(fn);// removed (issue 187)

      }
      _inj.notify();
    };
    _focusNode!.addListener(fn);
  }

  void resetField() {
    _inj.snapState = _inj.snapState.copyToHasData(initialValue);
    if (_validator != null) {
      //IF there is a validator, then set with idle flag so that isValid
      //is false unless validator is called
      _inj.snapState = _inj.snapState.copyToIsIdle(initialValue);
    }
    _inj.notify();
  }

  void dispose();
}

///Inject a TextEditingController
abstract class InjectedTextEditing implements InjectedBaseState<String> {
  TextEditingControllerImp? _controller;

  ///A controller for an editable text field.
  TextEditingControllerImp get controller;

  ///The current text being edited.
  String get text => state;

  late final _baseFormField = this as _BaseFormField;

  String get _state => getInjectedState(this);

  ///Whether it passes the validation test
  bool get isValid => _baseFormField.isValid;

  String get value => state;

  ///The range of text that is currently selected.
  TextSelection get selection => _controller!.value.selection;

  ///The range of text that is still being composed.
  TextRange get composing => _controller!.value.composing;

  set error(dynamic error) {
    _baseFormField.error = error;
  }

  void reset() {
    _controller?.text = _baseFormField.initialValue;
    _baseFormField.resetField();
  }

  ///Creates a focus node for this TextField
  FocusNode get focusNode {
    if (_baseFormField._focusNode != null) {
      return _baseFormField._focusNode!;
    }

    _baseFormField._focusNode ??= FocusNode();
    return _baseFormField.__focusNode;
  }
}

/// InjectedTextEditing implementation
class InjectedTextEditingImp extends InjectedBaseBaseImp<String>
    with InjectedTextEditing, _BaseFormField<String> {
  InjectedTextEditingImp({
    String text = '',
    TextSelection selection = const TextSelection.collapsed(offset: -1),
    TextRange composing = TextRange.empty,
    List<String? Function(String?)>? validator,
    bool? validateOnTyping,
    this.autoDispose = true,
    this.onTextEditing,
    bool? validateOnLoseFocus,
  })  : _validator = validator,
        _initialValidateOnTyping = validateOnTyping,
        _composing = composing,
        _selection = selection,
        super(
          creator: () => text,
          autoDisposeWhenNotUsed: autoDispose,
        ) {
    initialValue = text;
    _validateOnValueChange = validateOnTyping;
    _validateOnLoseFocus = validateOnLoseFocus;
  }

  final TextSelection _selection;
  final TextRange _composing;
  final bool? _initialValidateOnTyping;

  bool _formIsSet = false;
  @override
  final bool autoDispose;
  @override
  InjectedForm? form;
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
          if (_validateOnLoseFocus == null && _validateOnValueChange != true) {
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
        text: initialValue ?? '',
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
      if (form != null && _validateOnValueChange != true) {
        //If form is not null than override the autoValidate of this Injected
        _validateOnValueChange =
            form!.autovalidateMode != AutovalidateMode.disabled;
      }
      if (_validateOnValueChange ?? !(_validateOnLoseFocus ?? false)) {
        validate();
      }
      notify();
    });

    return _controller!;
  }

  VoidCallback? _removeFromInjectedList;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  VoidCallback? formTextFieldDisposer;

  @override
  final List<String? Function(String? text)>? _validator;

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
    _validateOnValueChange = _initialValidateOnTyping;
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
