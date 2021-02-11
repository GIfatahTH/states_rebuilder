part of 'reactive_model.dart';

abstract class StatesRebuilder<T> {
  bool _autoDisposeWhenNotUsed = true;

  final _listenersOfStateFulWidget =
      <void Function(ReactiveModel<T>? rm, List? tags, bool isOnCRUD)>[];
  Disposer _listenToRMForStateFulWidget(
      void Function(ReactiveModel<T>? rm, List? tags, bool isOnCRUD) fn) {
    _listenersOfStateFulWidget.add(fn);
    return () {
      _listenersOfStateFulWidget.remove(fn);
      if (_listenersOfStateFulWidget.isEmpty) {
        _clean();
      }
    };
  }

  ///Check if this observable has observer
  bool get hasObservers => _listenersOfStateFulWidget.isNotEmpty;
  int get observerLength => _listenersOfStateFulWidget.length;

  void _notifyListeners([List? tags, bool isOnCRUD = false]) {
    _listenersOfStateFulWidget.forEach((fn) => fn(
        this is ReactiveModel<T> ? this as ReactiveModel<T> : null,
        tags,
        isOnCRUD));
  }

  void rebuildStates([List? tags]) {
    _notifyListeners(tags);
  }

  Widget statesRebuilderSubscription({
    void Function(BuildContext context)? onSetState,
    void Function(BuildContext context)? onAfterInitialBuild,
    void Function(BuildContext context)? onAfterBuild,
    required Widget Function(BuildContext context) child,
    void Function(BuildContext context)? initState,
    void Function(BuildContext context)? dispose,
    Object? Function()? watch,
    void Function(BuildContext context)? didChangeDependencies,
    void Function(BuildContext context, _StateBuilder oldWidget)?
        didUpdateWidget,
    bool Function(SnapState<T>? previousState)? shouldRebuild,
    dynamic tag,
    Key? key,
  }) {
    return _StateBuilder(
      key: key,
      initState: (context, setState, _) {
        initState?.call(context);
        if (onAfterInitialBuild != null) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onAfterInitialBuild(context),
          );
        }
        List<String> _tags = [];
        if (tag != null) {
          if (tag is List) {
            _tags.addAll(tag.map((dynamic e) => '$e'));
          } else {
            _tags.add('$tag');
          }
        }
        //
        return _listenToRMForStateFulWidget((rm, tags, __) {
          if (!(shouldRebuild?.call(null) ?? true)) {
            return;
          }
          if (tags != null) {
            if (tag == null || !tags.any((dynamic e) => _tags.contains('$e'))) {
              return;
            }
          }

          if (setState(rm)) {
            onSetState?.call(context);
            if (onAfterBuild != null) {
              WidgetsBinding.instance?.addPostFrameCallback(
                (_) => onAfterBuild(context),
              );
            }
          }
        });
      },
      dispose: (context) {
        dispose?.call(context);
      },
      watch: watch,
      didChangeDependencies: (context) => didChangeDependencies?.call(context),
      didUpdateWidget: (context, oldWidget) =>
          didUpdateWidget?.call(context, oldWidget),
      builder: (context, _) {
        return child.call(context);
      },
    );
  }

  final _cleaner = <void Function()>[];
  Disposer addToCleaner(void Function() fn, [bool insertAt0 = false]) {
    if (insertAt0) {
      _cleaner.insert(0, fn);
    } else {
      _cleaner.add(fn);
    }
    return () => _cleaner.remove(fn);
  }

  @mustCallSuper
  void _clean([bool force = false]) {
    if (!force && !_autoDisposeWhenNotUsed) {
      return;
    }
    _cleaner
      ..forEach((e) => e())
      ..clear();
  }
}
