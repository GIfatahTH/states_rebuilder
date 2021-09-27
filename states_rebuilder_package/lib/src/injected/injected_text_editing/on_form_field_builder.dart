part of 'injected_text_editing.dart';

/// Listen to an [InjectedFormField] and define its corresponding input fields
///
/// {@template InjectedFormField.examples}
/// ## Examples
/// ### Checkbox
///   ```dart
///     final myCheckBox = RM.injectFormField<bool>(false);
///
///     //In the widget tree
///     OnFormFieldBuilder<bool>(
///      listenTo: myCheckBox,
///      builder: (value, onChanged) {
///        return CheckboxListTile(
///          value: value,
///          onChanged: onChanged,
///          title: Text('I accept the licence'),
///        );
///      },
///     ),
///   ```
///
/// ### Switch
///   ```dart
///       final switcher = RM.injectFormField(false);
///
///       OnFormFieldBuilder<bool>(
///         listenTo: switcher,
///         inputDecoration: InputDecoration(
///           labelText: 'switcher label',
///           hintText: 'switcher hint',
///           helperText: 'switcher helper text',
///           suffixIcon: dropdownMenu.hasError
///               ? const Icon(Icons.error, color: Colors.red)
///               : const Icon(Icons.check, color: Colors.green),
///         ),
///         builder: (val, onChanged) {
///           return SwitchListTile(
///             value: val,
///             onChanged: onChanged,
///             title: Text('I Accept the terms and conditions'),
///           );
///         },
///       ),
///     ),
///   ```
///
/// ### Date picker
///   ```dart
///     final dateTime = RM.injectFormField<DateTime?>(
///       null,
///       validators: [
///         (date) {
///           if (date == null || date.isAfter(DateTime.now())) {
///             return 'Not allowed';
///           }
///         }
///       ],
///       validateOnLoseFocus: true,
///     );
///
///
///     OnFormFieldBuilder(
///       listenTo: dateTime,
///       inputDecoration: InputDecoration(
///         labelText: 'DatePicker label',
///         hintText: 'DatePicker hint',
///         helperText: 'DatePicker helper text',
///       ),
///       builder: (value, onChanged) => ListTile(
///         dense: true,
///         title: Text('${value ?? ''}'),
///         //clear the state
///         trailing: IconButton(
///           icon: Icon(Icons.clear),
///           onPressed: () => dateTime.value = null,
///         ),
///         onTap: () async {
///           final result = await showDatePicker(
///             context: context,
///             initialDate: dateTime.value ?? DateTime.now(),
///             firstDate: DateTime(2000, 1, 1),
///             lastDate: DateTime(2040, 1, 1),
///           );
///           if (result != null) {
///             dateTime.value = result;
///           }
///         },
///       ),
///     ),
///   ```
///
/// ### Date range picker
///   ```dart
///   final dateTimeRange = RM.injectFormField<DateTimeRange?>(null);
///
///   OnFormFieldBuilder<DateTimeRange?>(
///     listenTo: dateTimeRange,
///     inputDecoration: InputDecoration(
///       labelText: 'DateRangePicker label',
///       hintText: 'DateRangePicker hint',
///       helperText: 'DateRangePicker helper text',
///     ),
///     builder: (value, onChanged) {
///       return ListTile(
///         dense: true,
///         title: Text('${value ?? ''}'),
///         trailing: IconButton(
///           icon: Icon(Icons.close),
///           onPressed: () {
///             dateTimeRange.value = null;
///           },
///         ),
///         onTap: () async {
///           final result = await showDateRangePicker(
///             context: context,
///             firstDate: DateTime(2000, 1, 1),
///             lastDate: DateTime(2040, 1, 1),
///           );
///           if (result != null) {
///             dateTimeRange.value = result;
///           }
///         },
///       );
///     },
///   ),
///   ```
///
/// ### Slider
///   ```dart
///   final slider = RM.injectFormField<double>(
///       6.0,
///       validators: [
///         (value) {
///           if (value < 6.0) {
///             return 'Not allowed';
///           }
///         }
///       ],
///     );
///
///   OnFormFieldBuilder<double>(
///     listenTo: slider,
///     autofocus: true,
///     inputDecoration: InputDecoration(
///       labelText: 'Slider label',
///       hintText: 'Slider hint',
///       helperText: 'Slider helper text: ${slider.value}',
///     ),
///     builder: (value, onChanged) {
///       return Slider(
///         value: value,
///         onChanged: onChanged,
///         min: 0.0,
///         max: 10.0,
///       );
///     },
///   ),
///   ```
///
/// ### RangeSlider
///   ```dart
///     OnFormFieldBuilder<RangeValues>(
///       listenTo: rangeSlider,
///       inputDecoration: InputDecoration(
///         labelText: 'Slider label',
///         hintText: 'Slider hint',
///         helperText: 'Slider helper text',
///       ),
///       builder: (value, onChanged) {
///         return RangeSlider(
///           values: value,
///           onChanged: onChanged,
///           min: 0.0,
///           max: 100.0,
///           divisions: 20,
///         );
///       },
///     ),
///   ```
/// ### DropdownButton
///   ```dart
///     const genders = ['Male', 'Female', 'Other'];
///     final dropdownMenu = RM.injectFormField<String?>(null);
///     OnFormFieldBuilder<String?>(
///       listenTo: dropdownMenu,
///       inputDecoration: InputDecoration(
///         labelText: 'DropDownMenu label',
///         hintText: 'DropDownMenu hint',
///         helperText: 'DropDownMenu helper text',
///         suffixIcon: dropdownMenu.hasError
///             ? const Icon(Icons.error, color: Colors.red)
///             : const Icon(Icons.check, color: Colors.green),
///       ),
///       builder: (val, onChanged) {
///         return DropdownButtonHideUnderline(
///           child: DropdownButton<String>(
///             value: val,
///             items: genders
///                 .map(
///                   (gender) => DropdownMenuItem(
///                     value: gender,
///                     child: Text(gender),
///                   ),
///                 )
///                 .toList(),
///             onChanged: onChanged,
///           ),
///         );
///       },
///     ),
///   ```
///
/// ### Radio Options
///   ```dart
///     final radioOptions = ['Dart', 'Kotlin', 'Java', 'Swift', 'Objective-C'];
///     final radioButtons = RM.injectFormField<String>('');
///     OnFormFieldBuilder<String>(
///       listenTo: radioButtons,
///       inputDecoration: InputDecoration(
///         labelText: 'Radio buttons label',
///         hintText: 'Radio buttons hint',
///         helperText: 'Radio buttons helper text',
///         suffixIcon: radioButtons.hasError
///             ? const Icon(Icons.error, color: Colors.red)
///             : const Icon(Icons.check, color: Colors.green),
///       ),
///       builder: (val, onChanged) {
///         return Row(
///           children: radioOptions
///               .map(
///                 (e) => InkWell(
///                   onTap: () => radioButtons.onChanged(e),
///                   child: Row(
///                     children: [
///                       Radio<String>(
///                         value: e,
///                         groupValue: val,
///                         onChanged: onChanged,
///                       ),
///                       Text(e),
///                       const SizedBox(width: 8),
///                     ],
///                   ),
///                 ),
///               )
///               .toList(),
///         );
///       },
///     ),
///   ```
///
/// ### Multi Check Boxes
///   ```dart
///       final multiCheckBoxes = RM.injectFormField<List<String>>(
///         [],
///         validators: [
///           (val) {
///             if (val.length < 3) {
///               return 'choose more than three items';
///             }
///           }
///         ],
///       );
///
///
///     OnFormFieldBuilder<List<String>>(
///       listenTo: multiCheckBoxes,
///       inputDecoration: InputDecoration(
///         labelText: 'multiCheckBoxes label',
///         hintText: 'multiCheckBoxes hint',
///         helperText: 'multiCheckBoxes helper text',
///       ),
///       builder: (val, onChanged) {
///         return Row(
///           children: radioOptions
///               .map(
///                 (e) => Row(
///                     children: [
///                       Checkbox(
///                         value: val.contains(e),
///                         onChanged: (checked) {
///                           if (checked!) {
///                             multiCheckBoxes.value = [...val, e];
///                           } else {
///                             multiCheckBoxes.value =
///                                 val.where((el) => e != el).toList();
///                           }
///                         },
///                       ),
///                       Text(e),
///                       const SizedBox(width: 8),
///                     ],
///                   ),
///               )
///               .toList(),
///         );
///       },
///     ),
///   ```
///  {@endtemplate}
class OnFormFieldBuilder<T> extends StatelessWidget {
  /// Listen to an [InjectedFormField] and define its corresponding input fields
  /// {@macro InjectedFormField.examples}
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
      enabled: listenTo.isEnabled,
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
                if (!listenTo.isEnabled) {
                  return false;
                }
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
          return IgnorePointer(
            ignoring: !listenTo.isEnabled,
            child: child,
          );
        },
        sideEffects: SideEffects(
          initState: () {
            (listenTo as InjectedFormFieldImp).linkToForm();
            if (autofocus) {
              WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
                  _focusNode.requestFocus();
              });
            }
          },
        ),
      ),
    );
  }
}
