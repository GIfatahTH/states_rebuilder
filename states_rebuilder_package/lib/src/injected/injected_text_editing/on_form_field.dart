part of 'injected_text_editing.dart';

class OnFormFieldBuilder<T> extends StatelessWidget {
  OnFormFieldBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
    this.inputDecoration,
    this.autofocus = false,
    this.enableBorder = false,
  }) : super(key: key);
  final InjectedFormField<T> listenTo;
  final Widget Function(T value) builder;
  final InputDecoration? inputDecoration;
  final bool enableBorder;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;
  late final _FocusNode _focusNode = listenTo.focusNode as _FocusNode;

  InputDecoration _getEffectiveDecoration(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final InputDecoration effectiveDecoration =
        (inputDecoration ?? const InputDecoration())
            .applyDefaults(themeData.inputDecorationTheme);
    return effectiveDecoration.copyWith(
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
          return InputDecorator(
            decoration: _getEffectiveDecoration(context),
            // baseStyle: style,
            textAlign: TextAlign.start,
            // textAlignVertical: textAlignVertical,
            // isHovering: _isHovering,
            isFocused: _focusNode.hasFocus,
            isEmpty: listenTo.value == null,
            expands: false,
            child: GestureDetector(
              onTapDown: (_) {
                FocusScope.of(context).unfocus();
                _focusNode.requestFocus();
              },
              child: builder(
                listenTo._state,
              ),
            ),
          );
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
