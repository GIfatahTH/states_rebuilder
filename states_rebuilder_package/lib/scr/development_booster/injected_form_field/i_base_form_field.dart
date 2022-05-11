part of 'injected_text_editing.dart';

abstract class _BaseFormField<T> {
  ///The associated [InjectedForm]
  late InjectedForm? form;
  late T? initialValue;
  late bool? _validateOnLoseFocus;
  late bool _isValidOnLoseFocusDefined;
  late bool isDirty;
  late T _initialIsDirtyText;

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

  late final _inj = this as ReactiveModelImp<T>;

  set error(dynamic error) {
    assert(error is String?);
    if (error != null && error.isNotEmpty) {
      _inj.snapValue = _inj.snapValue.copyWith(
        status: StateStatus.hasError,
        error: SnapError(error: error, refresher: () {}),
        data: value,
      );
    } else {
      _inj.snapValue = _inj.snapValue.copyToHasData(value);
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
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      SchedulerBinding.instance.endOfFrame.then((_) {
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

  late bool? _isReadOnly;
  late bool? _isEnabled;

  ///Validate the input text by invoking its validator.
  bool validate([bool isFromSubmission = false]) {
    if (!isFromSubmission &&
        _inj.hasError &&
        _inj.oldSnapState?.data == _inj.snapValue.data) {
      return false;
    }
    _inj.snapValue = _inj.snapValue.copyToHasData(value);

    if (_validator != null) {
      for (var e in _validator!) {
        final error = e.call(value);
        if (error != null) {
          _inj.snapValue = _inj.snapValue.copyWith(
            status: StateStatus.hasError,
            error: SnapError(error: error, refresher: () {}),
            data: value,
          );
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
    _inj.snapValue = _inj.snapState.copyToHasData(initialValue);
    if (_validator != null) {
      //IF there is a validator, then set with idle flag so that isValid
      //is false unless validator is called
      _inj.snapValue = _inj.snapState.copyToIsIdle(data: initialValue);
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
