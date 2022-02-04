import 'dart:async';

import 'package:flutter/material.dart';
import '../../state_management/common/logger.dart';
import '../../state_management/rm.dart';
import '../../../states_rebuilder.dart';

part 'on_tab_builder.dart';

/// {@template InjectedTabPageView}
/// Inject a [TabController] and [PageController] and sync them to work
/// together to get the most benefit of them.
///
/// This injected state abstracts the best practices to come out with a
/// simple, clean, and testable approach to control tab and page views.
///
/// If you don't use [OnTabPageViewBuilder] to listen the state, it is highly
/// recommended to manually dispose the state using [Injected.dispose] method.
///
/// Example: of controlling [TabBarView], [PageView], and [TabBar] with the
/// same [InjectedTabPageView]
/// ```dart
///  final injectedTab = RM.injectTabPageView(
///    initialIndex: 2,
///    length: 5,
///  );
///
///  //In the widget tree;
///  @override
///  Widget build(BuildContext context) {
///    return MaterialApp(
///      home: Scaffold(
///        appBar: AppBar(
///          title: OnTabViewBuilder(
///            listenTo: injectedTab,
///            builder: (index) => Text('$index'),
///          ),
///        ),
///        body: Column(
///          children: [
///            Expanded(
///              child: OnTabViewBuilder(
///                builder: (index) {
///                  print(index);
///                  return TabBarView(
///                    controller: injectedTab.tabController,
///                    children: views,
///                  );
///                },
///              ),
///            ),
///            Expanded(
///              child: OnTabViewBuilder(
///                builder: (index) {
///                  return PageView(
///                    controller: injectedTab.pageController,
///                    children: pages,
///                  );
///                },
///              ),
///            )
///          ],
///        ),
///        bottomNavigationBar: OnTabPageViewBuilder(
///           listenTo: injectedTab,
///           builder: (index) => BottomNavigationBar(
///             currentIndex: index,
///             onTap: (int index) {
///               injectedTab.index = index;
///             },
///             selectedItemColor: Colors.blue,
///             unselectedItemColor: Colors.blue[100],
///             items: tabs
///                 .map(
///                   (e) => BottomNavigationBarItem(
///                     icon: e,
///                     label: '$index',
///                   ),
///                 )
///                 .toList(),
///           ),
///       ),
///    );
///  }
/// ```
///  {@endtemplate}
abstract class InjectedTabPageView implements IObservable<int> {
  ///Listen to the [InjectedTabPageView] and rebuild when tab index is changed.
  // late final rebuild = _RebuildTab(this);
  TabController? _tabController;
  PageController? _pageController;

  /// Get the associated [TabController]
  TabController get tabController {
    _OnTabPageViewBuilderState._addToTabObs?.call(this);
    assert(
        _tabController != null,
        'TabController is not initialized yet. '
        'You have to wrap the TabBarView or TabBar widget with the OnTabBuilder widget');
    return _tabController!;
  }

  /// Get the associated [PageController]
  PageController get pageController;
  int? get _page => _pageController?.page?.round();

  /// The index of the currently selected tab.
  ///
  /// When is set to a target index, the tab / page will animated from the
  /// current idex to the target index
  int get index {
    return snapState.state;
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
        duration: (this as InjectedPageTabImp).duration,
        curve: (this as InjectedPageTabImp).curve,
      );
    } else {
      assert(_pageController != null);
      _pageController!.animateToPage(
        i,
        duration: (this as InjectedPageTabImp).duration,
        curve: (this as InjectedPageTabImp).curve,
      );
    }
  }

  /// The number of tabs / pages. It can set dynamically
  ///
  /// Example:
  /// ```dart
  ///    // We start with 2 tabs
  ///    final myInjectedTabPageView = RM.injectedTabPageView(length: 2);
  ///
  ///   // Later on, we can extend or shrink the length of tab views.
  ///
  ///   // Tab/page views are updated to display three views
  ///   myInjectedTabPageView.length = 3
  ///
  ///   // Tab/page views are updated to display one view
  ///   myInjectedTabPageView.length = 1
  /// ```
  late int length;

  late bool _pageIndexIsChanging;

  /// The index of the previously selected tab.
  int get previousIndex => _tabController!.previousIndex;

  /// True while we're animating from [previousIndex] to [index] as a consequence of calling [animateTo].
  bool get indexIsChanging =>
      _tabController?.indexIsChanging == true || _pageIndexIsChanging;

  /// Immediately sets [index] and [previousIndex] and then plays the animation
  /// from its current value to [index].
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
          duration: (this as InjectedPageTabImp).duration,
          curve: (this as InjectedPageTabImp).curve,
        );
        if ((this as InjectedPageTabImp).duration == Duration.zero) {
          return;
        }
        late void Function(AnimationStatus) listener;
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
        duration: (this as InjectedPageTabImp).duration,
        curve: (this as InjectedPageTabImp).curve,
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
          duration: (this as InjectedPageTabImp).duration,
          curve: (this as InjectedPageTabImp).curve,
        );
        if ((this as InjectedPageTabImp).duration == Duration.zero) {
          return;
        }
        late void Function(AnimationStatus) listener;
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
        duration: (this as InjectedPageTabImp).duration,
        curve: (this as InjectedPageTabImp).curve,
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

class InjectedPageTabImp extends ReactiveModelImp<int>
    with InjectedTabPageView {
  InjectedPageTabImp({
    int initialIndex = 0,
    required int length,
    this.duration = kTabScrollDuration,
    this.curve = Curves.ease,
    this.viewportFraction = 1.0,
    this.keepPage = true,
  }) : super(
          creator: () => initialIndex,
          initialState: initialIndex,
          autoDisposeWhenNotUsed: true,
          stateInterceptorGlobal: null,
        ) {
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
    ReactiveStatelessWidget.addToObs?.call(this);
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
      initializer();
    }
    index = initialIndex;
    snapValue = const SnapState<int>.none().copyToHasData(initialIndex);
    notify();
  }

  void initializer([TickerProvider? ticker]) {
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
    snapValue = const SnapState<int>.none().copyToHasData(initialIndex);

    _tabController!.addListener(() {
      if (snapState.data == _tabController!.index) {
        return;
      }
      snapValue = SnapState<int>.none().copyToHasData(_tabController!.index);

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
    _OnTabPageViewBuilderState._addToTabObs?.call(this);

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
        snapValue = SnapState<int>.none().copyToHasData(_page!);
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
