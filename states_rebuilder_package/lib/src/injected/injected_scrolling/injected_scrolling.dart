import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../rm.dart';
part 'on_scroll.dart';

class _RebuildScrolling {
  final InjectedScrolling _injected;
  _RebuildScrolling(this._injected);

  ///Listen to the [InjectedScrolling] and rebuild when scrolling data is changed.
  Widget onScroll(
    Widget Function(InjectedScrolling) builder, {
    Key? key,
  }) {
    return On.scroll(builder).listenTo(
      _injected,
      key: key,
    );
  }
}

///Injected a ScrollController
abstract class InjectedScrolling implements InjectedBaseState<double> {
  ///Listen to the [InjectedScrolling] and rebuild when scrolling data is changed.
  late final rebuild = _RebuildScrolling(this);

  late ScrollController? _controller;

  ///The created [ScrollController]
  ScrollController get controller;

  ///The current offset
  double get offset => _controller!.offset;

  ///The maximum in-range value for [pixels].
  ///
  /// Similar to [ScrollPosition.maxScrollExtent]
  double get maxScrollExtent => _controller!.position.maxScrollExtent;

  ///The minimum in-range value for [pixels].
  ///
  /// Similar to [ScrollPosition.minScrollExtent]
  double get minScrollExtent => _controller!.position.minScrollExtent;

  ///Whether the associates Scroll view is scrolling.
  late bool isScrolling;

  ///Scrolling is happening in the positive scroll offset direction.
  bool get isScrollingForward =>
      _controller!.position.userScrollDirection == ScrollDirection.forward;

  ///Scrolling is happening in the negative scroll offset direction.
  bool get isScrollingReverse =>
      _controller!.position.userScrollDirection == ScrollDirection.reverse;

  set state(double s);

  ///This scrolling list has just started scrolling.
  late bool hasStartedScrolling;

  ///The scrolling list has just started scrolling in the forward direction.
  late bool hasStartedScrollingForward;

  ///The scrolling list has just started scrolling in the reverse direction.
  late bool hasStartedScrollingReverse;

  ///The scrolling list has just ended scrolling.
  late bool hasEndedScrolling;
  //
  ///The scroll list has reached its top (the current offset is less or equal then
  ///minScrollExtent)
  late bool hasReachedMinExtent;

  ///The scroll list has reached its bottom (the current offset is greater or equal then
  ///maxScrollExtent)
  late bool hasReachedMaxExtent;

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
    if (_controller?.hasClients == false) {
      return 'InjectedScrolling(HasNoClient)';
    }
    if (hasReachedMaxExtent)
      return 'InjectedScrolling(hasReachedTheBottom: true)';
    if (hasReachedMinExtent) return 'InjectedScrolling(hasReachedTheTop: true)';
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
class InjectedScrollingImp extends InjectedBaseBaseImp<double>
    with InjectedScrolling {
  InjectedScrollingImp({
    this.initialScrollOffset = 0.0,
    this.keepScrollOffset = true,
    this.onScroll,
    this.onScrollEndedDelay = 300,
  }) : super(
          creator: () => initialScrollOffset,
        ) {
    _resetDefaultState = () {
      _controller = null;
      _maxScrollExtent = null;
      _userScrollDirection = null;
      _removeFromInjectedList = null;
      hasStartedScrolling = false;
      hasStartedScrollingForward = false;
      hasStartedScrollingReverse = false;
      hasEndedScrolling = false;
      hasReachedMinExtent = false;
      hasReachedMaxExtent = false;
      isScrolling = false;
    };
    _resetDefaultState();
  }

  ///Initial scroll offset
  final double initialScrollOffset;

  ///similar to [ScrollController.keepScrollOffset]
  final bool keepScrollOffset;
  final OnScroll? onScroll;
  final int onScrollEndedDelay;
  late double? _maxScrollExtent;
  late VoidCallback? _removeFromInjectedList;
  late ScrollDirection? _userScrollDirection;
  late final VoidCallback _resetDefaultState;
  //
  ScrollPosition get position => _controller!.position;
  ScrollController get controller {
    if (_controller != null) {
      return _controller!;
    }
    _controller = ScrollController(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
    );
    _removeFromInjectedList = addToInjectedModels(this);
    Timer? _timer;
    hasReachedMinExtent = initialScrollOffset == 0.0;
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
        hasReachedMinExtent = false;
        hasReachedMaxExtent = true;
        SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
          if (_maxScrollExtent != position.maxScrollExtent) {
            _maxScrollExtent = position.maxScrollExtent;
            if (_controller == null) {
              return;
            }
            _setState();
          }
        });
      } else if (_controller!.offset <= position.minScrollExtent &&
          !position.outOfRange) {
        hasReachedMinExtent = true;
        hasReachedMaxExtent = false;
      } else {
        hasReachedMinExtent = false;
        hasReachedMaxExtent = false;
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
          hasReachedMaxExtent = false;
          hasReachedMinExtent = false;
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
        _setState();
      },
    );

    return _controller!;
  }

  @override
  set state(double s) {
    assert(s >= 0 && s <= 1);
    moveTo(position.maxScrollExtent * s);
    // super.state = s;
  }

  void _setState() {
    final data = _controller!.offset / _maxScrollExtent!;
    snapState = snapState.copyToHasData(data);
    notify();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _removeFromInjectedList?.call();
    _resetDefaultState();
    super.dispose();
  }
}
