import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/common/logger.dart';
import '../../rm.dart';
import '../../common/consts.dart';
import 'package:collection/collection.dart';
part 'i_crud.dart';
part 'on_crud.dart';

/// Injection of a state that can create, read, update and
/// delete from a backend or database service.
///
/// This injected state abstracts the best practices of the clean
/// architecture to come out with a simple, clean, and testable approach
/// to manage CRUD operations.
///
/// The approach consists fo the following steps:
/// * Define uer Item Model. (The name is up to you).
/// * You may define a class (or enum) to parametrize the query.
/// * Your repository must implements [ICRUD]<T, P> where T is the Item type
///  and P is the parameter
/// type. with `ICRUD<T, P>` you define CRUD methods.
/// * Instantiate an [InjectedCRUD] object using [RM.injectCRUD] method.
/// * Later on use [InjectedCRUD.crud].create, [InjectedCRUD.auth].read,
/// [InjectedCRUD.auth].update, and [InjectedCRUD.auth].delete item.
/// * In the UI you can use [ReactiveStatelessWidget], [OnReactive], or
/// [ObBuilder] to listen the this injected state and define the appropriate
/// view for each state.
/// * You may use [InjectedCRUD.item].inherited for performant list of item
/// rendering.
///
/// See: [InjectedCRUD.crud], [_CRUDService.read], [_CRUDService.create],
/// [_CRUDService.update], [_CRUDService.delete],[InjectedCRUD.item],
/// [_Item.inherited] and [OnCRUDBuilder]
abstract class InjectedCRUD<T, P> implements Injected<List<T>> {
  _CRUDService<T, P>? _crud;

  List<T> get _state => getInjectedState(this);

  ///To create Read Update and Delete
  _CRUDService<T, P> get crud => _crud ??= _crud = _CRUDService<T, P>(
        getRepoAs<ICRUD<T, P>>(),
        this as InjectedCRUDImp<T, P>,
      );

  _Item<T, P>? _item;

  ///Optimized for item displaying. Used with ListView
  _Item<T, P> get item => _item ??= _Item<T, P>(this);
  ICRUD<T, P>? _repo;

  ///Get the repository implementation
  R getRepoAs<R extends ICRUD<T, P>>() {
    if (_repo != null) {
      return _repo as R;
    }
    final repoMock = _cachedRepoMocks.last;
    _repo = repoMock != null
        ? repoMock()
        : (this as InjectedCRUDImp<T, P>).repoCreator();
    return _repo as R;
  }

  late bool _isOnCRUD;

  ///Whether the state is waiting for a CRUD operation to finish
  bool get isOnCRUD => _isOnCRUD;

  final List<ICRUD<T, P> Function()?> _cachedRepoMocks = [null];

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function

  void injectCRUDMock(ICRUD<T, P> Function() fakeRepository) {
    dispose();
    RM.disposeAll();
    _cachedRepoMocks.add(fakeRepository);
  }
}

///An implementation of [InjectedCRUD]
class InjectedCRUDImp<T, P> extends InjectedImp<List<T>>
    with InjectedCRUD<T, P> {
  InjectedCRUDImp({
    required this.repoCreator,
    this.param,
    this.readOnInitialization = false,
    this.onCRUD,
    //
    SnapState<List<T>>? Function(MiddleSnapState<List<T>> middleSnap)?
        middleSnapState,
    void Function(List<T>? s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(List<T>?)? toDebugString,
  }) : super(
          creator: () => <T>[],
          initialState: <T>[],
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          middleSnapState: middleSnapState,
          onSetState: onSetState,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          isLazy: true,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
        ) {
    _resetDefaultState = () {
      _isInitialized = false;
      _onCrudSnap = const SnapState.none();
      _item?.dispose();
      _item = null;
      _repo = null;
      _crud = null;
      _isOnCRUD = false;
      onCRUDListeners = ReactiveModelListener();
    };
    _resetDefaultState();
  }

  final ICRUD<T, P> Function() repoCreator;
  final P Function()? param;
  final bool readOnInitialization;
  final OnCRUD<void>? onCRUD;
  //
  late bool _isInitialized;
  late SnapState<dynamic> _onCrudSnap;
  SnapState<dynamic> get onCrudSnap {
    initialize();
    return _onCrudSnap;
  }

  late ReactiveModelListener onCRUDListeners;
  late final VoidCallback _resetDefaultState;
  @override
  dynamic middleCreator(
    dynamic Function() crt,
    dynamic Function()? creatorMock,
  ) {
    if (creatorMock != null) {
      return super.middleCreator(crt, creatorMock);
    }

    return () async {
      final List<T> cache = super.middleCreator(crt, creatorMock);
      if (cache.isNotEmpty) {
        snapState = snapState.copyToIsIdle(cache);
        await _init();
        return cache;
      }
      onMiddleCRUD(const SnapState.waiting());
      await _init();
      crud;

      if (readOnInitialization) {
        return super.middleCreator(
          () async {
            try {
              final l = await getRepoAs<ICRUD<T, P>>().read(param?.call());
              onMiddleCRUD(const SnapState.data());
              return [...l];
            } catch (e, s) {
              onMiddleCRUD(SnapState.error(e, s, () {
                resetReactiveModelBase(reactiveModelState);
                reactiveModelState.initializer();
              }));
              rethrow;
            }
          },
          creatorMock,
        );
      } else {
        onMiddleCRUD(const SnapState.data());
        return super.middleCreator(crt, creatorMock);
      }
    }();
  }

  void onMiddleCRUD(SnapState<dynamic> snap) {
    _onCrudSnap = snap;
    onCRUDListeners.rebuildState(snap);
    if (snap.isWaiting) {
      _isOnCRUD = true;
      onCRUD?.onWaiting?.call();
    } else if (snap.hasError) {
      _isOnCRUD = false;
      onCRUD?.onError?.call(snap.error, snap.onErrorRefresher!);
    } else if (snap.hasData) {
      _isOnCRUD = false;
      onCRUD?.onResult(snap.data);
    }
  }

  Future<void> _init() async {
    if (_isInitialized) {
      return;
    }
    await getRepoAs<ICRUD<T, P>>().init();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _crud?._dispose();
    if (_cachedRepoMocks.length > 1) {
      _cachedRepoMocks.removeLast();
    }
    _resetDefaultState();
    super.dispose();
  }
}

class _CRUDService<T, P> {
  ///The repository implantation associated with this
  ///service class
  final ICRUD<T, P> _repository;

  ///The injected model associated with this service
  ///class
  final InjectedCRUDImp<T, P> injected;
  _CRUDService(this._repository, this.injected);

  ///Read form a rest API or a database, notify listeners,
  ///and return a list of
  ///items.
  ///
  ///The optional [param] can be used to parametrize the
  ///query. For example it can hold the user id or user
  ///token.
  ///
  ///[param] can be also used to distinguish between many
  ///delete queries
  ///[onSetState] for side effects.
  ///
  ///[middleState] is a callback that exposes the current state
  ///before mutation and the next state and returns the state
  ///that will be used for mutation.
  ///
  ///Example if you want to append the new results to the old state:
  ///
  ///```dart
  ///product.crud.read(
  /// middleState: (state, nextState) {
  ///   return [..state, ...nextState];
  /// }
  ///)
  ///```
  Future<List<T>> read({
    P Function(P? param)? param,
    @Deprecated(('Use sideEffects instead')) On<void>? onSetState,
    SideEffects<List<T>>? sideEffects,
    List<T> Function(List<T> state, List<T> nextState)? middleState,
  }) async {
    injected.debugMessage = kReading;
    await injected.setState(
      (s) async {
        injected.onMiddleCRUD(const SnapState.waiting());
        await injected._init();
        final items = await _repository.read(
          param?.call(injected.param?.call()) ?? injected.param?.call(),
        );
        final result = middleState?.call(s, items) ?? items;
        injected.onMiddleCRUD(const SnapState.data());
        return result;
      },
      sideEffects: SideEffects(
        onSetState: (snap) {
          onSetState?.call(snap);
          sideEffects?.onSetState?.call(snap);
          if (snap.hasError) {
            injected.onMiddleCRUD(snap);
          }
        },
      ),
    );
    return injected._state;
  }

  ///Create an item
  ///
  ///The optional [param] can be used to parametrize the query.
  ///For example, it can hold the user id or user
  ///token.
  ///
  ///[param] can be also used to distinguish between many
  ///delete queries
  ///
  ///[onSetState] for side effects.
  ///
  ///[isOptimistic]: Whether the querying is done optimistically a
  ///nd mutates the state before sending the query, or it is done
  ///pessimistically and the state waits for the query to end and
  ///mutate. The default value is true.
  ///
  ///[onResult]: Invoked after the query ends successfully and
  ///exposed the return result.
  ///
  Future<T?> create(
    T item, {
    P Function(P? param)? param,
    void Function(dynamic result)? onResult,
    @Deprecated(('Use sideEffects instead')) On<void>? onSetState,
    SideEffects<List<T>>? sideEffects,
    bool isOptimistic = true,
  }) async {
    T? addedItem;

    injected.debugMessage = kCreating;
    Future<List<T>> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.waiting());
            if (isOptimistic) {
              yield <T>[...s, item];
            }
            try {
              await injected._init();
              addedItem = await _repository.create(
                item,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(const SnapState.data());
              onResult?.call(addedItem);
            } catch (e, stack) {
              injected.onMiddleCRUD(SnapState.error(e, stack, call));

              if (isOptimistic) {
                yield s.where((e) => e != item).toList();
              }
              rethrow;
            }
            if (!isOptimistic) {
              yield <T>[...s, addedItem!];
            }
          },
          sideEffects: SideEffects(
            onSetState: (snap) {
              onSetState?.call(snap);
              sideEffects?.onSetState?.call(snap);
            },
          ),
          skipWaiting: isOptimistic,
        );
    await call();
    if (injected.hasError) {
      if (isOptimistic) {
        injected.snapState = injected.snapState.copyToHasData(injected._state);
      }
    }
    return addedItem;
  }

  ///Update the the state (which is a List of items), notify listeners
  ///and send update query to the database.
  ///
  ///By default the update is done optimistically. That is the state
  ///is mutated and listeners are notified before querying the database.
  ///If
  /// * Required parameters:
  ///     * [where] : Callback to filter items to be updated. It takes
  /// an item from the list and returns true if the item will be updated.
  ///     * [set] : Callback to map the old item to the new one. It takes
  /// an item to be updated and returns a new updated item.
  /// * Optional parameters:
  ///    * [param] : used to parametrizes the query. It can also be used to
  /// identify many update calls.
  ///    * [onSetState] : user for side effects.
  ///    * [onResult] : Hook to be called whenever the items are updated in t
  /// he database. It expoeses the return result (for example number of update line)
  ///    * [isOptimistic] : If true the state is mutated .
  ///
  Future<void> update({
    required bool Function(T item) where,
    required T Function(T item) set,
    P Function(P? param)? param,
    @Deprecated(('Use sideEffects instead')) On<void>? onSetState,
    SideEffects<List<T>>? sideEffects,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final updated = <T>[];
    final newState = <T>[];

    injected._state.forEachIndexed((i, e) {
      oldState.add(e);
      if (where(e)) {
        final newItem = set(e);
        updated.add(newItem);
        newState.add(newItem);
      } else {
        newState.add(e);
      }
    });
    if (updated.isEmpty) {
      return;
    }
    injected.debugMessage = kUpdating;
    Future<List<T>> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.waiting());
            if (isOptimistic) {
              yield newState;
              if (injected._item != null) {
                injected._item!._refresh();
              }
            }
            try {
              await injected._init();
              final dynamic r = await _repository.update(
                updated,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(SnapState.data(r));
              onResult?.call(r);
            } catch (e, s) {
              injected.onMiddleCRUD(SnapState.error(e, s, call));
              if (isOptimistic) {
                yield oldState;
                if (injected._item != null) {
                  injected._item!.injected.refresh();
                }
              }
              rethrow;
            }
            if (!isOptimistic) {
              yield newState;
            }
          },
          sideEffects: SideEffects(
            onSetState: (snap) {
              onSetState?.call(snap);
              sideEffects?.onSetState?.call(snap);
            },
          ),
          skipWaiting: isOptimistic,
        );
    await call();
    if (injected.hasError) {
      if (isOptimistic) {
        injected.snapState = injected.snapState.copyToHasData(oldState);
      }
    }
  }

  ///Delete items form the state, notify listeners
  ///and send update query to the database.
  ///
  ///By default the delete is done optimistically. That is the state
  ///is mutated and listeners are notified before querying the database.
  ///If
  /// * Required parameters:
  ///     * [where] : Callback to filter items to be deleted. It takes
  /// an item from the list and returns true if the item will be deleted.
  /// * Optional parameters:
  ///    * [param] : used to parametrizes the query. It can also be used to
  /// identify many update calls.
  ///    * [onSetState] : user for side effects.
  ///    * [onResult] : Hook to be called whenever the items are deleted in
  /// the database. It exposes the return result (for example number of deleted line)
  ///    * [isOptimistic] : If true the state is mutated .

  Future<void> delete({
    required bool Function(T item) where,
    P Function(P? param)? param,
    @Deprecated(('Use sideEffects instead')) On<void>? onSetState,
    SideEffects<List<T>>? sideEffects,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final removed = <T>[];
    final newState = <T>[];

    injected._state.forEachIndexed((i, e) {
      oldState.add(e);
      if (where(e)) {
        removed.add(e);
      } else {
        newState.add(e);
      }
    });
    if (removed.isEmpty) {
      return;
    }
    injected.debugMessage = kDeleting;
    Future<List<T>> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.waiting());

            if (isOptimistic) {
              yield newState;
            }
            try {
              await injected._init();
              final dynamic r = await _repository.delete(
                removed,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(SnapState.data(r));
              onResult?.call(r);
            } catch (e, s) {
              injected.onMiddleCRUD(SnapState.error(e, s, call));
              if (isOptimistic) {
                yield oldState;
              }
              rethrow;
            }

            if (!isOptimistic) {
              yield newState;
            }
          },
          sideEffects: SideEffects(
            onSetState: (snap) {
              onSetState?.call(snap);
              sideEffects?.onSetState?.call(snap);
            },
          ),
        );
    await call();
    if (injected.hasError) {
      if (isOptimistic) {
        injected.snapState = injected.snapState.copyToHasData(oldState);
      }
    }
  }

  void _dispose() async {
    _repository.dispose();
  }
}

class _Item<T, P> {
  final InjectedCRUD<T, P> injectedList;
  late final Injected<T> injected;
  bool _isUpdating = false;
  bool _isRefreshing = false;
  _Item(this.injectedList) {
    injected = RM.inject(
      () => injectedList._state.first,
      sideEffects: SideEffects.onData(
        (_) async {
          if (_isRefreshing) {
            return;
          }
          _isUpdating = true;
          try {
            await injectedList.crud.update(
              where: (t) {
                return t == (injected as InjectedImp).oldSnap?.data;
              },
              set: (t) => getInjectedState(injected),
            );
            _isUpdating = false;
          } catch (e) {
            _isUpdating = false;
          }
        },
      ),
      debugPrintWhenNotifiedPreMessage: 'injectedList',
    );
  }

  void _refresh() async {
    if (_isUpdating || _isRefreshing) {
      return;
    }
    _isRefreshing = true;
    await injected.refresh();
    _isRefreshing = false;
  }

  ///Provide the an item using an [InheritedWidget] to the sub-branch widget tree.
  ///
  ///The provided Item be obtained using .of(context) or .call(context) methods.

  Widget inherited({
    required Key key,
    required T Function()? item,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    return injected.inherited(
      key: key,
      stateOverride: item,
      builder: builder,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  ///Provide the item to another widget tree branch.
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    return injected.reInherited(
      key: key,
      context: context,
      builder: builder,
    );
  }

  ///Obtain the item from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will be registered so that when this Injected model
  ///emits a notification, the [Element] related the the [BuildContext] will rebuild.
  ///
  ///If you want to obtain the state without registering use the [call] method.
  T of(BuildContext context) {
    return injected.of(context)!;
  }

  ///Obtain the item from the nearest [InheritedWidget] inserted using [inherited].
  ///The [BuildContext] used, will not be registered.
  ///If you want to obtain the state and register it use the [of] method.
  Injected<T>? call(BuildContext context) {
    final inj = injected.call(
      context,
      defaultToGlobal: true,
    );
    return inj == injected ? null : inj;
  }

  void dispose() {
    injected.dispose();
  }
}
