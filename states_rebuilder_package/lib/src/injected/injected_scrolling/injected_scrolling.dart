import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';
part 'on_scroll.dart';

///Injected a ScrollController
abstract class InjectedScrolling implements Injected<double> {
  ScrollController? _controller;

  ///The created [ScrollController]
  ScrollController get controller;

  ///The current offset
  double get offset => _controller!.offset;

  ///Whether the associates Scroll view is scrolling.
  bool isScrolling = false;

  ///Scrolling is happening in the positive scroll offset direction.
  bool get isScrollingForward =>
      _controller!.position.userScrollDirection == ScrollDirection.forward;

  ///Scrolling is happening in the negative scroll offset direction.
  bool get isScrollingReverse =>
      _controller!.position.userScrollDirection == ScrollDirection.reverse;
  //
  ///This scrolling list has just started scrolling.
  bool hasStartedScrolling = false;

  ///The scrolling list has just started scrolling in the forward direction.
  bool hasStartedScrollingForward = false;

  ///The scrolling list has just started scrolling in the reverse direction.
  bool hasStartedScrollingReverse = false;

  ///The scrolling list has just ended scrolling.
  bool hasEndedScrolling = false;
  //
  ///The scroll list has reached its top (the current offset is less or equal then
  ///minScrollExtent)
  bool hasReachedTheTop = false;

  ///The scroll list has reached its bottom (the current offset is greater or equal then
  ///maxScrollExtent)
  bool hasReachedTheBottom = false;

  ///Calls [ScrollPosition.jumpTo] if duration is null or [Duration.zero],
  ///otherwise [ScrollPosition.animateTo] is called.
  ///
  ///If [clamp] is true (the default) then [to] is adjusted to prevent over or
  ///underscroll.
  ///
  ///If [ScrollPosition.animateTo] is called then [curve] defaults to [Curves.ease].
  Future<void> moveTo(
    double to, {
    Duration? duration,
    Curve? curve,
    bool? clamp = true,
  }) {
    return _controller!.position.moveTo(
      to,
      duration: duration,
      curve: curve,
      clamp: clamp,
    );
  }

  @override
  String toString() {
    if (hasReachedTheBottom)
      return 'InjectedScrolling(hasReachedTheBottom: true)';
    if (hasReachedTheTop) return 'InjectedScrolling(hasReachedTheTop: true)';
    if (hasStartedScrollingForward)
      return 'InjectedScrolling(hasStartedScrolling: true )';
    if (hasStartedScrollingReverse)
      return 'InjectedScrolling(hasStartedScrollingReverse: true )';
    if (isScrollingForward)
      return 'InjectedScrolling(isScrollingForward: true )';
    if (isScrollingReverse)
      return 'InjectedScrolling(isScrollingReverse: true )';
    if (isScrolling) return 'InjectedScrolling(isScrolling: true )';
    return 'InjectedScrolling(isIdle: offset: $offset)';
  }
}

///Implementation of InjectedScrolling
class InjectedScrollingImp extends ReactiveModel<double>
    with InjectedScrolling {
  InjectedScrollingImp({
    this.initialScrollOffset = 0.0,
    this.keepScrollOffset = true,
    this.onScroll,
    this.onScrollEndedDelay = 300,
  }) : super(
          creator: () => 0.0,
          initialState: initialScrollOffset,
        ) {
    _removeFromInjectedList = addToInjectedModels(this);
  }

  ///Initial scroll offset
  final double initialScrollOffset;

  ///similar to [ScrollController.keepScrollOffset]
  final bool keepScrollOffset;
  final OnScroll? onScroll;
  final int onScrollEndedDelay;
  double? _maxScrollExtent;
  ScrollDirection? _userScrollDirection;
  ScrollPosition get position => _controller!.position;

  ScrollController get controller {
    if (_controller != null) {
      if (_maxScrollExtent != position.maxScrollExtent) {
        _maxScrollExtent = position.maxScrollExtent;
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          if (_controller == null) {
            return;
          }
          setState(
            (s) => _controller!.offset / _maxScrollExtent!,
          );
        });
      }
      return _controller!;
    }

    _controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
    );
    Timer? _timer;
    hasReachedTheTop = initialState == 0;
    void setFlags() {
      hasStartedScrolling = false;
      hasStartedScrollingForward = false;
      hasStartedScrollingReverse = false;
      hasEndedScrolling = false;
      if (_userScrollDirection != position.userScrollDirection) {
        _userScrollDirection = position.userScrollDirection;
        if (position.userScrollDirection == ScrollDirection.forward) {
          hasStartedScrollingForward = true;
        } else if (position.userScrollDirection == ScrollDirection.reverse) {
          hasStartedScrollingReverse = true;
        }
      }
      if (_controller!.offset >= position.maxScrollExtent &&
          !position.outOfRange) {
        hasReachedTheTop = false;
        hasReachedTheBottom = true;
      } else if (_controller!.offset <= position.minScrollExtent &&
          !position.outOfRange) {
        hasReachedTheTop = true;
        hasReachedTheBottom = false;
      } else {
        hasReachedTheTop = false;
        hasReachedTheBottom = false;
      }

      if (_timer == null) {
        if (position.userScrollDirection != ScrollDirection.idle) {
          hasStartedScrolling = true;
          isScrolling = true;
        }
        hasEndedScrolling = false;
      }
      _timer?.cancel();
      _timer = Timer(
        Duration(milliseconds: onScrollEndedDelay),
        () {
          if (isScrolling) {
            hasEndedScrolling = true;
          }

          hasStartedScrolling = false;
          isScrolling = false;
          _userScrollDirection = null;
          hasReachedTheBottom = false;
          hasReachedTheTop = false;
          onScroll?.call(this);
          _timer = null;
          notify();
        },
      );
    }

    _controller!.addListener(
      () {
        _maxScrollExtent = position.maxScrollExtent;
        setFlags();
        onScroll?.call(this);
        setState(
          (s) => _controller!.offset / _maxScrollExtent!,
        );
      },
    );

    return _controller!;
  }

  late VoidCallback _removeFromInjectedList;

  @override
  set state(double s) {
    assert(s >= 0 && s <= 1);
    moveTo(position.maxScrollExtent * s);
    // super.state = s;
  }

  @override
  void dispose() {
    super.dispose();
    _removeFromInjectedList();
    _controller?.dispose();
    _controller = null;
  }
}
