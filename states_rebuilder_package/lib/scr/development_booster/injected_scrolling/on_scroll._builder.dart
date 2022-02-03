part of 'injected_scrolling.dart';

extension InjectedScrollingX on InjectedScrolling {
  _Rebuild get rebuild => _Rebuild(this);
}

class _Rebuild {
  final InjectedScrolling inj;
  _Rebuild(this.inj);
  OnScrollBuilder onScroll(
    Widget Function(InjectedScrolling) builder, {
    Key? key,
  }) {
    return OnScrollBuilder(
      key: key,
      listenTo: inj,
      builder: builder,
    );
  }

  call(Widget Function() builder) {
    return OnBuilder(
      listenTo: inj,
      builder: builder,
    );
  }
}

// class _RebuildScrolling {
//   final InjectedScrolling _injected;
//   _RebuildScrolling(this._injected);

//   ///Listen to the [InjectedScrolling] and rebuild when scrolling data is changed.
//   Widget onScroll(
//     Widget Function(InjectedScrolling) builder, {
//     Key? key,
//   }) {
//     return OnScroll(builder).listenTo(
//       _injected,
//       key: key,
//     );
//   }
// }

///Listen to an InjectedScrolling
class OnScroll<T> {
  final T Function(InjectedScrolling scroll) onScroll;
  OnScroll(this.onScroll);

  T? call(InjectedScrollingImp scroll) {
    return onScroll(scroll);
  }
}

/// Listen to an [InjectedScrolling] state.
///
/// The builder method is invoked when scrolling start, while scrolling and
/// when scrolling ends.
///  ```dart
///   OnScrollBuilder(
///     listenTo: scroll,
///     builder: (scroll) {
///       if (scroll.hasReachedMinExtent) {
///         return Text('isTop');
///       }
///
///       if (scroll.hasReachedMaxExtent) {
///         return Text('isBottom');
///       }
///
///       if (scroll.hasStartedScrollingReverse) {
///         return Text('hasStartedUp');
///       }
///       if (scroll.hasStartedScrollingForward) {
///         return Text('hasStartedDown');
///       }
///
///       if (scroll.hasStartedScrolling) {
///         return Text('hasStarted');
///       }
///
///       if (scroll.isScrollingReverse) {
///         return Text('isScrollingUp');
///       }
///       if (scroll.isScrollingForward) {
///         return Text('isScrollingDown');
///       }
///
///       if (scroll.isScrolling) {
///         return Text('isScrolling');
///       }
///
///       if (scroll.hasEndedScrolling) {
///         return Text('hasEnded');
///       }
///       return Text('NAN');
///     },
///   ),
///  ```
class OnScrollBuilder extends MyStatefulWidget {
  OnScrollBuilder({
    Key? key,
    required this.listenTo,
    required Widget Function(InjectedScrolling) builder,
  }) : super(
            key: key,
            observers: (_) => [listenTo as ReactiveModelImp],
            builder: (_, __, ___) => builder(listenTo));

  /// [InjectedScrolling] to listen to.
  final InjectedScrolling listenTo;

  /// The builder method is invoked when scrolling start, while scrolling and
  /// when scrolling ends.
  ///  ```dart
  ///   OnScrollBuilder(
  ///     listenTo: scroll,
  ///     builder: (scroll) {
  ///       if (scroll.hasReachedMinExtent) {
  ///         return Text('isTop');
  ///       }
  ///
  ///       if (scroll.hasReachedMaxExtent) {
  ///         return Text('isBottom');
  ///       }
  ///
  ///       if (scroll.hasStartedScrollingReverse) {
  ///         return Text('hasStartedUp');
  ///       }
  ///       if (scroll.hasStartedScrollingForward) {
  ///         return Text('hasStartedDown');
  ///       }
  ///
  ///       if (scroll.hasStartedScrolling) {
  ///         return Text('hasStarted');
  ///       }
  ///
  ///       if (scroll.isScrollingReverse) {
  ///         return Text('isScrollingUp');
  ///       }
  ///       if (scroll.isScrollingForward) {
  ///         return Text('isScrollingDown');
  ///       }
  ///
  ///       if (scroll.isScrolling) {
  ///         return Text('isScrolling');
  ///       }
  ///
  ///       if (scroll.hasEndedScrolling) {
  ///         return Text('hasEnded');
  ///       }
  ///       return Text('NAN');
  ///     },
  ///   ),
  ///  ```
  // final Widget Function(InjectedScrolling) builder;
  // @override
  // Widget build(BuildContext context) {
  //   return OnScroll(builder).listenTo(
  //     listenTo,
  //     key: key,
  //   );
  // }
}
