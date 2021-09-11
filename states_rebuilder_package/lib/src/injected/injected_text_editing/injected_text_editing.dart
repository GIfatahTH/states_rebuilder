import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';

part 'on_form_field_builder.dart';
part 'injected_form.dart';
part 'injected_form_field.dart';
part 'on_form.dart';
part 'on_form_submission.dart';
part 'i_base_form_field.dart';

///Inject a TextEditingController
abstract class InjectedTextEditing implements InjectedBaseState<String> {
  late TextEditingControllerImp? _controller;

  late final _baseFormField = this as _BaseFormField;

  ///A controller for an editable text field.
  TextEditingControllerImp get controller;

  ///The current text being edited.
  String get text => state;

  String get _state => getInjectedState(this);

  ///Whether it passes the validation test
  bool get isValid;

  String get value => state;

  ///The range of text that is currently selected.
  TextSelection get selection => _controller!.value.selection;

  ///The range of text that is still being composed.
  TextRange get composing => _controller!.value.composing;

  set error(dynamic error);

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
  })  : _composing = composing,
        _selection = selection,
        super(
          creator: () => text,
          autoDisposeWhenNotUsed: autoDispose,
        ) {
    _resetDefaultState = () {
      initialValue = text;
      _controller = null;
      form = null;
      _formIsSet = false;
      _removeFromInjectedList = null;
      formTextFieldDisposer = null;
      _validateOnLoseFocus = validateOnLoseFocus;
      _isValidOnLoseFocusDefined = false;
      _validator = validator;
      _validateOnValueChange = validateOnTyping;
      _focusNode = null;
    };
    _resetDefaultState();
  }

  @override
  final bool autoDispose;
  final void Function(InjectedTextEditing textEditing)? onTextEditing;

  final TextSelection _selection;
  final TextRange _composing;

  late bool _formIsSet;
  late VoidCallback? _removeFromInjectedList;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  late VoidCallback? formTextFieldDisposer;
//
  late final VoidCallback _resetDefaultState;

  @override
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
            if (!_isValidOnLoseFocusDefined) {
              _listenToFocusNodeForValidation();
            }
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

  @override
  void dispose() {
    super.dispose();
    _removeFromInjectedList?.call();
    _controller?.dispose();
    _controller = null;
    formTextFieldDisposer?.call();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      //Dispose after the associated TextField remove its listeners to _focusNode
      _focusNode?.dispose();
      _resetDefaultState();
    });
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
