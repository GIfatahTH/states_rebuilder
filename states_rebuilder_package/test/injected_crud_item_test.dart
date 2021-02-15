import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/src/reactive_model.dart';

class Product {
  final int id;
  final String name;
  int count = 0;

  Product({required this.id, required this.name});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Product && o.id == id && o.name == name && o.count == count;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ count.hashCode;

  Product copyWith({
    int? id,
    String? name,
    int? count,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
    )..count = count ?? this.count;
  }

  @override
  String toString() => 'Product(id: $id, name: $name, count: $count)';
}

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
    return _products.map((e) => e.copyWith()).toList();
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
  void dispose() {}

  @override
  Future<void> init() async {
    _products = [
      Product(id: 1, name: 'prod1'),
      Product(id: 2, name: 'prod2'),
      Product(id: 3, name: 'prod3')
    ];
  }
}

final _repo = Repository();
final products = RM.injectCRUD<Product, Object>(
  () => _repo,
  readOnInitialization: true,
);

final widget = MaterialApp(
  home: Scaffold(
    body: On.future(
      onWaiting: () => CircularProgressIndicator(),
      onError: (_, __) => Text('Error'),
      onData: (_, __) => ListView.builder(
        itemCount: products.state.length,
        itemBuilder: (context, index) {
          return products.item.inherited(
            key: Key('${products.state[index].id}'),
            item: () => products.state[index],
            builder: (conext) {
              return const Item();
            },
          );
        },
      ),
    ).listenTo(products),
  ),
  navigatorKey: RM.navigate.navigatorKey,
);

class Item extends StatelessWidget {
  const Item();
  @override
  Widget build(BuildContext context) {
    final product = products.item(context)!;
    return Column(
      children: [
        On.data(
          () => RaisedButton(
            key: Key('RaisedButton: ${product.state.id}'),
            child: Text('${product.state.name}: ${product.state.count}'),
            onPressed: () {
              product.state = product.state.copyWith(
                count: product.state.count + 1,
              );
            },
          ),
        ).listenTo(product),
        RaisedButton(
          key: Key('NavigateTo: ${product.state.id}'),
          child: Text('Navigate to'),
          onPressed: () {
            RM.navigate.to(products.item.reInherited(
              context: context,
              builder: (_) => const NewPage(),
            ));
          },
        ),
      ],
    );
  }
}

class NewPage extends StatelessWidget {
  const NewPage();
  @override
  Widget build(BuildContext context) {
    final product = products.item(context)!;

    return On.data(
      () => RaisedButton(
        key: Key('RaisedButton2: ${product.state.id}'),
        child:
            Text('${products.item.of(context)!.name}: ${product.state.count}'),
        onPressed: () {
          product.state = product.state.copyWith(
            count: product.state.count + 1,
          );
        },
      ),
    ).listenTo(product);
  }
}

void main() {
  setUp(() {
    _repo.error = null;
  });

  testWidgets('initial start', (tester) async {
    await tester.pumpWidget(widget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.byType(Item), findsNWidgets(3));
    expect(find.text('prod1: 0'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
  });

  testWidgets(
      'change the state of an item, should changes the state of the list of items,'
      'and update the store', (tester) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('RaisedButton: 1')));
    await tester.pump();
    expect(find.text('prod1: 1'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
    //
    expect(products.state[0].count, 1);
    expect(_repo._products.first.count, 0);
    final repo = await products.getRepoAs<Repository>();
    expect(repo._products.first.count, 0);

    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.first.count, 1);
    expect(repo._products.first.count, 1);
  });

  testWidgets(
      'change the state of an item, should changes the state of the list of items,'
      'and restor back en error', (tester) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    _repo.error = Exception('Error');
    await tester.tap(find.byKey(Key('RaisedButton: 2')));
    await tester.pump();
    expect(find.text('prod1: 0'), findsOneWidget);
    expect(find.text('prod2: 1'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
    //
    expect(products.state[1].count, 1);
    expect(_repo._products[1].count, 0);
    await tester.pump(Duration(seconds: 1));
    print(find.text('prod2: 0'));
  });

  testWidgets(
      'If list of items is updated, all item are updated even if the'
      'The widget is const', (tester) async {
    await tester.pumpWidget(widget);

    await tester.pumpAndSettle();

    expect(find.text('prod1: 0'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
    //

    products.crud.update(
      where: (p) => p.id == 1,
      set: (p) => p.copyWith(count: 1),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('prod1: 1'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);

    expect(products.state[0].count, 1);
    await tester.pump(Duration(seconds: 1));
  });

  testWidgets('Navigate to an other route, use of reinheited', (tester) async {
    await tester.pumpWidget(widget);

    await tester.pumpAndSettle();

    expect(find.text('prod1: 0'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
    //
    await tester.tap(find.byKey(Key('NavigateTo: 1')));

    await tester.pumpAndSettle();
    expect(find.byType(NewPage), findsOneWidget);
    expect(find.text('prod1: 0'), findsOneWidget);
    expect(find.text('prod2: 0'), findsNothing);
    expect(find.text('prod3: 0'), findsNothing);
    //
    await tester.tap(find.byKey(Key('RaisedButton2: 1')));
    await tester.pump();
    expect(find.text('prod1: 1'), findsOneWidget);
    expect(products.state[0].count, 1);
    expect(_repo._products.first.count, 0);

    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.first.count, 1);

    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Item), findsNWidgets(3));
    expect(find.text('prod1: 1'), findsOneWidget);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
    //
    //
    await tester.tap(find.byKey(Key('NavigateTo: 2')));

    await tester.pumpAndSettle();
    expect(find.byType(NewPage), findsOneWidget);
    expect(find.text('prod1: 0'), findsNothing);
    expect(find.text('prod2: 0'), findsOneWidget);
    expect(find.text('prod3: 0'), findsNothing);

    products.crud.update(
      where: (p) => p.id == 2,
      set: (p) => p.copyWith(count: 1),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('prod2: 1'), findsOneWidget);

    expect(products.state[1].count, 1);
    await tester.pump(Duration(seconds: 1));

    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(Item), findsNWidgets(3));
    expect(find.text('prod1: 1'), findsOneWidget);
    expect(find.text('prod2: 1'), findsOneWidget);
    expect(find.text('prod3: 0'), findsOneWidget);
  });

  testWidgets('refresh with error', (tester) async {
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    //
    products.crud.create(
      Product(id: 4, name: 'product 4'),
    );
    await tester.pump();
    await tester.pump();

    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 4);
    //
    _repo.error = Exception('CRUD error');
    products.crud.read();
    await tester.pump();

    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    _repo.error = null;
    products.refresh();
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 4);
  });

  testWidgets(
    'WHEN middleSnapState is defined'
    'THEN we can control how state is mutated',
    (tester) async {
      SnapState<List<Product>>? _snapState;
      late SnapState<List<Product>> _nextSnapState;
      final products = RM.injectCRUD<Product, Object>(
        () => _repo,
        readOnInitialization: true,
        middleSnapState: (snapState, nextSnapState) {
          _snapState = snapState;
          _nextSnapState = nextSnapState;
          if (_nextSnapState.hasData) {
            return _nextSnapState.copyWith(data: [
              ..._nextSnapState.data!,
              ..._nextSnapState.data!,
            ]);
          }
        },
      );
      expect(products.isWaiting, true);
      expect(_snapState, isNotNull);
      expect(_snapState?.isIdle, true);
      expect(_snapState?.data, null);
      expect(_nextSnapState.isWaiting, true);
      expect(_nextSnapState.data, []);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(_snapState?.isWaiting, true);
      expect(_snapState?.data, []);
      expect(_nextSnapState.hasData, true);
      expect(_nextSnapState.data!.length, 3);
      expect(products.state.length, 6);
    },
  );
}
