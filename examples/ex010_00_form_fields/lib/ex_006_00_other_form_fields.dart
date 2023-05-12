import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _Body(),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  _Body({Key? key}) : super(key: key);
  static final form = RM.injectForm(
    autovalidateMode: AutovalidateMode.onUserInteraction,
  );
  // static final text = RM.injectTextEditing();
  static final checkbox = RM.injectFormField<bool>(
    false,
    validators: [
      (val) => !val ? 'You must accept terms and conditions to continue' : null,
    ],
    // validateOnValueChange: true,
    validateOnLoseFocus: true,
  );
  static final dateTime = RM.injectFormField<DateTime?>(
    null,
    validators: [
      (date) {
        if (date == null || date.isAfter(DateTime.now())) {
          return 'Not allowed';
        }
        return null;
      }
    ],
    validateOnLoseFocus: true,
  );
  static final dateTimeRange = RM.injectFormField<DateTimeRange?>(null);
  static final slider = RM.injectFormField<double>(
    6.0,
    validators: [
      (value) {
        if (value < 6.0) {
          return 'Not allowed';
        }
        return null;
      }
    ],
  );

  static final rangeSlider = RM.injectFormField<RangeValues>(
    const RangeValues(10, 30),
    validators: [
      (value) {
        if (value.start < 6.0) {
          return 'Not allowed';
        }
        return null;
      }
    ],
  );

  static final textField = RM.injectTextEditing(text: '13', validators: [
    (val) {
      if (val == null || val.isEmpty) {
        return '* required';
      }
      final r = int.tryParse(val);
      if (r == null) {
        return 'Must be a number';
      }
      if (r < 16) {
        return 'It is for adult';
      }
      return null;
    }
  ]);

  final genderOptions = ['Male', 'Female', 'Other'];

  late final InjectedFormField<String?> dropdownMenu =
      RM.injectFormField<String?>(null);
  final radioOptions = ['Dart', 'Kotlin', 'Java', 'Swift', 'Objective-C'];
  final radioButtons = RM.injectFormField<String>('', validators: [
    (val) {
      if (val == 'Objective-C') {
        return 'Not that';
      }
      return null;
    }
  ]);

  static final switcher = RM.injectFormField(false);
  static final segmentedControl = RM.injectFormField<int>(0);
  static final multiCheckBoxes = RM.injectFormField<List<String>>(
    [],
    validators: [
      (val) {
        if (val.length < 3) {
          return 'choose more than three items';
        }
        return null;
      }
    ],
  );

  static final choiceChip = RM.injectFormField<List<String>>([]);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: OnFormBuilder(
          listenTo: form,
          builder: () {
            return Column(
              children: [
                OnFormFieldBuilder(
                  listenTo: dateTime,
                  inputDecoration: const InputDecoration(
                    isDense: true,
                    labelText: 'DatePicker label',
                    hintText: 'DatePicker hint',
                    // helperText: 'DatePicker helper text',
                  ),
                  builder: (value, onChanged) => ListTile(
                    dense: true,
                    title: Text('${value ?? ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => dateTime.value = null,
                    ),
                    onTap: () async {
                      final result = await showDatePicker(
                        context: context,
                        initialDate: dateTime.value ?? DateTime.now(),
                        firstDate: DateTime(2000, 1, 1),
                        lastDate: DateTime(2040, 1, 1),
                      );
                      if (result != null) {
                        dateTime.value = result;
                      }
                    },
                  ),
                ),
                const Divider(height: 16),
                OnFormFieldBuilder<DateTimeRange?>(
                  listenTo: dateTimeRange,
                  inputDecoration: const InputDecoration(
                    labelText: 'DateRangePicker label',
                    hintText: 'DateRangePicker hint',
                    // helperText: 'DateRangePicker helper text',
                  ),
                  builder: (value, onChanged) {
                    return ListTile(
                      dense: true,
                      title: Text('${value ?? ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          dateTimeRange.value = null;
                        },
                      ),
                      onTap: () async {
                        final result = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(2040, 1, 1),
                        );
                        if (result != null) {
                          dateTimeRange.value = result;
                        }
                      },
                    );
                  },
                ),
                const Divider(),
                OnReactive(
                  () => OnFormFieldBuilder<double>(
                    listenTo: slider,
                    autofocus: true,
                    inputDecoration: InputDecoration(
                      labelText: 'Slider label',
                      hintText: 'Slider hint',
                      helperText: 'Slider helper text: ${slider.value}',
                    ),
                    builder: (value, onChanged) {
                      return Slider(
                        value: value,
                        onChanged: slider.onChanged,
                        min: 0.0,
                        max: 10.0,
                        divisions: 20,
                        activeColor: Colors.red,
                        inactiveColor: Colors.pink[100],
                      );
                    },
                  ),
                ),
                const Divider(),
                OnFormFieldBuilder<RangeValues>(
                  listenTo: rangeSlider,
                  inputDecoration: const InputDecoration(
                    labelText: 'RangeSlider label',
                    hintText: 'RangeSlider hint',
                  ),
                  builder: (value, onChanged) {
                    return RangeSlider(
                      values: value,
                      onChanged: onChanged,
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      activeColor: Colors.red,
                      inactiveColor: Colors.pink[100],
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<bool>(
                  listenTo: checkbox,
                  inputDecoration: const InputDecoration(
                    labelText: 'CheckBox label',
                    hintText: 'CheckBox hint',
                    border: InputBorder.none,
                  ),
                  builder: (value, onChanged) {
                    return CheckboxListTile(
                      value: value,
                      onChanged: checkbox.onChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'I have read and agree to the ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                TextField(
                  controller: textField.controller,
                  focusNode: textField.focusNode,
                  decoration: InputDecoration(
                    errorText: textField.error,
                    labelText: 'TextField label',
                    hintText: 'TextField hint',
                    suffixIcon: textField.hasError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const Divider(),
                OnFormFieldBuilder<String?>(
                  listenTo: dropdownMenu,
                  inputDecoration: InputDecoration(
                    labelText: 'DropDownMenu label',
                    hintText: 'DropDownMenu hint',
                    suffixIcon: dropdownMenu.hasError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                  builder: (val, onChanged) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: val,
                        items: genderOptions
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: dropdownMenu.onChanged,
                      ),
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<String>(
                  listenTo: radioButtons,
                  inputDecoration: InputDecoration(
                    labelText: 'Radio buttons label',
                    hintText: 'Radio buttons hint',
                    suffixIcon: radioButtons.hasError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                  builder: (val, onChanged) {
                    return Row(
                      children: radioOptions
                          .map(
                            (e) => InkWell(
                              onTap: () => radioButtons.onChanged(e),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: e,
                                    groupValue: val,
                                    onChanged: radioButtons.onChanged,
                                  ),
                                  Text(e),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<int>(
                  listenTo: segmentedControl,
                  inputDecoration: const InputDecoration(
                    labelText: 'segmentedControl label',
                    hintText: 'segmentedControl hint',
                  ),
                  builder: (val, onChanged) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSegmentedControl<int>(
                        groupValue: val,
                        children: List.generate(5, (i) => i + 1).asMap().map(
                              (key, value) => MapEntry(key, Text('$value')),
                            ),
                        onValueChanged: segmentedControl.onChanged,
                      ),
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<bool>(
                  listenTo: switcher,
                  inputDecoration: InputDecoration(
                    labelText: 'switcher label',
                    hintText: 'switcher hint',
                    suffixIcon: dropdownMenu.hasError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                  builder: (val, onChanged) {
                    return SwitchListTile(
                      value: val,
                      onChanged: onChanged,
                      title: const Text('I Accept the tems and conditions'),
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<List<String>>(
                  listenTo: multiCheckBoxes,
                  inputDecoration: InputDecoration(
                    labelText: 'multiCheckBoxes label',
                    hintText: 'multiCheckBoxes hint',
                    suffixIcon: dropdownMenu.hasError
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                  builder: (val, onChanged) {
                    return Row(
                      children: radioOptions
                          .map(
                            (e) => Row(
                              children: [
                                Checkbox(
                                  value: val.contains(e),
                                  onChanged: (checked) {
                                    if (checked!) {
                                      multiCheckBoxes.value = [...val, e];
                                    } else {
                                      multiCheckBoxes.value =
                                          val.where((el) => e != el).toList();
                                    }
                                  },
                                ),
                                Text(e),
                                const SizedBox(width: 8),
                              ],
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const Divider(),
                OnFormFieldBuilder<List<String>>(
                  listenTo: choiceChip,
                  builder: (val, onChanged) {
                    return Wrap(
                      children: [...radioOptions].map(
                        (e) {
                          final selected = val.contains(e);
                          return FilterChip(
                            label: Text(e),
                            selected: selected,
                            onSelected: (selected) {
                              if (selected) {
                                choiceChip.value = [...val, e];
                              } else {
                                choiceChip.value = choiceChip.value
                                    .where((el) => e != el)
                                    .toList();
                              }
                            },
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      form.reset();
                    },
                    child: const Text('reset form')),
              ],
            );
          },
        ),
      ),
    );
  }
}
