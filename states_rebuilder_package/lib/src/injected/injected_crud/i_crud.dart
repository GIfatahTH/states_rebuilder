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
  Future<ICRUD<T, P>> init();

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
  final FutureOr<ICRUD<T, P>> repo;

  ///The injected model associated with this service
  ///class
  final InjectedCRUD<T, P> injected;
  _CRUDService(this.repo, this.injected);

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
  Future<List<T>> read({P Function()? param}) async {
    await injected.setState(
      (s) async {
        final _repo = await repo;
        return _repo.read(
          param?.call() ?? injected._param?.call(),
        );
      },
    );
    return injected.state;
  }

  //return null means an error
  Future<T?> create(
    T item, {
    P Function()? param,
    void Function()? onStateMutation,
    void Function(dynamic result)? onCRUD,
    void Function(dynamic error)? onError,
    bool isOptimistic = true,
  }) async {
    T? addedItem;
    await injected.setState(
      (s) async* {
        final _repo = await repo;
        if (isOptimistic) {
          s.add(item);
          yield item;
        }
        try {
          addedItem = await _repo.create(
            item,
            param?.call() ?? injected._param?.call(),
          );
          onCRUD?.call(addedItem);
        } catch (e) {
          if (isOptimistic) {
            s.remove(item);
          }
          yield item;
          onError?.call(e);
          rethrow;
        }
        if (!isOptimistic) {
          s.add(addedItem!);
          yield item;
        }
      },
      onSetState: onStateMutation != null ? On.data(onStateMutation) : null,
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
  ///    * [onStateMutation] : Hook to be called whenever the state is mutated.
  ///    * [onCRUD] : Hook to be called whenever the items are updated in the database
  ///    * [isOptimistic] : If true the state is mutated .
  ///
  Future<void> update({
    required bool Function(T item) where,
    required T Function(T item) set,
    P Function()? param,
    void Function()? onStateMutation,
    void Function(dynamic result)? onCRUD,
    void Function(dynamic error)? onError,
    bool isOptimistic = true,
  }) async {
    await injected.setState(
      (s) async* {
        final _repo = await repo;
        final List<T> oldState = [];
        final List<T> updated = [];
        final List<T> newState = [];
        s.forEachIndexed((i, e) {
          oldState.add(e);
          if (where(e)) {
            final newItem = set(e);
            updated.add(newItem);
            newState.add(newItem);
          } else {
            newState.add(e);
          }
        });

        if (isOptimistic) {
          yield newState;
        }
        try {
          final r = await _repo.update(
            updated,
            param?.call() ?? injected._param?.call(),
          );
          onCRUD?.call(r);
        } catch (e) {
          if (isOptimistic) {
            yield oldState;
          }
          onError?.call(e);
          rethrow;
        }
        if (!isOptimistic) {
          yield newState;
        }
      },
      onSetState: onStateMutation != null ? On.data(onStateMutation) : null,
    );
  }

  Future<void> delete({
    required bool Function(T item) where,
    P Function()? param,
    void Function()? onStateMutation,
    void Function(dynamic result)? onCRUD,
    void Function(dynamic error)? onError,
    bool isOptimistic = true,
  }) async {
    await injected.setState(
      (s) async* {
        final _repo = await repo;
        final List<T> oldState = [];
        final List<T> removed = [];
        final List<T> newState = [];

        s.forEachIndexed((i, e) {
          oldState.add(e);
          if (where(e)) {
            removed.add(e);
          } else {
            newState.add(e);
          }
        });

        if (isOptimistic) {
          yield newState;
        }
        try {
          final r = await _repo.delete(
            removed,
            param?.call() ?? injected._param?.call(),
          );
          onCRUD?.call(r);
        } catch (e) {
          if (isOptimistic) {
            yield oldState;
          }
          onError?.call(e);
          rethrow;
        }
        if (!isOptimistic) {
          yield newState;
        }
      },
      onSetState: onStateMutation != null ? On.data(onStateMutation) : null,
    );
  }
}

// ///Data class
// class Item {
//   //
// }

// ///Param class
// class Param {
//   final String usrId;
//   final String userToken;
//   final String queryType;
//   //Constructor
//   Parm(...);
// }

// class MyItemsRepository implements ICRUD<Item, Param> {
//   @override
//   Future<List<Item>> read(Param? param) async {
//     final items = await http.get('uri/${param.user.id}');
//     //After parsing
//     return items;

//     //OR
//     // if(param.queryType=='GetCompletedItems'){
//     //    final items = await http.get('uri/${param.user.id}/completed');
//     //    return items;
//     // }else if(param.queryType == 'GetActiveItems'){
//     //   final items = await http.get('uri/${param.user.id}/active');
//     //    return items;
//     // }
//   }
//   @override
//   Future<Item> create(Item item, Param? param) async {
//     final result = await http.post('uri/${param.user.id}/items');
//     return item.copyWith(id: result['id']);
//   }

//   @override
//   Future<dynamic> update(List<Item> items, Param? param) async {
//     //Update items
//     return numberOfUpdatedRows;
//   }
//   @override
//   Future<dynamic> delete(List<Item> items, Param? param) async {
//     //Delete items
//   }

//   @override
//   void dispose() {
//     //Cleaning resources
//   }
// }
