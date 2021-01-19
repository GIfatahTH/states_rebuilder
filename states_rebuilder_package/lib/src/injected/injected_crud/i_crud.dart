part of '../../reactive_model.dart';

abstract class ICRUD<T> {
  Future<T> create(T item);
  Future<List<T>> read();
  Future<bool> update(T item);
  Future<bool> delete(T item);
}

class _CRUDService<T> {
  final ICRUD<T> repo;
  final Injected<List<T>> injected;
  _CRUDService(this.repo, this.injected);

  Future<T> create(T item, {bool isOptimistic = true}) async {
    late T addedItem;
    await injected.setState((s) async* {
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
        s.add(addedItem);
        yield item;
      }
    });
    return addedItem;
  }

  Future<bool> update(T item) {
    return repo.update(item);
  }

  Future<bool> delete(T item) {
    return repo.delete(item);
  }
}
