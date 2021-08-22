//
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'number.dart';
import 'numbers_repository.dart';

//Used to make it testable
extension DateTimeX on DateTime {
  static int? secondFake;
  int get secondX {
    return secondFake ?? second;
  }
}

final numbers = RM.injectCRUD<Number, NumberParam>(
  () => NumbersRepository(),
  param: () => NumberParam(userId: '1', numType: NumType.all),
  readOnInitialization: true,
  debugPrintWhenNotifiedPreMessage: '',
  onCRUD: OnCRUD(
    onWaiting: null,
    onError: (err, refresh) {
      RM.scaffold.showSnackBar(
        SnackBar(
          content: OutlinedButton.icon(
            key: Key('Icons.refresh'),
            onPressed: refresh,
            icon: Icon(Icons.refresh),
            label: Text('$err'),
          ),
        ),
      );
    },
    onResult: (_) => count.refresh(),
  ),
);

final Injected<List<int>> count = RM.injectFuture<List<int>>(
  () async {
    final repo = numbers.getRepoAs<NumbersRepository>();
    final all = repo.count(NumberParam(userId: '1', numType: NumType.all));
    final odd = repo.count(NumberParam(userId: '1', numType: NumType.odd));
    final even = repo.count(NumberParam(userId: '1', numType: NumType.even));
    final l = [await all, await odd, await even];
    return l;
  },
  initialState: [0, 0, 0],
  debugPrintWhenNotifiedPreMessage: 'count',
);

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: _appBarMethod(), //read items
        body: _bodyMethod(), //listen, update and delete items
        floatingActionButton: buildFloatingActionMethod(), //add items
      ),
    );
  }

  FloatingActionButton buildFloatingActionMethod() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => numbers.crud.create(
        Number(
          number: DateTime.now().secondX,
        ),
        isOptimistic: false,
      ),
    );
  }

  AppBar _appBarMethod() {
    return AppBar(
      title: Text('InjectCRUD'),
      leading: OnCRUDBuilder(
        listenTo: numbers,
        onWaiting: () => Icon(Icons.circle, color: Colors.yellow),
        onError: (_, retry) => IconButton(
          icon: Icon(Icons.refresh_outlined, color: Colors.red),
          onPressed: () => retry(),
        ),
        onResult: (_) => Icon(Icons.check, color: Colors.green),
      ),
      actions: [
        ElevatedButton(
          child: Text('Even'),
          onPressed: () => numbers.crud.read(
            param: (param) => param!.copyWith(numType: NumType.even),
          ),
        ),
        ElevatedButton(
          child: Text('Odd'),
          onPressed: () => numbers.crud.read(
            param: (param) => param!.copyWith(numType: NumType.odd),
          ),
        ),
        ElevatedButton(
          child: Text('All'),
          onPressed: () => numbers.crud.read(
            param: (param) => param!.copyWith(numType: NumType.all),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size(20, 20),
        child: OnReactive(
          () => Row(
            children: [
              //counts are read from database
              Text('All: ${count.state[0]}    '),
              Text('Odd: ${count.state[1]}    '),
              Text('Even: ${count.state[2]}    '),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bodyMethod() {
    return OnReactive(
      () => numbers.onOrElse(
        onWaiting: numbers.state.isEmpty
            ? () => Center(child: CircularProgressIndicator())
            : null,
        // onError: (err, refresh) => Center(
        //   child: RaisedButton(
        //     child: Text('Refresh'),
        //     onPressed: () => refresh(),
        //   ),
        // ),
        orElse: (_) => ListView.builder(
          itemCount: numbers.state.length + 1,
          itemBuilder: (context, index) {
            if (index >= numbers.state.length) {
              return OnReactive(
                () => numbers.onOrElse(
                  onWaiting: () => Center(child: CircularProgressIndicator()),
                  orElse: (_) => SizedBox.shrink(),
                ),
              );
            }
            return numbers.item.inherited(
              key: Key('${numbers.state[index].id}'),
              item: () => numbers.state[index],
              builder: (context) => const ItemWidget(),
            );
          },
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget();
  @override
  Widget build(BuildContext context) {
    final item = numbers.item(context)!;
    return ListTile(
      title: OnReactive(() => Text('Number ${item.state.number}')),
      leading: const ChildItemWidget(),
      trailing: IconButton(
        icon: Icon(Icons.update),

        // updating the list of numbers ==> update the ItemWidget even if const
        /*
        onPressed: () => numbers.crud.update(
          where: (e) => e.id == item.state.id,
          set: (e) => e.copyWith(number: e.number + 1),
        ),
        */

        // updating an item ==> updates the list of items and sends update query
        //to the data base
        onPressed: () {
          item.setState(
            (s) => s.copyWith(
              number: s.number + 1,
            ),
          );
        },
      ),
    );
  }
}

class ChildItemWidget extends StatelessWidget {
  const ChildItemWidget();
  @override
  Widget build(BuildContext context) {
    final item = numbers.item.of(context);
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => numbers.crud.delete(
        where: (e) => e.id == item.id,
      ),
    );
  }
}
