import 'package:flutter/material.dart';

Widget testWidget(Widget child) => Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
