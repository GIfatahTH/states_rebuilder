import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/src/reactive_model.dart';

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
  Future update(List<Product> items, Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    for (var item in items) {
      final index = _products.indexWhere((e) => e.id == item.id);
      _products[index] = item;
    }
    return '${items.length} items updated';
  }

  @override
  Future delete(List<Product> items, Object? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    _products.removeWhere((item) => items.contains(item));
    return '${items.length} items deleted';
  }

  @override
  void dispose() {
    disposeMessage = 'isDisposed';
  }

  @override
  Future<void> init() async {}
}

final _repo = Repository();
final products = RM.injectCRUD<Product, Object>(
  () => throw UnimplementedError(),
  readOnInitialization: true,
);

void main() {
  products.injectCRUDMock(() => _repo);
  setUp(() {
    _repo._products = [Product(id: 1, name: 'product 1')];
    _repo.error = null;
    disposeMessage = '';
  });
  testWidgets('CRUD pessimistic without error', (tester) async {
    int numberOfonStateMutationCall = 0;
    dynamic onCRUDMessage;
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      isOptimistic: false,
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    expect(numberOfonStateMutationCall, 0);
    expect(onCRUDMessage, null);

    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 2);
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, isA<Product>());

    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      isOptimistic: false,
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    expect(numberOfonStateMutationCall, 0);
    expect(onCRUDMessage, null);
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));

    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, '1 items updated');

    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    products.crud.delete(
      where: (product) => product.id == 2,
      isOptimistic: false,
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    expect(numberOfonStateMutationCall, 0);
    expect(onCRUDMessage, null);
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, '1 items deleted');
    //
    await tester.pumpWidget(On(() => Container()).listenTo(products));
    expect(disposeMessage, '');
    products.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });

  testWidgets('CRUD pessimistic with error', (tester) async {
    products.injectCRUDMock(() => _repo..error = Exception('CRUD error'));

    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state, []);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      isOptimistic: false,
    );
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 0);
    expect(_repo._products.length, 1);
    products.state = [..._repo._products];

    //
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
  });

  testWidgets('CRUD optimistic without error', (tester) async {
    int numberOfonStateMutationCall = 0;
    dynamic onCRUDMessage;

    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 2);
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, isA<Product>());

    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    await tester.pump();
    expect(products.hasData, true);
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2'));
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, '1 items updated');

    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    products.crud.delete(
      where: (product) => product.id == 2,
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    expect(products.hasData, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 2);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, '1 items deleted');

    //
    await tester.pumpWidget(On(() => Container()).listenTo(products));
    expect(disposeMessage, '');
    products.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });

  testWidgets('CRUD optimistic with error', (tester) async {
    int numberOfonStateMutationCall = 0;
    dynamic onCRUDMessage;
    dynamic errorMessage;
    _repo.error = Exception('CRUD error');
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state, []);
    products.state = [..._repo._products];
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
      onError: (_) => errorMessage = _.message,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 2);
    expect(onCRUDMessage, null);
    expect(errorMessage, 'CRUD error');

    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    errorMessage = null;
    products.crud.update(
      where: (product) => product.id == 1,
      set: (product) => product.copyWith(name: 'product 1_new'),
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
      onError: (_) => errorMessage = _.message,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state[0], Product(id: 1, name: 'product 1_new'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state[0], Product(id: 1, name: 'product 1'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    expect(numberOfonStateMutationCall, 2);
    expect(onCRUDMessage, null);
    expect(errorMessage, 'CRUD error');
    //
    numberOfonStateMutationCall = 0;
    onCRUDMessage = null;
    errorMessage = null;
    products.crud.delete(
      where: (product) => product.id == 1,
      onStateMutation: () => numberOfonStateMutationCall++,
      onCRUD: (_) => onCRUDMessage = _,
      onError: (_) => errorMessage = _.message,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onCRUDMessage, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state.length, 0);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 2);
    expect(onCRUDMessage, null);
    expect(errorMessage, 'CRUD error');
    await tester.pumpWidget(On(() => Container()).listenTo(products));
  });
}
