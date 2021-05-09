part of '../rm.dart';

extension BuildContextX on BuildContext {
  Widget get routeWidget {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.route != null);
    return r!.route!;
    // if (r!.animation == null || !r.shouldAnimate) {
    //   return r.route!;
    // }

    // final widget = r.transitionsBuilder?.call(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     ) ??
    //     _navigate.transitionsBuilder?.call(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     ) ??
    //     _getThemeTransition!(
    //       this,
    //       r.animation!,
    //       r.animation!,
    //       r.route!,
    //     );
    // return Stack(
    //   children: [
    //     r.lastSubRoute!,
    //     Builder(builder: (_) {
    //       return widget;
    //     }),
    //   ],
    // );
  }

  dynamic get routeArguments {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.routeData.arguments != null);
    return r!.routeData.arguments;
  }

  Map<String, String> get routeQueryParams {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.routeData.queryParams != null);
    return r!.routeData.queryParams;
  }

  Map<String, String> get routePathParams {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.routeData.pathParams != null);
    return r!.routeData.pathParams;
  }

  String get routeBaseUrl {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    assert(r?.routeData.baseUrl != null);

    return r!.routeData.baseUrl;
  }

  String get routePath {
    final r = getElementForInheritedWidgetOfExactType<SubRoute>()?.widget
        as SubRoute?;
    return r!.routeData.routePath;
  }

  static Animation<double>? ofRouteAnimation(BuildContext context) {
    final r = context
        .getElementForInheritedWidgetOfExactType<SubRoute>()
        ?.widget as SubRoute?;
    return r?.animation;
  }
}
