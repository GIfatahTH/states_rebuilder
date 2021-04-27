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
  Future<void> init() async {
    _products = [Product(id: 1, name: 'product 1')];
  }
}

final _repo = Repository();
String onCRUDMessage = '';
final products = RM.injectCRUD<Product, Object>(
  () => throw UnimplementedError(),
  readOnInitialization: true,
  onCRUD: On.crud(
    onWaiting: () {
      onCRUDMessage = 'Waiting...';
    },
    onError: (_, __) {
      onCRUDMessage = _.message;
    },
    onResult: (r) {
      onCRUDMessage = 'Result: $r';
    },
  ),
  debugPrintWhenNotifiedPreMessage: '',
);

void main() {
  setUp(() {
    products.injectCRUDMock(() => _repo);
    _repo.error = null;
    disposeMessage = '';
    onCRUDMessage = '';
  });
  testWidgets('CRUD pessimistic without error', (tester) async {
    int numberOfonStateMutationCall = 0;
    dynamic onResultMessage;
    expect(products.isWaiting, true);
    await tester.pump();
    expect(onCRUDMessage, 'Waiting...');
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(onCRUDMessage, 'Result: null');
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    onCRUDMessage = '';
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      isOptimistic: false,
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResultMessage = _,
    );
    expect(numberOfonStateMutationCall, 0);
    expect(onResultMessage, null);
    await tester.pump();
    expect(products.isWaiting, true);
    expect(onCRUDMessage, 'Waiting...');
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(onCRUDMessage, 'Result: null');
    expect(products.state.length, 2);
    expect(_repo._products.length, 2);
    expect(numberOfonStateMutationCall, 1);
    expect(onResultMessage, isA<Product>());

    //
    onCRUDMessage = '';
    numberOfonStateMutationCall = 0;
    onResultMessage = null;
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      isOptimistic: false,
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResultMessage = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 0);
    expect(onResultMessage, null);
    expect(products.isWaiting, true);
    expect(onCRUDMessage, 'Waiting...');
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(onCRUDMessage, 'Result: 1 items updated');
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));

    expect(numberOfonStateMutationCall, 1);
    expect(onResultMessage, '1 items updated');

    //
    onCRUDMessage = '';
    numberOfonStateMutationCall = 0;
    onResultMessage = null;
    products.crud.delete(
      where: (product) => product.id == 2,
      isOptimistic: false,
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResultMessage = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 0);
    expect(onResultMessage, null);
    expect(products.isWaiting, true);
    expect(onCRUDMessage, 'Waiting...');
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(onCRUDMessage, 'Result: 1 items deleted');
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 1);
    expect(onResultMessage, '1 items deleted');
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
    dynamic onResult;

    expect(products.isWaiting, true);
    await tester.pump();
    expect(onCRUDMessage, 'Waiting...');
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(onCRUDMessage, 'Result: null');
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    onCRUDMessage = '';
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(onCRUDMessage, 'Waiting...');

    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    await tester.pump();

    expect(onCRUDMessage, 'Waiting...');

    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 2);
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, isA<Product>());
    expect(onCRUDMessage, 'Result: null');
    //
    onCRUDMessage = '';
    numberOfonStateMutationCall = 0;
    onResult = null;
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(onCRUDMessage, 'Waiting...');
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    await tester.pump();
    expect(onCRUDMessage, 'Waiting...');
    expect(products.hasData, true);
    expect(products.state[1], Product(id: 2, name: 'product 2_new'));
    expect(_repo._products[1], Product(id: 2, name: 'product 2'));
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products[1], Product(id: 2, name: 'product 2_new'));
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, '1 items updated');
    expect(onCRUDMessage, 'Result: 1 items updated');

    //
    numberOfonStateMutationCall = 0;
    onResult = null;
    products.crud.delete(
      where: (product) => product.id == 2,
      onSetState: On.data(() => numberOfonStateMutationCall++),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    expect(products.hasData, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 2);
    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, '1 items deleted');
    expect(onCRUDMessage, 'Result: 1 items deleted');

    //
    await tester.pumpWidget(On(() => Container()).listenTo(products));
    expect(disposeMessage, '');
    products.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });

  testWidgets('CRUD optimistic with error', (tester) async {
    int numberOfonStateMutationCall = 0;
    dynamic onResult;
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
      onSetState: On.or(
          onError: (_, __) => errorMessage = _.message,
          onData: () => numberOfonStateMutationCall++,
          or: () {}),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state.length, 2);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 2);
    expect(onResult, null);
    expect(errorMessage, 'CRUD error');

    //
    numberOfonStateMutationCall = 0;
    onResult = null;
    errorMessage = null;
    products.crud.update(
      where: (product) => product.id == 1,
      set: (product) => product.copyWith(name: 'product 1_new'),
      onSetState: On.or(
        onError: (_, __) => errorMessage = _.message,
        onData: () => numberOfonStateMutationCall++,
        or: () {},
      ),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state[0], Product(id: 1, name: 'product 1_new'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state[0], Product(id: 1, name: 'product 1'));
    expect(_repo._products[0], Product(id: 1, name: 'product 1'));
    expect(numberOfonStateMutationCall, 2);
    expect(onResult, null);
    expect(errorMessage, 'CRUD error');
    //
    numberOfonStateMutationCall = 0;
    onResult = null;
    errorMessage = null;
    products.crud.delete(
      where: (product) => product.id == 1,
      onSetState: On.or(
        onError: (err, _) => errorMessage = err.message,
        onData: () => numberOfonStateMutationCall++,
        or: () {},
      ),
      onResult: (_) => onResult = _,
    );
    await tester.pump();
    expect(numberOfonStateMutationCall, 1);
    expect(onResult, null);
    expect(errorMessage, null);
    expect(products.hasData, true);
    expect(products.state.length, 0);
    expect(_repo._products.length, 1);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasError, true);
    expect(products.state.length, 1);
    expect(_repo._products.length, 1);
    expect(numberOfonStateMutationCall, 2);
    expect(onResult, null);
    expect(errorMessage, 'CRUD error');
    await tester.pumpWidget(On(() => Container()).listenTo(products));
  });

  testWidgets('On.crud Peissimisally', (tester) async {
    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On.crud(
        onWaiting: () => Text('Waiting...'),
        onError: (_, __) => Text(_.message),
        onResult: (r) => Text('Result: $r'),
      ).listenTo(products),
    );

    ///READ
    await tester.pumpWidget(widget);
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);

    expect(find.text('Result: null'), findsOneWidget);
    //CREATE Peissimisally
    products.crud.create(
      Product(id: 2, name: 'product 2'),
      isOptimistic: false,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);
    //UPDATA
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
      isOptimistic: false,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items updated'), findsOneWidget);
    //DELETE
    products.crud.delete(
      where: (product) => product.id == 2,
      isOptimistic: false,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items deleted'), findsOneWidget);
  });

  testWidgets('On.crud Optimistically', (tester) async {
    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On.crud(
        onWaiting: () => Text('Waiting...'),
        onError: (_, __) => Text(_.message),
        onResult: (r) => Text('Result: $r'),
      ).listenTo(products),
    );

    ///READ
    await tester.pumpWidget(widget);
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);

    expect(find.text('Result: null'), findsOneWidget);
    //CREATE Peissimisally
    products.crud.create(
      Product(id: 2, name: 'product 2'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);
    //UPDATA
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items updated'), findsOneWidget);
    //DELETE
    products.crud.delete(
      where: (product) => product.id == 2,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items deleted'), findsOneWidget);
  });

  testWidgets('On.crud vs On.all Optimistically', (tester) async {
    int numberOfOnDataRebuild = 0;
    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          On.crud(
            onWaiting: () => Text('CRUD Waiting...'),
            onError: (_, __) => Text('CRUD' + _.message),
            onResult: (r) => Text('Result: $r'),
          ).listenTo(products),
          On.all(
            onIdle: () => Text('Idel'),
            onWaiting: () => Text('OnAll Waiting...'),
            onError: (_, __) => Text('OnAll ' + _.message),
            onData: () {
              numberOfOnDataRebuild++;
              return Text('onData');
            },
          ).listenTo(products),
        ],
      ),
    );

    ///READ
    await tester.pumpWidget(widget);
    expect(find.text('CRUD Waiting...'), findsOneWidget);
    expect(find.text('OnAll Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 1);

    //CREATE Peissimisally
    products.crud.create(
      Product(id: 2, name: 'product 2'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('CRUD Waiting...'), findsOneWidget);
    expect(find.text('OnAll Waiting...'), findsNothing);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 2);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: null'), findsOneWidget);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 2);

    //UPDATA
    products.crud.update(
      where: (product) => product.id == 2,
      set: (product) => product.copyWith(name: 'product 2_new'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('CRUD Waiting...'), findsOneWidget);
    expect(find.text('OnAll Waiting...'), findsNothing);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 3);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items updated'), findsOneWidget);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 3);
    //DELETE
    products.crud.delete(
      where: (product) => product.id == 2,
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('CRUD Waiting...'), findsOneWidget);
    expect(find.text('OnAll Waiting...'), findsNothing);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 4);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Result: 1 items deleted'), findsOneWidget);
    expect(find.text('onData'), findsOneWidget);
    expect(numberOfOnDataRebuild, 4);
  });

  testWidgets('refresh with error', (tester) async {
    expect(products.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(products.hasData, true);
    expect(products.state, [Product(id: 1, name: 'product 1')]);
    //
    products.crud.create(
      Product(id: 2, name: 'product 2'),
    );
    await tester.pump();
    await tester.pump();

    await tester.pump(Duration(seconds: 1));
    expect(_repo._products.length, 2);
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
    expect(_repo._products.length, 2);
  });

  testWidgets(
    'When On.crud hasError'
    'Refresh it',
    (tester) async {
      late void Function() refresher;
      final widget = Directionality(
        textDirection: TextDirection.rtl,
        child: On.crud(
          onWaiting: () => Text('Waiting...'),
          onError: (_, refresh) {
            refresher = refresh;
            return Text(_.message);
          },
          onResult: (r) => Text('Result: $r'),
        ).listenTo(
          products,
          debugPrintWhenRebuild: '',
        ),
      );

      ///READ
      _repo.error = Exception('Read Error');
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Read Error'), findsOneWidget);
      _repo.error = null;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Result: null'), findsOneWidget);

      //CREATE Peissimisally
      _repo.error = Exception('Create Error');

      products.crud.create(
        Product(id: 2, name: 'product 2'),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Create Error'), findsOneWidget);
      _repo.error = null;
      refresher();
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Result: null'), findsOneWidget);
      //UPDATA
      _repo.error = Exception('Update Error');

      products.crud.update(
        where: (product) => product.id == 2,
        set: (product) => product.copyWith(name: 'product 2_new'),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Update Error'), findsOneWidget);
      _repo.error = null;
      refresher();
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Result: 1 items updated'), findsOneWidget);
      //DELETE
      _repo.error = Exception('Delete Error');

      products.crud.delete(
        where: (product) => product.id == 2,
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Delete Error'), findsOneWidget);
      _repo.error = null;
      refresher();
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Result: 1 items deleted'), findsOneWidget);
    },
  );
}
