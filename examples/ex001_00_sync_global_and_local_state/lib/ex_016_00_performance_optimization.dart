import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* This is a show case on how to limit the rebuild to the widget really need to
* update its view.
*
* The example is inspired from provider_shopper in flutter examples repo
*/

@immutable
class CartModel {
  final List<String> items;
  CartModel({
    required this.items,
  });

  final _selectedItems = RM.inject<List<int>>(() => []);

  List<Item> get selectedItems =>
      _selectedItems.state.map((id) => items.getById(id)).toList();

  void add(Item item) {
    _selectedItems.state = [..._selectedItems.state, item.id];
  }

  void remove(Item item) {
    _selectedItems.state =
        _selectedItems.state.where((e) => e != item.id).toList();
  }
}

final cartModel = CartModel(items: itemNames);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyCatalog(),
    );
  }
}

class MyCatalog extends StatelessWidget {
  const MyCatalog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _MyAppBar(),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _MyListItem(index),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog', style: Theme.of(context).textTheme.headline4),
      floating: true,
    );
  }
}

// Used for test
final rebuiltItems = [];

// For the sake of this example we make this widget ReactiveStatelessWidget.
class _MyListItem extends ReactiveStatelessWidget {
  final int index;

  const _MyListItem(this.index, {Key? key}) : super(key: key);
  // OnReactive and OnBuilder both have shouldRebuild parameter
  @override
  bool shouldRebuildWidget(SnapState oldSnap, SnapState currentSnap) {
    // Check that the nonfiction is emitted from _selectedItems state
    if (currentSnap.type() == List<int>) {
      final oldItems = oldSnap.state as List<int>;
      final currentItems = currentSnap.state as List<int>;
      if (oldItems.contains(index) != currentItems.contains(index)) {
        // Rebuild the widget only in two cases:
        // 1- The item was in the old list and it is removed from the new list.
        // 2- The item wasn't in the old list ant it is added to the new list.
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var item = itemNames.getById(index);
    var textTheme = Theme.of(context).textTheme.headline6;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.primaries[
                    Random().nextInt(Colors.primaries.length) %
                        Colors.primaries.length],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(item.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            _AddButton(item: item),
          ],
        ),
      ),
    );
  }
}

// For better optimization, this widget can be ReactiveStatelessWidget
//
class _AddButton extends StatelessWidget {
  final Item item;

  const _AddButton({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Used for to test rebuild items
    rebuiltItems.add(item.id);
    print('rebuilding ${item.id}');
    late final isInCart = cartModel.selectedItems.contains(item);
    return TextButton(
      onPressed: isInCart
          ? () {
              cartModel.remove(item);
            }
          : () {
              cartModel.add(item);
            },
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}

extension on List<String> {
  Item getById(int id) => Item(id, this[id % length]);
}

List<String> itemNames = [
  'Code Smell',
  'Control Flow',
  'Interpreter',
  'Recursion',
  'Sprint',
  'Heisenbug',
  'Spaghetti',
  'Hydra Code',
  'Off-By-One',
  'Scope',
  'Callback',
  'Closure',
  'Automata',
  'Bit Shift',
  'Currying',
];

@immutable
class Item {
  final int id;
  final String name;
  final int price = 42;

  Item(this.id, this.name);

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Item && other.id == id;
}
