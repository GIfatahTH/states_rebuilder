import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/* ----------------------------- Injected State ----------------------------- */
late InjectedCRUD<Order?, String> testOrderCRUD = RM.injectCRUD<Order?, String>(
  () => OrderRepository(),
  readOnInitialization: true, // NOTE Must add this line.
  persist: () => PersistState(
    key: '__Order__',
    // shouldRecreateTheState: true,
    toJson: (List<Order?> orders) {
      final mappedOrders = (orders).map((o) => o?.toMap()).toList();
      return jsonEncode(mappedOrders);
    },
    fromJson: (json) {
      return (jsonDecode(json) as List)
          .map(
            (mappedOrder) => Order.fromJson(mappedOrder),
          )
          .toList();
    },
  ),
);

bool isOnReactiveUsed = true;
main() async {
  final store = await RM.storageInitializerMock();
  setUp(
    () {
      store.clear();
    },
  );

  testWidgets(
    'WHEN when no cached order and app starts'
    'THEN the app fetches for items from the repo '
    'Case OnReactive is used',
    (tester) async {
      isOnReactiveUsed = true;
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(5));
    },
  );
  testWidgets(
    'WHEN there is one order cached'
    'THEN it get in on app start without fetching from the repo'
    'WHEN refresh is called'
    'THEN it trigger repo fetch'
    'Case OnReactive is used',
    (tester) async {
      isOnReactiveUsed = true;
      store.store = {
        '__Order__': jsonEncode(
          [Order(id: 'id-cached', orderName: 'Order No.#cached').toJson()],
        )
      };

      await tester.pumpWidget(const MyApp());
      await tester.pump(); //The first frame
      expect(find.byType(ListTile), findsOneWidget);
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 1);
      //
      testOrderCRUD.refresh();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(testOrderCRUD.isWaiting, true);
      //
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
    },
  );

  //
  //
  testWidgets(
    'WHEN when no cached order and app starts'
    'THEN the app fetches for items from the repo '
    'Case OnCRUDBuilder is used',
    (tester) async {
      isOnReactiveUsed = false;
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(5));
    },
  );
  testWidgets(
    'WHEN there is one order cached'
    'THEN it get in on app start without fetching from the repo'
    'WHEN refresh is called'
    'THEN it trigger repo fetch'
    'Case OnCRUDBuilder is used',
    (tester) async {
      isOnReactiveUsed = false;
      store.store = {
        '__Order__': jsonEncode(
          [Order(id: 'id-cached', orderName: 'Order No.#cached').toJson()],
        )
      };

      await tester.pumpWidget(const MyApp());
      await tester.pump(); //The first frame
      expect(find.byType(ListTile), findsOneWidget);
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 1);
      //
      testOrderCRUD.refresh();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(testOrderCRUD.isWaiting, true);
      //
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
    },
  );
  testWidgets(
    'WHEN there is one order cached'
    'AND WHEN the shouldRecreateTheState is true'
    'THEN it get in on app start and fetch in the repo in the background'
    'Case OnReactive is used',
    (tester) async {
      isOnReactiveUsed = true;
      testOrderCRUD = RM.injectCRUD<Order?, String>(
        () => OrderRepository(),
        readOnInitialization: true,
        persist: () => PersistState(
          key: '__Order__',
          shouldRecreateTheState: true,
          toJson: (List<Order?> orders) {
            final mappedOrders = (orders).map((o) => o?.toMap()).toList();
            return jsonEncode(mappedOrders);
          },
          fromJson: (json) {
            return (jsonDecode(json) as List)
                .map(
                  (mappedOrder) => Order.fromJson(mappedOrder),
                )
                .toList();
          },
        ),
      );
      store.store = {
        '__Order__': jsonEncode(
          [Order(id: 'id-cached', orderName: 'Order No.#cached').toJson()],
        )
      };
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 1);
      //It is waiting for fetch under the hood
      expect(testOrderCRUD.isOnCRUD, true);
      //
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
    },
  );
  testWidgets(
    'WHEN there is one order cached'
    'AND WHEN the shouldRecreateTheState is true'
    'THEN it get in on app start and fetch in the repo in the background'
    'Case OnCRUDBuilder is used',
    (tester) async {
      isOnReactiveUsed = false;
      testOrderCRUD = RM.injectCRUD<Order?, String>(
        () => OrderRepository(),
        readOnInitialization: true,
        persist: () => PersistState(
          key: '__Order__',
          shouldRecreateTheState: true,
          toJson: (List<Order?> orders) {
            final mappedOrders = (orders).map((o) => o?.toMap()).toList();
            return jsonEncode(mappedOrders);
          },
          fromJson: (json) {
            return (jsonDecode(json) as List)
                .map(
                  (mappedOrder) => Order.fromJson(mappedOrder),
                )
                .toList();
          },
        ),
      );
      store.store = {
        '__Order__': jsonEncode(
          [Order(id: 'id-cached', orderName: 'Order No.#cached').toJson()],
        )
      };
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 1);
      //It is waiting for fetch under the hood
      expect(testOrderCRUD.isOnCRUD, true);
      //
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ListTile), findsNWidgets(5));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
    },
  );
  testWidgets(
    'Test when testOrderCRUD is mocked with simple injected',
    (tester) async {
      isOnReactiveUsed = false;
      testOrderCRUD.injectMock(() => [Order(id: 'id', orderName: 'orderName')]);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 1);
      expect(find.byType(ListTile), findsNWidgets(1));
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Flutter Demo CRUD Persistence'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    // Fetch data from CRUD (Online)
                    await testOrderCRUD.crud.read();
                  },
                  child: const Text('Fetch Online Data ')),
              ElevatedButton(
                  onPressed: () {
                    // Refresh the state, then it'll auto-query back the cache data from localDB
                    testOrderCRUD.refresh();
                  },
                  child: const Text('Refresh & Query from LocalDB')),
              ElevatedButton(
                  onPressed: () {
                    // Delete the cache from localDB
                    testOrderCRUD.deletePersistState();
                  },
                  child: const Text('Delete Cache')),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: isOnReactiveUsed
                    ? OnReactive(
                        () {
                          if (testOrderCRUD.isWaiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return Column(
                            children: testOrderCRUD.state
                                .map((order) => ListTile(
                                    title: Text(order?.id ?? 'NO ID'),
                                    subtitle:
                                        Text(order?.orderName ?? 'NO NAME')))
                                .toList(),
                          );
                        },
                      )
                    : OnCRUDBuilder(
                        listenTo: testOrderCRUD,
                        onWaiting: () =>
                            const Center(child: CircularProgressIndicator()),
                        onResult: (_) {
                          final List<ListTile> listOfResult = testOrderCRUD
                              .state
                              .map((order) => ListTile(
                                  title: Text(order?.id ?? 'NO ID'),
                                  subtitle:
                                      Text(order?.orderName ?? 'NO NAME')))
                              .toList();
                          return Column(children: listOfResult);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Order {
  String id;
  String orderName;
  Order({
    required this.id,
    required this.orderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderName': orderName,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      orderName: map['orderName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  String toString() => 'Order(id: $id, orderName: $orderName)';
}

/* ------------------------ Repository With CRUD API ------------------------ */
class OrderRepository implements ICRUD<Order, String> {
  @override
  Future<List<Order>> read(String? param) async {
    await Future.delayed(const Duration(seconds: 1)); // Fake latency
    final fakeOrders = List.generate(
        5,
        (index) => Order(
            id: 'id-$index',
            orderName: 'Order No.#$index')); // Generated fake orders

    return fakeOrders;
  }

  @override
  Future<Order> create(item, param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List items, param) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  Future<void> init() async {}

  @override
  Future update(List items, param) {
    throw UnimplementedError();
  }
}
