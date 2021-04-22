import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Product {
  final int id;
  final String name;

  Product({required this.id, required this.name});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Product && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  Product copyWith({
    int? id,
    String? name,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

String disposeMessage = '';

class Repository implements ICRUD<Product, Object> {
  List<Product> _products = [];
  dynamic error;
  @override
  Future<Product> create(Product item, Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    _products.add(item);
    return item;
  }

  @override
  Future<List<Product>> read(Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    return _products;
  }

  @override
  Future<void> update(List<Product> items, Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    for (var item in items) {
      final index = _products.indexWhere((e) => e.id == item.id);
      _products[index] = item;
    }
  }

  @override
  Future<void> delete(List<Product> items, Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    _products.removeWhere((item) => items.contains(item));
  }

  void dispose() {
    disposeMessage = "isDisposed";
  }

  @override
  Future<void> init() async {}
}

final _repo = Repository();
final products = RM.injectCRUD<Product, Object>(
  () => _repo,
  readOnInitialization: true,
);

void main() {
  setUp(() {
    _repo._products = [Product(id: 1, name: 'product 1')];
    _repo.error = null;
    disposeMessage = '';
  });
  testWidgets('CRUD pessimistic without error', (tester) async {
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 2);
    // //
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));
    //
    products.crud.delete(
      where: (product) => product.id == 2,
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);

    await tester.pumpWidget(On(() => Container()).listenTo(products));
    products.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });

  testWidgets('CRUD pessimistic with error', (tester) async {
    _repo.error = Exception('CRUD error');
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state, []);
    //
    products.crud.create(
      Product(id: 1, name: 'product 1'),
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 0);
    expect(_repo._products.length, 1);
    //
    _repo.error = null;
    products.crud.read();
    await tester.pump(Duration(seconds: 1));
    _repo.error = Exception('CRUD error');

    products.crud.update(
      where: (product) => product.id == 1,
      set: (product) => product.copyWith(name: 'product 2_new'),
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    //
    products.crud.delete(
      where: (product) => product.id == 1,
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    await tester.pumpWidget(On(() => Container()).listenTo(products));
    expect(disposeMessage, '');
    products.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });

  testWidgets('CRUD optimistic without error', (tester) async {
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 2);

    //
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2'));
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));

    //
    products.crud.delete(
      where: (product) => product.id == 2,
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 2);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 1);
    await tester.pumpWidget(On(() => Container()).listenTo(products));
  });

  testWidgets('CRUD optimistic with error', (tester) async {
    _repo.error = Exception('CRUD error');
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state, []);
    products.state = [..._repo._products];
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);

    //
    products.crud.update(
      where: (product) => product.id == 1,
      set: (product) => product.copyWith(name: 'product 1_new'),
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state[0], Product(id: 1, name: 'product 1_new'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state[0], Product(id: 1, name: 'product 1'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    //
    products.crud.delete(
      where: (product) => product.id == 1,
    );
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state.length, 0);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    await tester.pumpWidget(On(() => Container()).listenTo(products));
  });
  testWidgets('Start with empty list if not read on initialized',
      (tester) async {
    final crud = RM.injectCRUD(() => Repository());
    expect(crud.state.isEmpty, true);
  });
}
