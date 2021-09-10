part of 'injected_text_editing.dart';

class OnFormFieldBuilder<T> extends StatelessWidget {
  OnFormFieldBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
    this.inputDecoration = const InputDecoration(),
    this.autofocus = false,
    this.enableBorder = false,
    this.style,
  }) : super(key: key);

  /// InjectedFormField to listen to.
  ///
  /// Example:
  ///```dart
  ///  final myCheckBox = RM.injectFormField<bool>(
  ///    false,
  ///    validators: [(value) => !value ? 'You must check me' : null],
  ///  );
  /// ```
  /// If the InjectedFormField state is nullable and it is set to null, the
  /// [InputDecoration.hintText] is displayed when the field isFocused and the
  /// [InputDecoration.labelText] is displayed when unfocuced.
  final InjectedFormField<T> listenTo;

  /// Builder to be called each time the [InjectedFormField] emits a notification.
  ///
  /// It exposes the current value the the onChanged callback.
  ///
  /// In most cases any input form widget have a `value` and `onChanged`
  /// properties. You must set these properties to the exposed value and
  /// onChanged.
  ///
  /// This is an example of a CheckBox.
  /// ```dart
  ///  final myCheckBox = RM.injectFormField<bool>(
  ///    false,
  ///    validators: [(value) => !value ? 'You must check me' : null],
  ///  );
  ///
  /// //In the widget tree inside OnFormBuilder widget.
  /// OnFormFieldBuilder<bool>(
  ///    listenTo: myCheckBox,
  ///    builder: (value, onChanged) {
  ///      return CheckboxListTile(
  ///        value: value,
  ///        onChanged: onChanged,
  ///        title: Text('I accept the licence'),
  ///      );
  ///    },
  ///  ),
  /// ```
  ///
  ///
  /// To deal with multi choice checkboxes (or FilterChips), you have to be more
  /// explicit on what to do in onChange callback.
  ///
  /// Example of multi choice checkboxds:
  ///
  /// ```dart
  ///  static const languages = ['Dart', 'Java', 'C++'];
  ///  final myLanguages = RM.injectFormField<List<String>>([]);
  ///
  /// //In the widget tree inside OnFormBuilder widget.
  /// OnFormFieldBuilder<List<String>>(
  ///    listenTo: myLanguages,
  ///    builder: (value, onChanged) {
  ///      return Row(
  ///        children: languages
  ///            .map(
  ///              (e) => Row(
  ///                children: [
  ///                  Checkbox(
  ///                    value: value.contains(e),
  ///                    onChanged: (val) {
  ///                      if (val == true) {
  ///                        myLanguages.value = [...value, e];
  ///                      } else {
  ///                        myLanguages.value =
  ///                            value.where((el) => el != e).toList();
  ///                      }
  ///                    },
  ///                  ),
  ///                  Text('$e'),
  ///                ],
  ///              ),
  ///            )
  ///            .toList(),
  ///      );
  ///    },
  ///  ),
  /// ```
  final Widget Function(T value, void Function(T?) onChanged) builder;

  /// The decoration to show around the form field.
  ///
  /// It is used to show an icon, label, hint, helper text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration? inputDecoration;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, defaults to the `subtitle1` text style from the current [Theme].
  final TextStyle? style;

  /// By default InputDecorator borders are set to none.
  ///
  /// If you want the default flutter InputBorder to show set [enableBorder]
  /// to true.
  final bool enableBorder;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;
  late final FocusNode _focusNode = listenTo.focusNode;

  InputDecoration _getEffectiveDecoration(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final InputDecoration effectiveDecoration =
        inputDecoration!.applyDefaults(themeData.inputDecorationTheme);
    return effectiveDecoration.copyWith(
      //TODO add enable to injectedFormField
      enabled: true,
      errorText: listenTo.error,
      border: enableBorder ? effectiveDecoration.border : InputBorder.none,
      errorBorder:
          enableBorder ? effectiveDecoration.errorBorder : InputBorder.none,
      enabledBorder:
          enableBorder ? effectiveDecoration.enabledBorder : InputBorder.none,
      focusedBorder:
          enableBorder ? effectiveDecoration.focusedBorder : InputBorder.none,
      disabledBorder:
          enableBorder ? effectiveDecoration.disabledBorder : InputBorder.none,
      focusedErrorBorder: enableBorder
          ? effectiveDecoration.focusedErrorBorder
          : InputBorder.none,
      contentPadding: effectiveDecoration.contentPadding ?? EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      canRequestFocus: false,
      child: OnBuilder(
        listenTo: listenTo,
        builder: () {
          Widget child = GestureDetector(
            onTapDown: (_) {
              FocusScope.of(context).unfocus();
              (listenTo as InjectedFormFieldImp)._hasFocus = true;
              // (_focusNode as FocusNode).requestFocus();
            },
            child: builder(
              listenTo._state,
              listenTo.onChanged,
            ),
          );
          if (inputDecoration != null) {
            child = InputDecorator(
              decoration: _getEffectiveDecoration(context),
              baseStyle: style,
              textAlign: TextAlign.start,
              // textAlignVertical: textAlignVertical,
              // isHovering: _isHovering,
              isFocused: () {
                final inj = listenTo as InjectedFormFieldImp;
                if (inj._hasFocus == true) {
                  inj._hasFocus = null;
                  return true;
                }
                return _focusNode.hasFocus;
              }(),
              isEmpty: listenTo.value == null,
              expands: false,
              child: child,
            );
          }
          return child;
        },
        sideEffects: SideEffects(
          initState: () {
            (listenTo as InjectedFormFieldImp).linkToForm();
            if (autofocus) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                _focusNode.requestFocus();
              });
            }
          },
        ),
      ),
    );
  }
}
