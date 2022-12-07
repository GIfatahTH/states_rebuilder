import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../states_rebuilder.dart';
import '../../state_management/rm.dart';

part 'i_crud.dart';
part 'on_crud_builder.dart';

/// Injection of a state that can create, read, update and
/// delete from a backend or database service.
///
/// This injected state abstracts the best practices of the clean
/// architecture to come out with a simple, clean, and testable approach
/// to manage CRUD operations.
///
/// The approach consists of the following steps:
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

  ///To create Read Update and Delete
  _CRUDService<T, P> get crud => _crud ??= _crud = _CRUDService<T, P>(
        getRepoAs<ICRUD<T, P>>(),
        this as InjectedCRUDImp<T, P>,
      );

  // _Item<T, P>? _item;

  /// Optimized for item displaying. Used with
  ///
  /// Working with a list of items, we may want to display them using the
  /// `ListView` widget of Flutter. At this stage, we are faced with some
  /// problems regarding :
  /// - performance: Can we use the `const` constructor for the item widget.
  /// Then, how to update the item widget if the list of items updates.
  /// - Widget tree structure: What if the item widget is a big widget with
  /// its nested widget tree. Then, how to pass the state of the item through
  ///  the widget three? Are we forced to pass it through a nest tree of
  ///  constructors?
  ///  - State mutation: How to efficiently update the list of items when an item
  ///  is updated.
  ///
  /// InjectedCRUD, solves those problems using the concept of inherited
  /// injected. [Injected.inherited]
  ///
  /// Example:
  ///
  /// ### inherited
  /// ```dart
  /// products.inherited({
  ///     required Key  key,
  ///     required T Function()? item,
  ///     required Widget Function(BuildContext) builder,
  ///     String? debugPrintWhenNotifiedPreMessage,
  ///  })
  /// ```
  /// Key is required here because we are dealing with a list of widgets with
  /// a similar state.
  ///
  /// Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return OnReactive(
  ///        ()=>  ListView.builder(
  ///           itemCount: products.state.length,
  ///           itemBuilder: (context, index) {
  ///             //Put InheritedWidget here that holds the item state
  ///             return todos.item.inherited(
  ///               key: Key('${products.state[index].id}'),
  ///               item: () => products.state[index],
  ///               builder: (context) => const ProductItem(),//use of const
  ///             );
  ///           },
  ///         );
  ///   );
  /// ```
  /// In the ListBuilder, we used the `inherited` method to display the
  /// `ItemWidget`. This has huge advantages:
  ///
  /// - As the `inherited` method inserts an` InheritedWidget` above`ItemWidget`
  /// , we can take advantage of everything you know about` InheritedWidget`.
  /// - Using const constructors for item widgets.
  /// - Item widgets can be gigantic widgets with a long widget tree. We can
  /// easily get the state of an item and mutate it with the state of the
  /// original list of items even in the deepest widget.
  /// - The `inherited` method, binds the item to the list of items so that
  /// updating an item updates the state of the list of items and sends an
  /// update request to the database. Likewise, updating the list of items will
  /// update the `ItemWidget` even if it is built with the const constructor.
  ///
  /// ### call(context)
  /// From a child of the item widget, we can obtain an injected state of the
  /// item using the call method:
  /// ```dart
  /// Inherited<T> product = products.item.call(context);
  /// //item is callable object. `call` can be removed
  /// Inherited<T> product = products.item(context);
  /// ```
  /// You can use the injected product to listen to and mutate the state.
  ///
  /// ```dart
  /// product.state = updatedProduct;
  /// ```
  /// Here we mutated the state of one item, the UI will update to display the
  /// new state, and, **importantly, the list of items will update and update
  /// query with the default parameter is sent to the backend service.**
  ///
  /// **Another important behavior is that if the list of items is updated, the
  /// item states will update and the Item Widget is re-rendered, even if it is
  /// declared with const constructor.** (This is possible because of the
  /// underlying InheritedWidget).
  ///
  /// ### of(context)
  /// It is used to obtain the state of an item. The `BuildContext` is
  /// subscribed to the inherited widget used on top of the item widget,
  ///
  /// ```dart
  /// T product = products.item.of(context);
  /// ```
  /// > of(context) vs call(context):
  /// >  - of(context) gets the state of the item, whereas, call(context) gets
  /// the `Injected` object.
  /// >  * of(context) subscribes the BuildContext to the InheritedWidget,
  /// whereas call(context) does not.
  ///
  /// ### reInherited
  /// As we know `InheritedWidget` cannot cross route boundary unless it is
  /// defined above the `MaterielApp` widget (which s a nonpractical case).
  ///
  /// After navigation, the `BuildContext` connection loses the connection
  /// with the `InheritedWidgets` defined in the old route. To overcome this
  /// shortcoming, with state_rebuilder, we can reinject the state to the next
  /// route:
  ///
  /// ```dart
  /// RM.navigate.to(
  ///   products.item.reInherited(
  ///      // Pass the current context
  ///      context : context,
  ///      // The builder method, Notice we can use const here, which is a big
  ///      // performance gain
  ///      builder: (BuildContext context)=>  const NewItemDetailedWidget()
  ///   )
  /// )
  /// ```
  ///
  late final _Item<T, P> item = _Item<T, P>(this as InjectedCRUDImp<T, P>);
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
class InjectedCRUDImp<T, P> extends InjectedImpRedoPersistState<List<T>>
    with InjectedCRUD<T, P> {
  ///An implementation of [InjectedCRUD]
  InjectedCRUDImp({
    required this.repoCreator,
    required this.param,
    required this.readOnInitialization,
    required this.onCRUDSideEffects,
    //
    required StateInterceptor<List<T>>? stateInterceptor,
    // SnapState<List<T>>? Function(MiddleSnapState<List<T>> middleSnap)?
    //     middleSnapState,
    // void Function(List<T>? s)? onInitialized,
    // void Function(List<T> s)? onDisposed,
    // On<void>? onSetState,
    required SideEffects<List<T>>? sideEffects,
    //
    required DependsOn<List<T>>? dependsOn,
    required int undoStackLength,
    required PersistState<List<T>> Function()? persist,
    required bool autoDisposeWhenNotUsed,
    required String? debugPrintWhenNotifiedPreMessage,
    required String Function(List<T>?)? toDebugString,
  }) : super(
          creator: () => <T>[],
          initialState: <T>[],
          sideEffects: sideEffects,
          stateInterceptor: stateInterceptor,
          persist: persist,
          undoStackLength: undoStackLength,
          dependsOn: dependsOn,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          watch: null,
        );

  final ICRUD<T, P> Function() repoCreator;
  final P Function()? param;
  final bool readOnInitialization;
  final OnCRUDSideEffects? onCRUDSideEffects;
  //
  ReactiveModelImp<Object?>? _onCrudRM;
  ReactiveModelImp<Object?> get onCrudRM {
    if (_onCrudRM != null) {
      return _onCrudRM!;
    }
    _onCrudRM = ReactiveModel.create(creator: () => snapValue.data)
        as ReactiveModelImp<Object?>;
    initialize();
    if (snapValue.isWaiting || !_isOnCRUD) {
      _isOnCRUD = snapValue.isWaiting;
      _onCrudRM!.snapValue = snapValue;
    }
    return _onCrudRM!;
  }

  late bool _isInitialized;
  @override
  void resetDefaultState([VoidCallback? fn]) {
    super.resetDefaultState(fn);
    _isInitialized = false;
    _onCrudRM?.dispose();
    _onCrudRM = null;
    item._dispose();
    _repo = null;
    _crud = null;
    _isOnCRUD = false;
  }

  @override
  Object? Function() get mockableCreator {
    if (cachedCreatorMocks.last != null) {
      isWaitingToInitialize = true;
      return super.mockableCreator;
    }
    return () async {
      final List<T> cache = super.mockableCreator() as List<T>;
      if (cache.isNotEmpty) {
        await _init();
        onMiddleCRUD(const SnapState.none().copyToHasData(cache));
        return cache;
      }
      onMiddleCRUD(const SnapState.none().copyToIsWaiting());
      await _init();
      // crud;
      if (readOnInitialization) {
        try {
          final l = await getRepoAs<ICRUD<T, P>>().read(param?.call());
          onMiddleCRUD(const SnapState.none().copyToHasData(l));
          return [...l];
        } catch (e, s) {
          onMiddleCRUD(
            const SnapState.none().copyWith(
              status: StateStatus.hasError,
              error: SnapError(
                error: e,
                stackTrace: s,
                refresher: refresh,
              ),
              infoMessage: '',
            ),
          );
          rethrow;
        }
      } else {
        onMiddleCRUD(const SnapState.none().copyToHasData(cache));
        return cache;
      }
    };
  }

  void onMiddleCRUD(SnapState<dynamic> snap) {
    if (_onCrudRM != null && _onCrudRM!.snapValue != snap) {
      _onCrudRM!.snapValue = snap;
      _onCrudRM!.notify();
    }
    if (snap.isWaiting) {
      _isOnCRUD = true;
      onCRUDSideEffects?.onWaiting?.call();
    } else if (snap.hasError) {
      _isOnCRUD = false;
      onCRUDSideEffects?.onError
          ?.call(snap.snapError!.error, snap.snapError!.refresher);
    } else if (snap.hasData) {
      _isOnCRUD = false;
      onCRUDSideEffects?.onResult(snap.data);
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
  void injectFutureMock(Future<List<T>> Function() fakeCreator) async {
    super.injectFutureMock(fakeCreator);
    stateAsync.then(
      (value) => onMiddleCRUD(
        const SnapState.none().copyToHasData(snapValue.data),
      ),
    );
  }

  @override
  void dispose() {
    _crud?._dispose();
    if (_cachedRepoMocks.length > 1) {
      _cachedRepoMocks.removeLast();
    }
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
  ///
  ///[sideEffects] for side effects.
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
    SideEffects<List<T>>? sideEffects,
    List<T> Function(List<T> state, List<T> nextState)? middleState,
  }) async {
    // injected.debugMessage = kReading;
    await injected.setState(
      (s) async {
        injected.onMiddleCRUD(const SnapState.none().copyToIsWaiting());
        await injected._init();
        final items = await _repository.read(
          param?.call(injected.param?.call()) ?? injected.param?.call(),
        );
        final result = middleState?.call(s, items) ?? items;
        injected.onMiddleCRUD(const SnapState.none().copyToHasData(result));
        return result;
      },
      sideEffects: SideEffects(
        onSetState: (snap) {
          sideEffects?.onSetState?.call(snap);
          if (snap.hasError) {
            injected.onMiddleCRUD(snap);
          }
        },
      ),
    );
    return injected.snapValue.state;
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
  ///[sideEffects] for side effects.
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
    SideEffects<List<T>>? sideEffects,
    bool isOptimistic = true,
  }) async {
    T? addedItem;

    // injected.debugMessage = kCreating;
    Future<List<T>?> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.none().copyToIsWaiting());
            if (isOptimistic) {
              yield <T>[...s, item];
            }
            try {
              await injected._init();
              addedItem = await _repository.create(
                item,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(
                  const SnapState.none().copyToHasData(addedItem));
              onResult?.call(addedItem);
            } catch (e, stack) {
              injected.onMiddleCRUD(
                const SnapState.none().copyWith(
                  status: StateStatus.hasError,
                  error: SnapError(
                    error: e,
                    stackTrace: stack,
                    refresher: call,
                  ),
                  infoMessage: '',
                ),
              );

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
              sideEffects?.onSetState?.call(snap);
            },
          ),
          stateInterceptor: isOptimistic
              ? (current, next) {
                  if (next.isWaiting) {
                    return current;
                  }
                  return next;
                }
              : null,
        );
    await call();
    // if (injected.hasError) {
    //   if (isOptimistic) {
    //     injected.setToHasData(injected.snapValue.state);
    //   }
    // }
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
  ///    * [sideEffects] : user for side effects.
  ///    * [onResult] : Hook to be called whenever the items are updated in t
  /// he database. It expoeses the return result (for example number of update line)
  ///    * [isOptimistic] : If true the state is mutated .
  ///
  Future<void> update({
    required bool Function(T item) where,
    required T Function(T item) set,
    P Function(P? param)? param,
    SideEffects<List<T>>? sideEffects,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final updated = <T>[];
    final newState = <T>[];

    injected.snapValue.data!.forEachIndexed((i, e) {
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
    // injected.debugMessage = kUpdating;
    Future<List<T>?> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.none().copyToIsWaiting());
            if (isOptimistic) {
              yield newState;
              injected.item._refresh();
            }
            try {
              await injected._init();
              final dynamic r = await _repository.update(
                updated,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(const SnapState.none().copyToHasData(r));
              onResult?.call(r);
            } catch (e, s) {
              injected.onMiddleCRUD(
                const SnapState.none().copyWith(
                  status: StateStatus.hasError,
                  error: SnapError(
                    error: e,
                    stackTrace: s,
                    refresher: call,
                  ),
                  infoMessage: '',
                ),
              );
              if (isOptimistic) {
                yield oldState;
                injected.item._refresh();
              }
              rethrow;
            }
            if (!isOptimistic) {
              yield newState;
            }
          },
          sideEffects: SideEffects(
            onSetState: (snap) {
              sideEffects?.onSetState?.call(snap);
            },
          ),
          stateInterceptor: isOptimistic
              ? (current, next) {
                  if (next.isWaiting) {
                    return current;
                  }
                  return next;
                }
              : null,
        );
    await call();
    // if (injected.hasError) {
    //   if (isOptimistic) {
    //     injected.setToHasData(oldState);
    //   }
    // }
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
  ///    * [sideEffects] : user for side effects.
  ///    * [onResult] : Hook to be called whenever the items are deleted in
  /// the database. It exposes the return result (for example number of deleted line)
  ///    * [isOptimistic] : If true the state is mutated .
  Future<void> delete({
    required bool Function(T item) where,
    P Function(P? param)? param,
    SideEffects<List<T>>? sideEffects,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final removed = <T>[];
    final newState = <T>[];

    injected.snapValue.data!.forEachIndexed((i, e) {
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

    // injected.debugMessage = kDeleting;
    Future<List<T>?> call() => injected.setState(
          (s) async* {
            injected.onMiddleCRUD(const SnapState.none().copyToIsWaiting());
            if (isOptimistic) {
              yield newState;
            }
            try {
              await injected._init();
              final dynamic r = await _repository.delete(
                removed,
                param?.call(injected.param?.call()) ?? injected.param?.call(),
              );
              injected.onMiddleCRUD(const SnapState.none().copyToHasData(r));
              onResult?.call(r);
            } catch (e, s) {
              injected.onMiddleCRUD(
                const SnapState.none().copyWith(
                  status: StateStatus.hasError,
                  error: SnapError(
                    error: e,
                    stackTrace: s,
                    refresher: call,
                  ),
                  infoMessage: '',
                ),
              );
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
              sideEffects?.onSetState?.call(snap);
            },
          ),
          stateInterceptor: isOptimistic
              ? (current, next) {
                  if (next.isWaiting) {
                    return current;
                  }
                  return null;
                }
              : null,
        );
    await call();
    // if (injected.hasError) {
    //   if (isOptimistic) {
    //     injected.setToHasData(oldState);
    //   }
    // }
  }

  void _dispose() async {
    _repository.dispose();
  }
}

class _Item<T, P> {
  final InjectedCRUDImp<T, P> _injectedList;

  // bool _isUpdating = false;
  // bool _isRefreshing = false;
  _Item(this._injectedList);

  late final InjectedImp<T> _injected = RM.inject<T>(
    () => throw UnimplementedError(),
    sideEffects: SideEffects.onData(
      (_) {
        _injectedList.crud.update(
          where: (t) {
            return t == _injected.oldSnapState?.data;
          },
          set: (t) => _injected.snapValue.data!,
        );
      },
    ),
    // debugPrintWhenNotifiedPreMessage: 'injectedList',
  ) as InjectedImp<T>;

  void _refresh() => _injected.refresh();

  ///Provide the an item using an [InheritedWidget] to the sub-branch widget tree.
  ///
  ///The provided Item be obtained using .of(context) or .call(context) methods.
  ///
  ///Example:
  ///
  /// ### inherited
  /// ```dart
  /// products.inherited({
  ///     required Key  key,
  ///     required T Function()? item,
  ///     required Widget Function(BuildContext) builder,
  ///     String? debugPrintWhenNotifiedPreMessage,
  ///  })
  /// ```
  /// Key is required here because we are dealing with a list of widgets with
  /// a similar state.
  ///
  /// Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return OnReactive(
  ///        ()=>  ListView.builder(
  ///           itemCount: products.state.length,
  ///           itemBuilder: (context, index) {
  ///             //Put InheritedWidget here that holds the item state
  ///             return todos.item.inherited(
  ///               key: Key('${products.state[index].id}'),
  ///               item: () => products.state[index],
  ///               builder: (context) => const ProductItem(),//use of const
  ///             );
  ///           },
  ///         );
  ///   );
  /// ```
  /// In the ListBuilder, we used the `inherited` method to display the
  /// `ItemWidget`. This has huge advantages:
  ///
  /// - As the `inherited` method inserts an` InheritedWidget` above`ItemWidget`
  /// , we can take advantage of everything you know about` InheritedWidget`.
  /// - Using const constructors for item widgets.
  /// - Item widgets can be gigantic widgets with a long widget tree. We can
  /// easily get the state of an item and mutate it with the state of the
  /// original list of items even in the deepest widget.
  /// - The `inherited` method, binds the item to the list of items so that
  /// updating an item updates the state of the list of items and sends an
  /// update request to the database. Likewise, updating the list of items will
  /// update the `ItemWidget` even if it is built with the const constructor.
  Widget inherited({
    required Key key,
    required T Function()? item,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return _injected.inherited(
      key: key,
      stateOverride: item,
      connectWithGlobal: true,
      builder: builder,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  ///Provide the item to another widget tree branch.
  ///
  /// As we know `InheritedWidget` cannot cross route boundary unless it is
  /// defined above the `MaterielApp` widget (which s a nonpractical case).
  ///
  /// After navigation, the `BuildContext` connection loses the connection
  /// with the `InheritedWidgets` defined in the old route. To overcome this
  /// shortcoming, with state_rebuilder, we can reinject the state to the next
  /// route:
  ///
  /// ```dart
  /// RM.navigate.to(
  ///   products.item.reInherited(
  ///      // Pass the current context
  ///      context : context,
  ///      // The builder method, Notice we can use const here, which is a big
  ///      // performance gain
  ///      builder: (BuildContext context)=>  const NewItemDetailedWidget()
  ///   )
  /// )
  /// ```
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    return _injected.reInherited(
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
    return _injected.of(context)!;
  }

  ///Obtain the item from the nearest [InheritedWidget] inserted using [inherited].
  ///The [BuildContext] used, will not be registered.
  ///If you want to obtain the state and register it use the [of] method.
  Injected<T>? call(BuildContext context) {
    final inj = _injected.call(
      context,
      defaultToGlobal: true,
    );
    return inj == _injected ? null : inj;
  }

  void _dispose() {
    _injected.dispose();
  }
}
