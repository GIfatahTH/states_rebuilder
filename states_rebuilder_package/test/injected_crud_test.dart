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
}

class Repository implements ICRUD<Product> {
  final List<Product> _products = [Product(id: 1, name: 'product 1')];
  @override
  Future<Product> create(Product item) async {
    await Future.delayed(Duration(seconds: 1));
    _products.add(item);
    return item;
  }

  @override
  Future<List<Product>> read() async {
    await Future.delayed(Duration(seconds: 1));
    return _products;
  }

  @override
  Future<bool> update(Product item) async {
    await Future.delayed(Duration(seconds: 1));
    final index = _products.indexWhere((e) => e.id == item.id);
    _products[index] = item;
    return true;
  }

  @override
  Future<bool> delete(Product item) async {
    await Future.delayed(Duration(seconds: 1));
    _products.add(item);
    return true;
  }
}

final _repo = Repository();
final products = RM.injectCRUD<Product>(
  () => _repo,
);

void main() {
  testWidgets('description', (tester) async {
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
    expect(_repo._products.length, 2);
  });
}
