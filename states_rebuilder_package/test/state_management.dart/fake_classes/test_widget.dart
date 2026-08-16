import 'package:material_ui/material_ui.dart';

Widget testWidget(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
