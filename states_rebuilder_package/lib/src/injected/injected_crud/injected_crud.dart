part of '../../reactive_model.dart';

class InjectedCRUD<T, P> extends InjectedImp<List<T>> {
  InjectedCRUD({
    required dynamic Function() creator,
    P Function()? param,
    List<T>? initialState,
    void Function(List<T> s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,

    //
  })  : _param = param,
        super(
          creator: (_) => creator(),
          initialValue: initialState,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          on: onSetState,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          //
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          debugError: debugError,
        );
  final P Function()? _param;
  bool _readOnInitialization = false;
  _CRUDService<T, P> get crud {
    _initialize();
    return _crud!;
  }

  _CRUDService<T, P>? _crud;
  Future<R> getRepoAs<R>() async {
    assert(R != dynamic && R != Object);
    return (await crud._repository) as R;
  }

  _Item<T, P>? _item;
  _Item<T, P> get item => _item ??= _Item<T, P>(this)
    ..injected.addToCleaner(
      () => _item = null,
    );

  @override
  void _onDisposeState() {
    _crud?._dispose();
    super._onDisposeState();
  }

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectCRUDMock(ICRUD<T, P> Function() fakeRepository) {
    final creator = () {
      final fn = () async {
        final repo = fakeRepository();
        await repo.init();
        return repo;
      };
      _crud = _CRUDService(fn(), this);
      if (!_isFirstInitialized && !_readOnInitialization) {
        return <T>[];
      } else {
        return () async {
          final _repo = await _crud!._repository;
          final l = await _repo.read(_param?.call());
          return [...l];
        }();
      }
    };
    _cachedMockCreator ??= (_) => creator();
    _cleanUpState((_) => creator());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}

class _Item<T, P> {
  final InjectedCRUD<T, P> injectedList;
  late Injected<T> injected;
  bool _isUpdating = false;
  _Item(this.injectedList) {
    injected = RM.inject(
      () => injectedList.state.first,
      onSetState: On.data(
        () async {
          _isUpdating = true;
          await injectedList.crud.update(
            where: (t) => t == injected._previousSnapState?.data,
            set: (t) => injected.state,
          );
          _isUpdating = false;
        },
      ),
    );
  }
  void refresh() {
    if (_isUpdating) {
      return;
    }
    injected.refresh();
  }

  Widget inherited({
    required Key key,
    required T Function()? item,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    return injected.inherited(
      key: key,
      stateOverride: item,
      builder: builder,
    );
  }

  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    return injected.reInherited(
      key: key,
      context: context,
      builder: builder,
      // connectWithGlobal: true,
    );
  }

  T? of(BuildContext context) => injected.of(context);
  Injected<T>? call(BuildContext context) => injected(context);
}
