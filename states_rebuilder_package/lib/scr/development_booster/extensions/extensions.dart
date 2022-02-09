import 'package:flutter/material.dart';

extension StringXX on String {
  Locale locale({String? countryCode, String? scriptCode}) {
    return Locale.fromSubtags(
      languageCode: this,
      countryCode: countryCode,
      scriptCode: scriptCode,
    );
  }
}

extension IntXX on int {
  IntTween tweenTo(int end) {
    return IntTween(begin: this, end: end);
  }
}

extension DoubleXX on double {
  Tween<double> tweenTo(double end) {
    return Tween<double>(begin: this, end: end);
  }
}

extension ColorX on Color {
  ColorTween tweenTo(Color end) {
    return ColorTween(begin: this, end: end);
  }
}

extension OffsetX on Offset {
  Tween<Offset> tweenTo(Offset end) {
    return Tween<Offset>(begin: this, end: end);
  }
}

extension SizeX on Size {
  Tween<Size> tweenTo(Size end) {
    return Tween<Size>(begin: this, end: end);
  }
}

extension AlignmentGeometryX on AlignmentGeometry {
  AlignmentGeometryTween tweenTo(AlignmentGeometry end) {
    return AlignmentGeometryTween(begin: this, end: end);
  }
}

extension EdgeInsetsGeometryX on EdgeInsetsGeometry {
  EdgeInsetsGeometryTween tweenTo(EdgeInsetsGeometry end) {
    return EdgeInsetsGeometryTween(begin: this, end: end);
  }
}

extension DecorationX on Decoration {
  DecorationTween tweenTo(Decoration end) {
    return DecorationTween(begin: this, end: end);
  }
}

extension BoxConstraintsX on BoxConstraints {
  BoxConstraintsTween tweenTo(BoxConstraints end) {
    return BoxConstraintsTween(begin: this, end: end);
  }
}

extension TextStyleX on TextStyle {
  TextStyleTween tweenTo(TextStyle end) {
    return TextStyleTween(begin: this, end: end);
  }
}

extension RectX on Rect {
  RectTween tweenTo(Rect end) {
    return RectTween(begin: this, end: end);
  }
}

extension RelativeRectX on RelativeRect {
  RelativeRectTween tweenTo(RelativeRect end) {
    return RelativeRectTween(begin: this, end: end);
  }
}

extension BorderRadiusX on BorderRadius {
  BorderRadiusTween tweenTo(BorderRadius end) {
    return BorderRadiusTween(begin: this, end: end);
  }
}

extension ThemeDataX on ThemeData {
  ThemeDataTween tweenTo(ThemeData end) {
    return ThemeDataTween(begin: this, end: end);
  }
}

extension Matrix4X on Matrix4 {
  Matrix4Tween tweenTo(Matrix4 end) {
    return Matrix4Tween(begin: this, end: end);
  }
}
