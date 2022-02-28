import 'package:flutter/material.dart';

/// Extension on String
extension StringXX on String {
  /// Create a [Locale] object
  Locale locale({String? countryCode, String? scriptCode}) {
    return Locale.fromSubtags(
      languageCode: this,
      countryCode: countryCode,
      scriptCode: scriptCode,
    );
  }
}

/// Extension on int
extension IntXX on int {
  /// Create an [IntTween] form this value to the provided end value
  IntTween tweenTo(int end) {
    return IntTween(begin: this, end: end);
  }
}

/// Extension on double
extension DoubleXX on double {
  /// Create an [Tween<double>] form this value to the provided end value
  Tween<double> tweenTo(double end) {
    return Tween<double>(begin: this, end: end);
  }
}

/// Extension on Color
extension ColorX on Color {
  /// Create an [ColorTween] form this value to the provided end value
  ColorTween tweenTo(Color end) {
    return ColorTween(begin: this, end: end);
  }
}

/// Extension on Offset
extension OffsetX on Offset {
  /// Create an [Tween<Offset>] form this value to the provided end value
  Tween<Offset> tweenTo(Offset end) {
    return Tween<Offset>(begin: this, end: end);
  }
}

/// Extension on Size
extension SizeX on Size {
  /// Create an [Tween<Size>] form this value to the provided end value
  Tween<Size> tweenTo(Size end) {
    return Tween<Size>(begin: this, end: end);
  }
}

/// Extension on AlignmentGeometry
extension AlignmentGeometryX on AlignmentGeometry {
  /// Create an [AlignmentGeometryTween] form this value to the provided end value
  AlignmentGeometryTween tweenTo(AlignmentGeometry end) {
    return AlignmentGeometryTween(begin: this, end: end);
  }
}

/// Extension on EdgeInsetsGeometry
extension EdgeInsetsGeometryX on EdgeInsetsGeometry {
  /// Create an [EdgeInsetsGeometryTween] form this value to the provided end value
  EdgeInsetsGeometryTween tweenTo(EdgeInsetsGeometry end) {
    return EdgeInsetsGeometryTween(begin: this, end: end);
  }
}

/// Extension on Decoration
extension DecorationX on Decoration {
  /// Create an [DecorationTween] form this value to the provided end value
  DecorationTween tweenTo(Decoration end) {
    return DecorationTween(begin: this, end: end);
  }
}

/// Extension on BoxConstraints
extension BoxConstraintsX on BoxConstraints {
  /// Create an [BoxConstraintsTween] form this value to the provided end value
  BoxConstraintsTween tweenTo(BoxConstraints end) {
    return BoxConstraintsTween(begin: this, end: end);
  }
}

/// Extension on TextStyle
extension TextStyleX on TextStyle {
  /// Create an [TextStyleTween] form this value to the provided end value
  TextStyleTween tweenTo(TextStyle end) {
    return TextStyleTween(begin: this, end: end);
  }
}

/// Extension on Rect
extension RectX on Rect {
  /// Create an [RectTween] form this value to the provided end value
  RectTween tweenTo(Rect end) {
    return RectTween(begin: this, end: end);
  }
}

/// Extension on RelativeRect
extension RelativeRectX on RelativeRect {
  /// Create an [RelativeRectTween] form this value to the provided end value
  RelativeRectTween tweenTo(RelativeRect end) {
    return RelativeRectTween(begin: this, end: end);
  }
}

/// Extension on BorderRadius
extension BorderRadiusX on BorderRadius {
  /// Create an [BorderRadiusTween] form this value to the provided end value
  BorderRadiusTween tweenTo(BorderRadius end) {
    return BorderRadiusTween(begin: this, end: end);
  }
}

/// Extension on ThemeData
extension ThemeDataX on ThemeData {
  /// Create an [ThemeDataTween] form this value to the provided end value
  ThemeDataTween tweenTo(ThemeData end) {
    return ThemeDataTween(begin: this, end: end);
  }
}

/// Extension on Matrix4
extension Matrix4X on Matrix4 {
  /// Create an [Matrix4Tween] form this value to the provided end value
  Matrix4Tween tweenTo(Matrix4 end) {
    return Matrix4Tween(begin: this, end: end);
  }
}
