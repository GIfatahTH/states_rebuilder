part of '../../reactive_model.dart';

abstract class ICRUD<T, P> {
  Future<T> create(T item);
  Future<List<T>> read([P? param]);
  Future<bool> update(T item);
  Future<bool> delete(T item);
}

class _CRUDService<T, P> {
  final ICRUD<T, P> repo;
  final Injected<List<T>> injected;
  final Object Function(T item) identifier;
  _CRUDService(this.repo, this.identifier, this.injected);
  //
  Future<List<T>> read([P? param]) async {
    late List<T> items;
    // await injected.setState(
    //   (s) async => items =,
    // );
    items = await repo.read(param);
    print(items);
    return items;
  }

  //return null means an error
  Future<T?> create(T item, {bool isOptimistic = true}) async {
    T? addedItem;
    await injected.setState(
      (s) async* {
        if (isOptimistic) {
          s.add(item);
          yield item;
        }
        try {
          addedItem = await repo.create(item);
        } catch (e) {
          if (isOptimistic) {
            s.remove(item);
          }
          rethrow;
        }
        if (!isOptimistic) {
          s.add(addedItem!);
          yield item;
        }
      },
      skipWaiting: isOptimistic,
    );
    return addedItem;
  }

  Future<bool> update(T item, {bool isOptimistic = true}) async {
    bool isUpdated = false;
    await injected.setState((s) async* {
      final index = s.indexWhere((e) => identifier(e) == identifier(item));
      if (index == -1) {
        throw Exception('Can not update List<$T>.\nItem not found');
      }
      final oldItem = s[index];
      if (isOptimistic) {
        s[index] = item;
        yield true;
      }
      try {
        isUpdated = await repo.update(item);
      } catch (e) {
        if (isOptimistic) {
          s[index] = oldItem;
        }
        rethrow;
      }
      if (!isOptimistic) {
        s[index] = item;
        yield true;
      }
    });
    return isUpdated;
  }

  Future<bool> delete(T item, {bool isOptimistic = true}) async {
    bool isDeleted = false;
    await injected.setState((s) async* {
      final index = s.indexWhere((e) => identifier(e) == identifier(item));
      if (index == -1) {
        throw Exception('Can not update List<$T>.\nItem not found');
      }
      final oldItem = s[index];
      if (isOptimistic) {
        s.removeAt(index);
        yield true;
      }
      try {
        isDeleted = await repo.delete(item);
      } catch (e) {
        if (isOptimistic) {
          s.insert(index, oldItem);
        }
        rethrow;
      }
      if (!isOptimistic) {
        s.removeAt(index);
        yield true;
      }
    });
    return isDeleted;
  }
}
