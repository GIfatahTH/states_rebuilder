import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';
part 'injected_Form.dart';
part 'on_form.dart';

///Inject a TextEditingController
abstract class InjectedTextEditing implements Injected<String> {
  TextEditingControllerImp? _controller;

  ///A controller for an editable text field.
  TextEditingControllerImp get controller;

  ///The current text being edited.
  String get text => _controller!.value.text;

  ///The range of text that is currently selected.
  TextSelection get selection => _controller!.value.selection;

  ///The range of text that is still being composed.
  TextRange get composing => _controller!.value.composing;

  ///Input text validator
  String? Function(String? text)? _validator;
  String? _errorText;

  ///Whether it passes the validation test
  bool get isValid => hasData;

  ///Get Validator to be used with TextFormField
  String? Function(String? text)? get validator {
    return (_) => _errorText;
  }

  ///Validate the input text by invoking its validator.
  bool validate() {
    _errorText = _validator?.call(this.text);

    if (_errorText != null && _errorText!.isNotEmpty) {
      snapState = snapState.copyToHasError(_errorText!, data: this.text);
    } else {
      snapState = snapState.copyToHasData(this.text);
    }
    notify();
    (this as InjectedTextEditingImp).form?.notify();
    return _errorText == null;
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
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        //After too frame, to ensure the focused field is initialized
        if (_focusNode?.hasFocus == true) {
          final form =
              (this as InjectedTextEditingImp).form as InjectedFormImp?;
          form?._autoFocusedNode = _focusNode;
        }
      });
    });
    return _focusNode!;
  }
}

/// InjectedTextEditing implementation
class InjectedTextEditingImp extends ReactiveModel<String>
    with InjectedTextEditing {
  InjectedTextEditingImp({
    String text = '',
    TextSelection selection = const TextSelection.collapsed(offset: -1),
    TextRange composing = TextRange.empty,
    String? Function(String?)? validator,
    this.autoValidate,
    this.autoDispose = true,
  })  : _validator = validator,
        initialValue = text,
        _composing = composing,
        _selection = selection,
        super(
          creator: () => text,
          autoDisposeWhenNotUsed: autoDispose,
        );

  final TextSelection _selection;
  final TextRange _composing;
  bool? autoValidate;
  bool _formIsSet = false;
  final bool autoDispose;
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
        }
      }
    }
    if (_controller != null) {
      return _controller!;
    }
    _controller ??= TextEditingControllerImp.fromValue(
      TextEditingValue(
        text: initialValue,
        selection: _selection,
        composing: _composing,
      ),
      disposeInjected: () {
        if (autoDispose && !hasObservers) {
          dispose();
          return true;
        }
        return false;
      },
    );

    _removeFromInjectedList = addToInjectedModels(this);

    _controller!.addListener(() {
      if (state == this.text) {
        notify();
        return;
      }
      if (form != null && autoValidate != true) {
        //If form is not null than override the autoValidate of this Injected
        autoValidate = form!.autovalidateMode != AutovalidateMode.disabled;
      }
      if (autoValidate ?? true) {
        validate();
      }
    });

    if (validator == null) {
      //If the field is not validate then set its snapshot to hasData, so that
      //in the [InjectedForm.isValid] consider it as a valid field
      snapState = snapState.copyToHasData(text);
    }
    return _controller!;
  }

  late VoidCallback _removeFromInjectedList;

  ///The associated [InjectedForm]
  InjectedForm? form;

  ///Remove this InjectedTextEditing from the associated InjectedForm,
  VoidCallback? formTextFieldDisposer;

  ///The initial value
  final String initialValue;
  @override
  String? Function(String? text)? _validator;

  @override
  void reset() {
    _controller?.text = initialValue;
  }

  @override
  void dispose() {
    super.dispose();
    _removeFromInjectedList();
    _controller!.dispose();
    _controller = null;
    _focusNode?.dispose();
    _focusNode = null;
    _formIsSet = false;
    form = null;
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
    required this.disposeInjected,
  }) : super.fromValue(value);
  int _numberOfAddListener = 0;
  bool _isDisposed = false;
  final bool Function() disposeInjected;
  @override
  void addListener(listener) {
    _numberOfAddListener++;
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    if (_isDisposed) {
      return;
    }
    _numberOfAddListener--;
    if (_numberOfAddListener < 3) {
      _isDisposed = disposeInjected();
      if (_isDisposed) return;
    }

    super.removeListener(listener);
  }
}
