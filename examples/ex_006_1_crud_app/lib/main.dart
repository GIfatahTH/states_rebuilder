//
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'number.dart';
import 'numbers_repository.dart';

final numbers = RM.injectCRUD<Number, NumberParam>(
  () => NumbersRepository(),
  param: () => NumberParam(userId: '1', numType: NumType.all),
  readOnInitialization: true,
  middleSnapState: (snap) {
    // snap.print(
    //   stateToString: (List<Number> s) => '${s?.length}',
    // );
  },
);

final count = RM.injectFuture<List<int>>(
  () async {
    final repo = await numbers.getRepoAs<NumbersRepository>();
    final all = repo.count(NumberParam(userId: '1', numType: NumType.all));
    final odd = repo.count(NumberParam(userId: '1', numType: NumType.odd));
    final even = repo.count(NumberParam(userId: '1', numType: NumType.even));
    return [await all, await odd, await even];
  },
  initialState: [0, 0, 0],
  dependsOn: DependsOn({numbers}, shouldNotify: (_) => !numbers.isOnCRUD),
  middleSnapState: (snap) {
    // snap.print();
  },
);

void main() => runApp(_App());

class _App extends StatelessWidget {
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
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          number: DateTime.now().second,
        ),
      ),
    );
  }

  AppBar _appBarMethod() {
    return AppBar(
      title: Text('InjectCRUD'),
      leading: On.crud(
        onWaiting: () => Icon(Icons.circle, color: Colors.yellow),
        onError: (_, retry) => IconButton(
          icon: Icon(Icons.refresh_outlined, color: Colors.red),
          onPressed: () => retry(),
        ),
        onResult: (_) => Icon(Icons.circle, color: Colors.green),
      ).listenTo(numbers),
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
        child: On.data(
          () => Row(
            children: [
              //counts are read from database
              Text('All: ${count.state[0]}    '),
              Text('Odd: ${count.state[1]}    '),
              Text('Even: ${count.state[2]}    '),
            ],
          ),
        ).listenTo(count),
      ),
    );
  }

  Widget _bodyMethod() {
    return On.or(
      onWaiting: () => Center(child: CircularProgressIndicator()),
      // onError: (err, refresh) => Center(
      //   child: RaisedButton(
      //     child: Text('Refresh'),
      //     onPressed: () => refresh(),
      //   ),
      // ),
      or: () => ListView.builder(
        itemCount: numbers.state.length,
        itemBuilder: (context, index) {
          return numbers.item.inherited(
            key: Key('${numbers.state[index].id}'),
            item: () => numbers.state[index],
            builder: (context) => const ItemWidget(),
          );
        },
      ),
    ).listenTo(numbers);
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget();
  @override
  Widget build(BuildContext context) {
    final item = numbers.item(context)!;
    return ListTile(
      title: On.data(
        () => Text('${item.state.number}'),
      ).listenTo(item),
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
        onPressed: () => item.setState(
          (s) => s.copyWith(
            number: s.number + 1,
          ),
        ),
      ),
    );
  }
}

class ChildItemWidget extends StatelessWidget {
  const ChildItemWidget();
  @override
  Widget build(BuildContext context) {
    final item = numbers.item.of(context)!;
    return IconButton(
      icon: Icon(Icons.delete),
      onPressed: () => numbers.crud.delete(
        where: (e) => e.id == item.id,
      ),
    );
  }
}
