import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/counter.dart';
import '../../../service/counters_service.dart';
import '../../widgets/counter_action_button.dart';

class CounterListTile extends StatelessWidget {
  CounterListTile({
    this.key,
    this.counter,
  });
  final Key key;
  final Counter counter;

  final countersService = Injector.get<CountersService>();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: key,
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => countersService.delete(counter),
      child: ListTile(
        title: Text(
          '${counter.value}',
          style: TextStyle(fontSize: 48.0),
        ),
        subtitle: Text(
          '${counter.id}',
          style: TextStyle(fontSize: 16.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CounterActionButton(
              iconData: Icons.remove,
              onPressed: () => countersService.decrement(counter),
            ),
            SizedBox(width: 8.0),
            CounterActionButton(
              iconData: Icons.add,
              onPressed: () => countersService.increment(counter),
            ),
          ],
        ),
      ),
    );
  }
}
