import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/counter.dart';
import '../../../service/counters_service.dart';
import '../../common/config.dart';
import 'counter_list_tile.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //get the appTitle for the config file
        title: Text(Injector.get<IConfig>().appTitle),
        elevation: 1.0,
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          //getting the registered CountersService instance and call createCounter method
          Injector.get<CountersService>().createCounter();
        },
      ),
    );
  }

  Widget _buildContent() {
    //Use WhenRebuilderOr to subscribe to the stream and display onWaiting, onError and default builder widgets
    return WhenRebuilderOr<List<Counter>>(
      models: [Injector.getAsReactive<List<Counter>>()],
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (error) => Center(child: Text(error.toString())),
      builder: (_, countersStream) {
        final counters = countersStream.snapshot.data;
        if (counters.length > 0) {
          return ListView.builder(
            itemCount: counters.length,
            itemBuilder: (context, index) {
              final counter = counters[index];
              return CounterListTile(
                key: Key('counter-${counter.id}'),
                counter: counter,
              );
            },
          );
        }
        return Center(
          child: Text('You have no counter yet, please add a Counter.'),
        );
      },
    );
  }
}
