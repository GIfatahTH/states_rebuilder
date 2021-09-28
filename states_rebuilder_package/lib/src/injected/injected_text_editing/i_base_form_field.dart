part of 'injected_text_editing.dart';

abstract class _BaseFormField<T> {
  ///The associated [InjectedForm]
  late InjectedForm? form;
  late T? initialValue;
  late bool? _validateOnLoseFocus;
  late bool _isValidOnLoseFocusDefined;

  ///Input text validator
  late List<String? Function(T value)>? _validator;
  late FocusNode? _focusNode;
  late bool? _validateOnValueChange;
  //
  bool get isValid => hasData;
  T get value;
  bool get hasData;
  bool get hasError;
  bool get autoDispose;
  bool get hasObservers;

  late final _inj = this as InjectedBaseState<T>;

  set error(dynamic error) {
    assert(error is String?);
    if (error != null && error.isNotEmpty) {
      _inj.snapState = _inj.snapState.copyToHasError(error, data: value);
    } else {
      _inj.snapState = _inj.snapState.copyToHasData(value);
    }
    _inj.notify();
  }

  ///Creates a focus node for this TextField
  FocusNode get __focusNode {
    _focusNode!.addListener(() {
      _inj.notify();
      form?.notify();
    });
    //To cache the auto focused TextField
    WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
      SchedulerBinding.instance!.endOfFrame.then((_) {
        final form = this.form as InjectedFormImp?;
        if (form != null) {
          if (_focusNode?.hasFocus == true) {
            form.autoFocusedNode = _focusNode;
          }
        }
      });
    });

    if (_validateOnLoseFocus == true) {
      _listenToFocusNodeForValidation();
    }

    return _focusNode!;
  }

  late bool isReadOnly;
  late bool _isEnabled;

  ///Validate the input text by invoking its validator.
  bool validate() {
    _inj.snapState = _inj.snapState.copyToHasData(value);

    if (_validator != null) {
      for (var e in _validator!) {
        final error = e.call(value);
        if (error != null) {
          _inj.snapState = _inj.snapState.copyToHasError(error, data: value);
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

  void _listenToFocusNodeForValidation() {
    if (_focusNode == null) {
      return;
    }
    _isValidOnLoseFocusDefined = true;
    void fn() {
      if (!_focusNode!.hasFocus) {
        validate();
        //After the first lose of focus and if field is not valid,
        // turn _validateOnValueChange to true and remove listener
        _validateOnValueChange = true;
        // _focusNode!.removeListener(fn);// removed (issue 187)

      }
    }

    _focusNode!.addListener(fn);
  }
}
