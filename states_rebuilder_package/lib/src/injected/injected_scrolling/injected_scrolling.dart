import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../rm.dart';
part 'on_scroll.dart';

abstract class InjectedScrolling implements Injected<double> {
  late final ScrollController controller;
  double get offset => controller.offset;
  bool isScrolling = false;
  bool isScrollingToTheTop = false;
  bool isScrollStarted = false;
  bool isScrollEnded = false;

  Future<void> moveTo(
    double to, {
    Duration? duration,
    Curve? curve,
    bool? clamp = true,
  }) {
    return controller.position.moveTo(
      to,
      duration: duration,
      curve: curve,
      clamp: clamp,
    );
  }
}

class InjectedScrollingImp extends ReactiveModel<double>
    with InjectedScrolling {
  InjectedScrollingImp({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    OnScroll? onScroll,
    int onScrollEndedDelay = 300,
  }) : super(
          creator: () => 0.0,
          initialState: initialScrollOffset,
        ) {
    controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
    );
    Timer? _timer;
    void setFlags() {
      isScrollingToTheTop = controller.offset > state;
      isScrollStarted = false;
      isScrollEnded = false;

      if (controller.offset >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        _isOnTop = false;
        _isOnBottom = true;
      } else if (controller.offset <= controller.position.minScrollExtent &&
          !controller.position.outOfRange) {
        _isOnTop = true;
        _isOnBottom = false;
      } else {
        _isOnTop = false;
        _isOnBottom = false;
      }

      if (_timer == null) {
        isScrollStarted = true;
        isScrollEnded = false;
        isScrolling = true;
      }
      _timer?.cancel();
      _timer = Timer(
        Duration(milliseconds: onScrollEndedDelay),
        () {
          isScrollStarted = false;
          isScrollEnded = true;
          isScrolling = false;
          onScroll?.call(this);
          _timer = null;
          notify();
        },
      );
    }

    _isOnTop = initialState == 0;

    controller.addListener(() {
      assert(controller.positions.length == 1);
      if (state == offset) {
        return;
      }
      setFlags();
      onScroll?.call(this);
      setState((s) => controller.offset / controller.position.maxScrollExtent);
    });
  }
  @override
  set state(double s) {
    assert(s >= 0 && s <= 1);
    moveTo(controller.position.maxScrollExtent * s);
    // super.state = s;
  }

  bool _isOnTop = false;
  bool _isOnBottom = false;
}
