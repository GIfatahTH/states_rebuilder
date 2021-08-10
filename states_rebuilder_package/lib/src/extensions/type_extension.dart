import 'package:flutter/material.dart';

import '../rm.dart';

extension IntX on int {
  ReactiveModel<int> inj() {
    return ReactiveModelImp(creator: () => this, initialState: 0);
  }

  IntTween tweenTo(int end) {
    return IntTween(begin: this, end: end);
  }

  Duration get milliseconds {
    return Duration(milliseconds: this);
  }

  Duration get seconds {
    return Duration(seconds: this);
  }

  Duration get minutes {
    return Duration(minutes: this);
  }

  Duration get hours {
    return Duration(hours: this);
  }
}

extension DoubleX on double {
  ReactiveModel<double> inj() {
    return ReactiveModelImp(creator: () => this, initialState: 0.0);
  }

  Tween<double> tweenTo(double end) {
    return Tween<double>(begin: this, end: end);
  }
}

extension StringX on String {
  ReactiveModel<String> inj() {
    return ReactiveModelImp(creator: () => this, initialState: '');
  }
}

extension BoolX on bool {
  ReactiveModel<bool> inj() {
    return ReactiveModelImp(creator: () => this, initialState: false);
  }
}

extension ListX<T> on List<T> {
  ReactiveModel<List<T>> inj() {
    return ReactiveModelImp(creator: () => this, initialState: <T>[]);
  }
}

extension SetX<T> on Set<T> {
  ReactiveModel<Set<T>> inj() {
    return ReactiveModelImp(creator: () => this, initialState: <T>{});
  }
}

extension MapX<T, D> on Map<T, D> {
  ReactiveModel<Map<T, D>> inj() {
    return ReactiveModelImp(creator: () => this, initialState: <T, D>{});
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
