import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:states_rebuilder/src/builders/on_reactive.dart';

import '../../rm.dart';

part 'on_tab.dart';

class _RebuildTab {
  final InjectedPageTab _injected;
  _RebuildTab(this._injected);

  ///Listen to the [InjectedPageTab] and rebuild when tab index is changed.
  Widget onTab(
    Widget Function(int index) builder, {
    Key? key,
  }) {
    return OnTabBuilder(
      listenTo: _injected,
      builder: builder,
    );
  }
}

abstract class InjectedPageTab implements InjectedBaseState<int> {
  ///Listen to the [InjectedPageTab] and rebuild when tab index is changed.
  late final rebuild = _RebuildTab(this);
  TabController? _tabController;
  PageController? _pageController;

  TabController get tabController {
    assert(
        _tabController != null,
        'TabController is not initialized yet. '
        'You have to wrap the TabBarView or TabBar widget with the OnTabBuilder widget');
    return _tabController!;
  }

  PageController get pageController;
  int? get _page => _pageController?.page?.round();

  ///The index of the currently selected tab.
  int get index {
    return state;
    // if (_tabController != null) {
    //   return _tabController!.index;
    // }
    // assert(_pageController != null);
    // if (_pageController!.positions.isNotEmpty) {
    //   return _page!;
    // }
    // return (this as InjectedTabImp).initialIndex;
  }

  set index(int i) {
    if (i == snapState.data) {
      return;
    }
    if (_tabController != null) {
      _tabController!.animateTo(
        i,
        duration: (this as InjectedTabImp).duration,
        curve: (this as InjectedTabImp).curve,
      );
    } else {
      assert(_pageController != null);
      _pageController!.animateToPage(
        i,
        duration: (this as InjectedTabImp).duration,
        curve: (this as InjectedTabImp).curve,
      );
    }
  }

  late int length;

  late bool _pageIndexIsChanging;

  ///The index of the previously selected tab.
  int get previousIndex => _tabController!.previousIndex;

  ///True while we're animating from [previousIndex] to [index] as a consequence of calling [animateTo].
  bool get indexIsChanging =>
      _tabController?.indexIsChanging == true || _pageIndexIsChanging;

  ///Immediately sets [index] and [previousIndex] and then plays the animation from its current value to [index].
  void animateTo(
    int value, {
    Duration duration = kTabScrollDuration,
    Curve curve = Curves.ease,
  }) {
    if (_tabController != null) {
      _tabController!.animateTo(
        value,
        duration: duration,
        curve: curve,
      );
    } else {
      assert(_pageController != null);
      if (duration == Duration.zero) {
        _pageController?.jumpToPage(value);
      } else {
        _pageController?.animateToPage(
          value,
          duration: duration,
          curve: curve,
        );
      }
    }
  }

  /// Animates the controlled pages/tabs to the next page/tab.
  ///
  /// The animation lasts for the default duration and follows the default curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  Future<void> nextView() async {
    if (_tabController != null) {
      if (index + 1 < _tabController!.length) {
        final future = Completer();
        _tabController!.animateTo(
          index + 1,
          duration: (this as InjectedTabImp).duration,
          curve: (this as InjectedTabImp).curve,
        );
        if ((this as InjectedTabImp).duration == Duration.zero) {
          return;
        }
        var listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            future.complete();
            _tabController!.animation?.removeStatusListener(listener);
          }
        };
        _tabController!.animation?.addStatusListener(listener);
        return future.future;
      }
    } else {
      assert(_pageController != null);
      return _pageController!.nextPage(
        duration: (this as InjectedTabImp).duration,
        curve: (this as InjectedTabImp).curve,
      );
    }
  }

  /// Animates the controlled pages/tabs to the previous page/tab.
  ///
  /// The animation lasts for the default duration and follows the default curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  Future<void> previousView() async {
    if (_tabController != null) {
      if (index - 1 >= 0) {
        final future = Completer();
        _tabController!.animateTo(
          index - 1,
          duration: (this as InjectedTabImp).duration,
          curve: (this as InjectedTabImp).curve,
        );
        if ((this as InjectedTabImp).duration == Duration.zero) {
          return;
        }
        var listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            future.complete();
            _tabController!.animation?.removeStatusListener(listener);
          }
        };
        _tabController!.animation?.addStatusListener(listener);
        return future.future;
      }
    } else {
      assert(_pageController != null);
      return _pageController!.previousPage(
        duration: (this as InjectedTabImp).duration,
        curve: (this as InjectedTabImp).curve,
      );
    }
  }

  // Future<void> toLastPage() async {
  //   animateTo(length - 1);
  // }

  // Future<void> toFirstPage() async {
  //   animateTo(0);
  // }
}

class InjectedTabImp extends InjectedBaseBaseImp<int> with InjectedPageTab {
  InjectedTabImp({
    int initialIndex = 0,
    required int length,
    this.duration: kTabScrollDuration,
    this.curve: Curves.ease,
    this.viewportFraction = 1.0,
    this.keepPage = true,
  }) : super(creator: () => initialIndex) {
    _resetDefaultState = () {
      _tabController = null;
      _pageController = null;
      _pageIndexIsChanging = false;

      this.initialIndex = initialIndex;
      _length = length;
      _ticker = null;
    };
    _resetDefaultState();
  }

  ///The duration the page/tab transition takes.
  final Duration duration;

  ///The curve the page/tab animation transition takes.
  final Curve curve;

  ///ONLY for PageView
  ///
  ///The fraction of the viewport that each page should occupy.
  ///Defaults to 1.0, which means each page fills the viewport in the
  ///scrolling direction.
  ///
  ///See [PageController.viewportFraction]
  final double viewportFraction;

  ///ONLY for PageView
  ///
  ///Save the current [page] with [PageStorage] and restore it if this
  ///controller's scrollable is recreated.
  ///
  ///See [PageController.keepPage]
  final bool keepPage;

  ///The initial index the app start with.
  late int initialIndex;
  late int _length;

  late TickerProvider? _ticker;
  late final VoidCallback _resetDefaultState;

  ///The total number of tabs.
  ///
  ///Typically greater than one. Must match [TabBar.tabs]'s and
  ///[TabBarView.children]'s length.
  @override
  int get length {
    OnReactiveState.addToObs?.call(this);
    return _length;
  }

  @override
  set length(int l) {
    assert(l > 0);
    if (_length == l) {
      return;
    }
    _length = l;
    initialIndex = _page ?? index;
    if (initialIndex > l - 1) {
      initialIndex = l - 1;
    }
    if (_tabController != null) {
      _tabController!.index = initialIndex;
      _tabController!.dispose();
      _tabController = null;
      initialize();
    }
    index = initialIndex;
    snapState = SnapState.data(initialIndex);
    notify();
  }

  void initialize([TickerProvider? ticker]) {
    _ticker ??= ticker;
    if (_tabController != null) {
      return;
    }
    assert(length > 0, 'The length must be defined and greater than one');
    _tabController = TabController(
      vsync: _ticker!,
      length: length,
      initialIndex: initialIndex,
    );
    snapState = SnapState.data(initialIndex);

    _tabController!.addListener(() {
      if (snapState.data == _tabController!.index) {
        return;
      }
      snapState = SnapState.data(_tabController!.index);
      if (!_pageIndexIsChanging) {
        if (duration == Duration.zero) {
          _pageController?.jumpToPage(
            _tabController!.index,
          );
        } else {
          _pageController?.animateToPage(
            _tabController!.index,
            duration: duration,
            curve: curve,
          );
        }
      }
      notify();
    });
  }

  @override
  PageController get pageController {
    if (_pageController != null) {
      return _pageController!;
    }

    _pageController = PageController(
      initialPage: initialIndex,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );

    _pageController!.addListener(() {
      if (snapState.data == _page!) {
        return;
      }
      if (_tabController?.indexIsChanging == true) {
        return;
      }
      if (_tabController != null) {
        _pageIndexIsChanging = true;
        if (_page! >= _tabController!.length) {
          return;
        }
        _tabController?.animateTo(
          _page!,
          duration: duration,
          curve: curve,
        );
        _pageIndexIsChanging = false;
      } else {
        snapState = SnapState.data(_page!);
        notify();
      }
    });

    return _pageController!;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    _resetDefaultState();
    super.dispose();
  }
}
