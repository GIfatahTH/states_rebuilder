import 'package:flutter/widgets.dart';

import '../../rm.dart';

abstract class InjectedTextEditing implements Injected<String> {
  late final TextEditingController controller;
  String get text => controller.value.text;
  TextSelection get selection => controller.value.selection;
  TextRange get composing => controller.value.composing;
}

class InjectedTextEditingImp extends ReactiveModel<String>
    with InjectedTextEditing {
  InjectedTextEditingImp({
    String text = '',
    TextSelection selection = const TextSelection.collapsed(offset: -1),
    TextRange composing = TextRange.empty,
    this.validator,
  }) : super(creator: () => text) {
    controller = TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: selection,
        composing: composing,
      ),
    );

    controller.addListener(() {
      if (state == this.text) {
        notify();
        return;
      }
      setState((s) {
        final errorMessage = validator?.call(this.text);
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw errorMessage;
        }
        return this.text;
      });
    });
  }

  String? Function(String text)? validator;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
