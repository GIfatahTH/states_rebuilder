part of '../../reactive_model.dart';

///Interface to implement to query a rest API or
///database for Create,
///Read, Update, and Delete of Items-Item.
///
///The first generic type is the item type.
///
///the second generic type is for the query parameter
///type
abstract class ICRUD<T, P> {
  ///Initialize any plugging and return the
  ///initialized instance.
  Future<void> init();

  ///Read from rest API or a database and get a list
  ///of items
  ///
  ///The param argument can be used to defined the query
  ///parameter
  Future<List<T>> read(P? param);

  ///Create an Item
  ///
  ///It takes an item to create and returns the added
  ///item that
  ///may be different form the taken item (ex: when the
  ///id is
  ///defined form the database).
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  Future<T> create(T item, P? param);

  ///Update a list of items
  ///
  ///It takes the list of updated items.
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[param] can be also used to distinguish between many
  ///update queries
  Future<dynamic> update(List<T> items, P? param);

  ///Delete a list of items
  ///
  ///It takes the list of deleted items.
  ///
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[param] can be also used to distinguish between many
  ///delete queries
  Future<dynamic> delete(List<T> items, P? param);

  ///It is called when the injected model is disposed
  ///
  ///This is the right place for cleaning resources.
  void dispose();
}

class _CRUDService<T, P> {
  ///The repository implantation associated with this
  ///service class
  final FutureOr<ICRUD<T, P>> _repository;

  ///The injected model associated with this service
  ///class
  final InjectedCRUD<T, P> injected;
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
  ///Expample if you want to append the new results to the old state:
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
    On<void>? onSetState,
    List<T> Function(List<T> state, List<T> nextState)? middleState,
  }) async {
    injected._result = null;
    await injected.setState(
      (s) async {
        final _repo = await _repository;
        final items = await _repo.read(
          param?.call(injected._param?.call()) ?? injected._param?.call(),
        );

        return middleState?.call(s, items) ?? items;
      },
      onSetState: onSetState,
    );
    return injected.state;
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
    On<void>? onSetState,
    bool isOptimistic = true,
  }) async {
    T? addedItem;
    injected
      .._result = null
      .._isOnCRUD = false;
    await injected.setState(
      (s) async* {
        final _repo = await _repository;
        if (isOptimistic) {
          s.add(item);
          injected._isOnCRUD = true;
          yield item;
        }
        try {
          addedItem = await _repo.create(
            item,
            param?.call(injected._param?.call()) ?? injected._param?.call(),
          );
          onResult?.call(addedItem);
        } catch (e) {
          injected._isOnCRUD = false;
          if (isOptimistic) {
            yield s.remove(item);
          }
          rethrow;
        }
        if (!isOptimistic) {
          s.add(addedItem!);
          yield item;
        } else {
          injected._isOnCRUD = false;
          injected._notifyListeners(null, true);
        }
      },
      onSetState: onSetState,
      skipWaiting: isOptimistic,
    );
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
    On<void>? onSetState,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final updated = <T>[];
    final newState = <T>[];
    injected
      .._result = null
      .._isOnCRUD = false;
    injected.state.forEachIndexed((i, e) {
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
    await injected.setState(
      (s) async* {
        final _repo = await _repository;

        if (isOptimistic) {
          injected._isOnCRUD = true;
          yield newState;
          if (injected._item != null) {
            injected._item!.refresh();
          }
        }
        try {
          final dynamic r = await _repo.update(
            updated,
            param?.call(injected._param?.call()) ?? injected._param?.call(),
          );
          injected._result = r;
          onResult?.call(r);
        } catch (e) {
          injected._isOnCRUD = false;
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
        } else {
          injected._isOnCRUD = false;
          injected._notifyListeners(null, true);
        }
      },
      onSetState: onSetState,
      skipWaiting: isOptimistic,
    );
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
  /// the database. It expoeses the return result (for example number of deleted line)
  ///    * [isOptimistic] : If true the state is mutated .

  Future<void> delete({
    required bool Function(T item) where,
    P Function(P? param)? param,
    On<void>? onSetState,
    void Function(dynamic result)? onResult,
    bool isOptimistic = true,
  }) async {
    final oldState = <T>[];
    final removed = <T>[];
    final newState = <T>[];
    injected
      .._result = null
      .._isOnCRUD = false;
    injected.state.forEachIndexed((i, e) {
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
    await injected.setState(
      (s) async* {
        final _repo = await _repository;

        if (isOptimistic) {
          injected._isOnCRUD = true;
          yield newState;
        }
        try {
          final dynamic r = await _repo.delete(
            removed,
            param?.call(injected._param?.call()) ?? injected._param?.call(),
          );
          injected._result = r;
          onResult?.call(r);
        } catch (e) {
          injected._isOnCRUD = false;
          if (isOptimistic) {
            yield oldState;
          }
          rethrow;
        }
        if (!isOptimistic) {
          yield newState;
        } else {
          injected._isOnCRUD = false;
          injected._notifyListeners(null, true);
        }
      },
      onSetState: onSetState,
    );
  }

  void _dispose() async {
    final _repo = await _repository;
    _repo.dispose();
  }
}
