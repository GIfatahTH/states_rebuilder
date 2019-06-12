import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'blocs/counter_bloc.dart';

// Provide your BloC using BlocProvider:
class CounterTabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterBloc()],
      builder: (_, __) => MaterialApp(
            home: MyHomePage(),
          ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
    return StateWithMixinBuilder(
      mixinWith: MixinWith.singleTickerProviderStateMixin,
      initState: (_, __, ticker) => counterBloc.initState(ticker),
      dispose: (_, __, ___) => counterBloc.dispose(),
      builder: (_, __) => Scaffold(
            appBar: AppBar(
              title: const Text('states_rebuilder'),
              leading: IconButton(
                tooltip: 'Previous choice',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  counterBloc.nextPage(-1);
                },
              ),
              actions: <Widget>[
                StateBuilder(
                  tag: CounterState.total,
                  viewModels: [counterBloc],
                  builder: (_, __) => CircleAvatar(
                        child: Text("${counterBloc.total}"),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Next choice',
                  onPressed: () {
                    counterBloc.nextPage(1);
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: Container(
                    height: 48.0,
                    alignment: Alignment.center,
                    child:
                        TabPageSelector(controller: counterBloc.tabController),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: counterBloc.tabController,
              children: choices,
            ),
          ),
    );
  }
}
