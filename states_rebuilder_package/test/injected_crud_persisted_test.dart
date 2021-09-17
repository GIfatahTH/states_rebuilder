import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/* ----------------------------- Injected State ----------------------------- */
final testOrderCRUD = RM.injectCRUD<Order?, String>(
  () => OrderRepository(),
  readOnInitialization: true,
  persist: () => PersistState(
    key: '__Order__',
    toJson: (List<Order?> orders) {
      final mappedOrders = (orders).map((o) => o?.toMap()).toList();
      return jsonEncode(mappedOrders);
    },
    fromJson: (json) {
      return (jsonDecode(json) as List)
          .map((mappedOrder) => Order.fromMap(mappedOrder))
          .toList();
    },
  ),
);

main() async {
  final store = await RM.storageInitializerMock();
  setUp(
    () {
      store.clear();
      testOrderCRUD.dispose();
    },
  );

  testWidgets(
    'WHEN when no cached order and app starts'
    'THEN the app fetches for items from the repo ',
    (tester) async {
      expect(testOrderCRUD.isWaiting, true);
      await tester.pump(const Duration(seconds: 1));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
      testOrderCRUD.deletePersistState();
      print(store);
    },
  );
  testWidgets(
    'WHEN there is one order cached'
    'THEN it get in on app start without fetching from the repo'
    'WHEN refresh is called'
    'THEN it trigger repo fetch',
    (tester) async {
      store.store = {
        '__Order__': '[{"id":"id-0","orderName":"Order No.#0"}]',
      };
      expect(testOrderCRUD.isWaiting, true);
      await tester.pump();
      expect(testOrderCRUD.hasData, true);
      testOrderCRUD.refresh();
      expect(testOrderCRUD.isWaiting, true);
      await tester.pump(const Duration(seconds: 1));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.state.length, 5);
    },
  );

  testWidgets(
    'WHEN there is one order cached'
    'AND WHEN the shouldRecreateTheState is true'
    'THEN it get in on app start and fetch in the repo in the background',
    (tester) async {
      final testOrderCRUD = RM.injectCRUD<Order?, String>(
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
                .map((mappedOrder) => Order.fromMap(mappedOrder))
                .toList();
          },
        ),
      );

      store.store = {
        '__Order__': '[{"id":"id-0","orderName":"Order No.#0"}]',
      };
      expect(testOrderCRUD.isWaiting, false);
      await tester.pump();
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.isOnCRUD, true);

      await tester.pump(const Duration(seconds: 1));
      expect(testOrderCRUD.hasData, true);
      expect(testOrderCRUD.isOnCRUD, false);
      expect(testOrderCRUD.state.length, 5);
    },
  );
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
